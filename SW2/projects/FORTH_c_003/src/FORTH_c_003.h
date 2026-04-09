/* vim: ft=cpp showbreak=--»\  noexpandtab fileencoding=utf-8 nomodified wrap textwidth=0 foldmethod=marker foldmarker={{{,}}} foldcolumn=4 ruler showcmd lcs=tab\:|- list: tabstop=8 linebreak tags=./tags;,tags; 
 * */
// ,,g = gcc, exactly one space after "set"
//
#pragma once
#include <avr/io.h>
#include <avr/interrupt.h>
#include <stdlib.h>
#include <string.h>

#include "TCB_offsets.h"
#include "usart0.h"
#include "VGA0.h"
#include "FORTH-Engine.h"
#include "C_Bats.h"		// ../../../libs/FORTH/C_Bats/include/C_Bats.h
#include "C2forth.h"
#include "flags.h"
#include "debug.h"
#include "getc.h"
#include "bios.h"
#include "DebugLEDs.h"
#include "vectors.h"
#include "TextVGA.h"

extern T_TextVGA_VRAM VRAM;
extern T_TextVGA_CRAM CRAM;
extern void func_yield();
uint8_t serial_getc(void *state, char *out_char);

// External FORTH primitives

typedef const __memx uint8_t *xpC;
typedef const __memx uint8_t   xC;
typedef const uint8_t *npC;
typedef const uint8_t   nC;


extern __memx const uint8_t w_TEST_cw;
extern __memx const uint8_t w_QUIT_cw;
extern __memx const uint8_t w_zzz_eol_1;
extern __memx const uint8_t ww_zzz_eol_2;
extern __memx const uint8_t ww_zzz_eol_3;
extern xC FORTH_WORDS_START;
extern xC FORTH_WORDS_END;
extern xC f_docol;
extern xC w_docol_cw;
extern const __memx uint32_t	val_of_w_exit_cw;
extern const __memx uint32_t	val_of_f_docol;

extern uint8_t __data_start;
extern uint8_t __data_end;
extern uint8_t __highram_start;
extern uint8_t __highram_end;
extern uint8_t __bss_start;
extern uint8_t __bss_end;
extern uint8_t __noinit_start;
extern uint8_t __noinit_end;
extern uint8_t __heap_start;
#pragma GCC push_options
#pragma GCC optimize ("no-strict-aliasing")

static inline P16 U16_P16(uint16_t x){ return *(P16*)&x;  }
static inline P24 U32_P24(uint32_t x){ return *(P24*)&x;  }
static inline uint32_t P24_U32(P24 x) { uint32_t r; __asm__ ( "clr %D0" : "=r" (r) : "0" (x)); return r; }
static inline uint32_t xpC_U32(xpC x) { uint32_t r; __asm__ ( "clr %D0" : "=r" (r) : "0" (x)); return r; }
static inline uint32_t npC_U32(npC x) { uint32_t r; __asm__ ( "clr %D0" : "=r" (r) : "0" (x)); return r; }
//static inline DOUBLE_t U32_D(uint32_t x){ return x & 0x00FFFFFFUL; }
#pragma GCC pop_options
