/* vim: ft=cpp showbreak=--»\  noexpandtab fileencoding=utf-8 nomodified wrap textwidth=0 foldmethod=marker foldmarker={{{,}}} foldcolumn=4 ruler showcmd lcs=tab\:|- list: tabstop=8 linebreak  
 * */
// ,,g = gcc, exactly one space after "set"
//
#include "sd_getc.h"

FATFS fs;

// Internal details are internal :)

typedef struct {
    FIL fil;              // FatFs file handle
    uint8_t buffer[512];  // sektorový buffer
    UINT bytes_in_buf;    // kolik bajtů je v bufferu
    UINT index;           // aktuální index do bufferu
    uint32_t file_pos;    // absolutní pozice (volitelné)

    uint8_t (*refill)(void *ctx);  // funkce pro doplnění bufferu
    void (*on_close)(void *ctx);   // zavření / cleanup
} sd_input_t;

#define SD_MAX_STCK 4
sd_input_t sd_stack[SD_MAX_STCK] __attribute__((section(".highram")));
uint8_t sd_used_mask;
/*
static sd_input_t* sd_alloc(void);	// internal, allocate ctx
static void sd_free(sd_input_t* ptr);	// internal, deallocate ctx
static uint8_t sd_refill(void *ctx);	// internal, read next buff
static void sd_close(void *ptr);	// internal, close used file
*/

// Internal functions are internal :)



static sd_input_t* sd_alloc(void)
{
// TX0_WriteStr("sd_alloc");
for (int i = 0; i < SD_MAX_STCK; i++)
    {
        if (!(sd_used_mask & (1 << i)))
        {
            sd_used_mask |= (1 << i);
//	    TX0_WriteStr(" OK ");
            return &sd_stack[i];
        }
    }
//	    TX0_WriteStr(" FAIL ");
    return NULL;
}
void sd_free(sd_input_t* ptr)
{
    if (ptr < sd_stack || ptr >= sd_stack + SD_MAX_STCK)
        return; // neplatná adresa

    int index = ptr - sd_stack;
    sd_used_mask &= ~(1 << index);
}
static uint8_t sd_refill(void *ctx)
{
//	    TX0_WriteStr(" sd_refill ");
    sd_input_t *in = (sd_input_t*)ctx;
    UINT br;

    if (f_read(&in->fil, in->buffer, 512, &br) != FR_OK || br == 0) {

//	    TX0_WriteStr(" EOF ");
        return 1; // EOF
	}

    in->bytes_in_buf = br;
    in->index = 0;
//    	TX0_WriteHex16(br);
//	    TX0_WriteStr(" OK ");
    return 0;
}

uint8_t sd_getc(void *ptr, char *c)
{
//TX0_WriteStr("sd_getc");
    sd_input_t *in = (sd_input_t*)ptr;

    if (in->index >= in->bytes_in_buf) {
        if (in->refill(ptr))
        {
            *c = 0;
            return 1;   // EOF
        }
    }

    *c = in->buffer[in->index++];
    return 0;           // OK
}

static void sd_close(void *ptr)
{
    sd_input_t *in = (sd_input_t*)ptr;
    f_close(&in->fil);
    sd_free(in);
}
void C_SD_LOAD(char * C_filename)
{
    TX0_WriteStr("FatFs test\r\n");

    FRESULT res;

    res = f_mount(&fs, "", 1);
    if (res != FR_OK)
    {
        TX0_WriteStr("f_mount error: ");
        TX0_WriteHex8(res);
        TX0_WriteStr("\r\n");
        while(1);
    }

    TX0_WriteStr("Mounted OK\r\n");

    DIR dir;
    FILINFO fno;

    res = f_opendir(&dir, "/");
    if (res != FR_OK)
    {
        TX0_WriteStr("f_opendir error\r\n");
        while(1);
    }

    TX0_WriteStr("Root dir:\r\n");

    while (1)
    {
        res = f_readdir(&dir, &fno);
        if (res != FR_OK || fno.fname[0] == 0)
            break;

        if (fno.fattrib & AM_DIR)
            TX0_WriteStr("[DIR] ");
        else
            TX0_WriteStr("      ");

        TX0_WriteStr(fno.fname);
        TX0_WriteStr("\r\n");
    }

    f_closedir(&dir);

    TX0_WriteStr("Done.\r\n");

    sd_input_t *ctx = sd_alloc();
TX0_Write(':');
	res = f_open(&(ctx->fil), C_filename, FA_READ);
	if (res != FR_OK) {
TX0_Write('(');
TX0_WriteHex8(res);
        sd_free(ctx);
        return;
	};
TX0_Write(')');

    ctx->bytes_in_buf = 0;
    ctx->index = 0;
    ctx->refill = sd_refill;
    ctx->on_close = sd_close;

    add_getc(&get_STK,sd_getc,ctx);
}


