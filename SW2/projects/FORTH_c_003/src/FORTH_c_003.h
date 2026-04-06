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
#include "tools/VGA0.h"
#include "FORTH-Engine.h"
#include "C_Bats.h"
#include "tools/C2forth.h"
#include "flags.h"
#include "tools/debug.h"
#include "tools/getc.h"
#include "tools/bios.h"
#include "DebugLEDs.h"
#include "tools/vectors.h"
#include "TextVGA.h"
#include "../version.h"

extern T_TextVGA_VRAM VRAM;
extern T_TextVGA_CRAM CRAM;
extern void func_yield();
uint8_t serial_getc(void *state, char *out_char);
