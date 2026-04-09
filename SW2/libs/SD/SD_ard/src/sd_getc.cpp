#include "Arduino.h"
#include "SD.h"
#include "SPI.h"

#include "sd_getc.h"

// =========================
// Interní struktura
// =========================

typedef struct {
	File file;           // Arduino File handle
	uint8_t buffer[512];
	uint16_t bytes_in_buf;
	uint16_t index;

	uint8_t (*refill)(void *ctx);
	void (*on_close)(void *ctx);
} sd_input_t;

#define SD_MAX_STCK 4

sd_input_t sd_stack[SD_MAX_STCK] __attribute__((section(".highram")));
uint8_t sd_used_mask = 0;

// =========================
// Alokace
// =========================

static sd_input_t* sd_alloc(void)
{
	for (int i = 0; i < SD_MAX_STCK; i++)
	{
		if (!(sd_used_mask & (1 << i)))
		{
			sd_used_mask |= (1 << i);
			return &sd_stack[i];
		}
	}
	return NULL;
}

static void sd_free(sd_input_t* ptr)
{
	if (ptr < sd_stack || ptr >= sd_stack + SD_MAX_STCK)
		return;

	int index = ptr - sd_stack;
	sd_used_mask &= ~(1 << index);
}

// =========================
// Refill bufferu
// =========================

static uint8_t sd_refill(void *ctx)
{
	sd_input_t *in = (sd_input_t*)ctx;

	int n = in->file.read(in->buffer, sizeof(in->buffer));

	if (n <= 0)
		return 1; // EOF

	in->bytes_in_buf = n;
	in->index = 0;

	return 0;
}

// =========================
// GETC (hlavní API)
// =========================

extern "C" 
uint8_t sd_getc(void *ptr, char *c)
{
	sd_input_t *in = (sd_input_t*)ptr;

	if (in->index >= in->bytes_in_buf)
	{
		if (in->refill(ptr))
		{
			*c = 0;
			return 1; // EOF
		}
	}

	*c = in->buffer[in->index++];
	return 0;
}

// =========================
// Close
// =========================

static void sd_close(void *ptr)
{
	sd_input_t *in = (sd_input_t*)ptr;

	if (in->file)
		in->file.close();

	sd_free(in);
}

// =========================
// LOAD (hlavní vstup)
// =========================
extern "C" 
void C_SD_LOAD(char *C_filename)
{
	VGA0_WriteStr((char*)"SD init...\r\n");

	if (!SD.begin())
	{
		VGA0_WriteStr((char*)"SD init FAIL\r\n");
		return;
	}

	VGA0_WriteStr((char*)"SD OK\r\n");

	// (volitelné) listing root
	File root = SD.open("/");
	if (root)
	{
		VGA0_WriteStr((char*)"Root:\r\n");

		File entry;
		while ((entry = root.openNextFile()))
		{
			if (entry.isDirectory())
				VGA0_WriteStr((char*)"[DIR] ");
			else
				VGA0_WriteStr((char*)"      ");

			VGA0_WriteStr(entry.name());
			VGA0_WriteStr((char*)"\r\n");

			entry.close();
		}

		root.close();
	}

	// otevření souboru
	sd_input_t *ctx = sd_alloc();
	if (!ctx)
	{
		VGA0_WriteStr((char*)"No ctx\r\n");
		return;
	}

	ctx->file = SD.open(C_filename, FILE_READ);

	if (!ctx->file)
	{
		VGA0_WriteStr((char*)"Open FAIL\r\n");
		sd_free(ctx);
		return;
	}

	VGA0_WriteStr((char*)"Open OK\r\n");

	ctx->bytes_in_buf = 0;
	ctx->index = 0;
	ctx->refill = sd_refill;
	ctx->on_close = sd_close;

	add_getc(&get_STK, sd_getc, ctx);
}
