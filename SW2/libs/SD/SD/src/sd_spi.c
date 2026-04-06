#include "sd_spi.h"
#include <avr/io.h>
#include <util/delay.h>

#define SD_CS_LOW()    PORTB &= ~(1 << PB0)
#define SD_CS_HIGH()   PORTB |=  (1 << PB0)

#define SPI_DDR   DDRB
#define SPI_PORT  PORTB

static uint8_t sd_type = 0;   // 1 = SDSC, 2 = SDHC

// ------------------------------------------------
// SPI low-level
// ------------------------------------------------

static void spi_init_slow(void)
{
    SPI_DDR |= (1<<PB0) | (1<<PB1) | (1<<PB2); // SS, SCK, MOSI output
    SPI_DDR &= ~(1<<PB3);                      // MISO input

    SPI_PORT |= (1<<PB0); // CS high

    SPCR = (1<<SPE) | (1<<MSTR) | (1<<SPR1) | (1<<SPR0); // F_CPU/128
    SPSR = 0;
}

static void spi_init_fast(void)
{
    SPCR = (1<<SPE) | (1<<MSTR);  // F_CPU/4
    SPSR = (1<<SPI2X);            // F_CPU/2
}

static uint8_t spi_txrx(uint8_t d)
{
    SPDR = d;
    while (!(SPSR & (1<<SPIF)));
    return SPDR;
}

// ------------------------------------------------
// SD helpers
// ------------------------------------------------

static void sd_send_clock_train(void)
{
    SD_CS_HIGH();
    for (uint8_t i=0; i<10; i++)
        spi_txrx(0xFF);
}


static uint8_t sd_wait_ready(void)
{
//    uint16_t timeout = 50000;
    uint16_t timeout = 5000;
    uint8_t r;

    do {
        r = spi_txrx(0xFF);
    } while (r != 0xFF && --timeout);

    return (timeout ? 0 : 1);
}

static uint8_t sd_command(uint8_t cmd, uint32_t arg, uint8_t crc)
{
    uint8_t r;

    SD_CS_LOW();
    if (sd_wait_ready()) {
         SD_CS_HIGH();
         return 0xFF;
    }
    spi_txrx(0xFF);

    spi_txrx(0x40 | cmd);
    spi_txrx(arg >> 24);
    spi_txrx(arg >> 16);
    spi_txrx(arg >> 8);
    spi_txrx(arg);
    spi_txrx(crc);

    for (uint8_t i=0; i<10; i++) {
        r = spi_txrx(0xFF);
        if (!(r & 0x80))
            return r;
    }

    return 0xFF;
}

// ------------------------------------------------
// Initialization
// ------------------------------------------------

uint8_t sd_init(void)
{
    uint8_t r;
    uint16_t i;

    spi_init_slow();
    sd_send_clock_train();

    // CMD0
    r = sd_command(0, 0, 0x95);
    if (r != 0x01) return 1;

    SD_CS_HIGH();
    spi_txrx(0xFF);

    // CMD8
    r = sd_command(8, 0x1AA, 0x87);
    if (r == 0x01)
    {
        uint8_t ocr[4];
        for (i=0;i<4;i++)
            ocr[i] = spi_txrx(0xFF);

        SD_CS_HIGH();
        spi_txrx(0xFF);

        if (ocr[2] != 0x01 || ocr[3] != 0xAA)
            return 2;

        // ACMD41
        do {
            sd_command(55,0,0x01);
            r = sd_command(41,0x40000000,0x01);
            SD_CS_HIGH();
            spi_txrx(0xFF);
        } while (r != 0 && --i);

        if (!i) return 3;

        // CMD58
        r = sd_command(58,0,0x01);
        if (r) return 4;

        uint8_t ocr2[4];
        for (i=0;i<4;i++)
            ocr2[i] = spi_txrx(0xFF);

        SD_CS_HIGH();
        spi_txrx(0xFF);

        sd_type = (ocr2[0] & 0x40) ? 2 : 1;
    }
    else
    {
        return 5; // jen SD v2 podporováno
    }

    spi_init_fast();
    return 0;
}

// ------------------------------------------------
// Read single block (CMD17)
// ------------------------------------------------

uint8_t sd_read_block(uint32_t lba, uint8_t *buf)
{
    uint8_t r;
    uint16_t i;

    if (sd_type != 2)
        lba <<= 9;

    r = sd_command(17, lba, 0x01);
    if (r) { SD_CS_HIGH(); return 1; }

    // čekání na token 0xFE
    i = 50000;
    while ((r = spi_txrx(0xFF)) == 0xFF && --i);

    if (r != 0xFE) { SD_CS_HIGH(); return 2; }

    for (i=0;i<512;i++)
        buf[i] = spi_txrx(0xFF);

    spi_txrx(0xFF); // CRC
    spi_txrx(0xFF);

    SD_CS_HIGH();
    spi_txrx(0xFF);

    return 0;
}

// ------------------------------------------------
// Write single block (CMD24)
// ------------------------------------------------

uint8_t sd_write_block(uint32_t lba, const uint8_t *buf)
{
    uint8_t r;
    uint16_t i;

    if (sd_type != 2)
        lba <<= 9;

    r = sd_command(24, lba, 0x01);
    if (r) { SD_CS_HIGH(); return 1; }

    spi_txrx(0xFF);
    spi_txrx(0xFE);

    for (i=0;i<512;i++)
        spi_txrx(buf[i]);

    spi_txrx(0xFF);
    spi_txrx(0xFF);

    r = spi_txrx(0xFF);
    if ((r & 0x1F) != 0x05) { SD_CS_HIGH(); return 2; }

    while (!spi_txrx(0xFF));

    SD_CS_HIGH();
    spi_txrx(0xFF);

    return 0;
}
