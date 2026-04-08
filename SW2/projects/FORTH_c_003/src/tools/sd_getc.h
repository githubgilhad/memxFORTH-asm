/* vim: ft=cpp showbreak=--»\  noexpandtab fileencoding=utf-8 nomodified wrap textwidth=0 foldmethod=marker foldmarker={{{,}}} foldcolumn=4 ruler showcmd lcs=tab\:|- list: tabstop=8 linebreak  
 * */
// ,,g = gcc, exactly one space after "set"
//
#pragma once


#include "ff.h"
#include <avr/interrupt.h>
#include "getc.h"
#include <stddef.h>
#include "VGA0.h"

#include "diskio.h"		/* Declarations FatFs MAI */

uint8_t sd_getc(void *ptr, char *c);	// exported, source of chars
void C_SD_LOAD(char * C_filename);	// word SD.LOAD, call with C string in RAM
