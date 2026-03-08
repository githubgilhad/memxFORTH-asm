/* vim: ft=cpp showbreak=--»\  noexpandtab fileencoding=utf-8 nomodified wrap textwidth=0 foldmethod=marker foldmarker={{{,}}} foldcolumn=4 ruler showcmd lcs=tab\:|- list: tabstop=8 linebreak  
 * */
// ,,g = gcc, exactly one space after "set"
//
#include "sd_getc.h"


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
void sd_free(sd_input_t* ptr)
{
    if (ptr < sd_stack || ptr >= sd_stack + SD_MAX_STCK)
        return; // neplatná adresa

    int index = ptr - sd_stack;
    sd_used_mask &= ~(1 << index);
}
static uint8_t sd_refill(void *ctx)
{
    sd_input_t *in = (sd_input_t*)ctx;
    UINT br;

    if (f_read(&in->fil, in->buffer, 512, &br) != FR_OK || br == 0)
        return 1; // EOF

    in->bytes_in_buf = br;
    in->index = 0;
    return 0;
}

uint8_t sd_getc(void *ptr, char *c)
{
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
    sd_input_t *ctx = sd_alloc();

    if (f_open(&(ctx->fil), C_filename, FA_READ) != FR_OK) {
        sd_free(ctx);
        return;
	};

    ctx->bytes_in_buf = 0;
    ctx->index = 0;
    ctx->refill = sd_refill;
    ctx->on_close = sd_close;

    add_getc(&get_STK,sd_getc,ctx);
}


