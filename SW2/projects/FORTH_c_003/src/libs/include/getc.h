/* vim: ft=cpp showbreak=--»\  noexpandtab fileencoding=utf-8 nomodified wrap textwidth=0 foldmethod=marker foldmarker={{{,}}} foldcolumn=4 ruler showcmd lcs=tab\:|- list: tabstop=8 linebreak tags=./tags;,tags; 
 * */
// ,,g = gcc, exactly one space after "set"
#pragma once

#include <stdint.h>
#include "getc.inc"
#include "usart0.h"

#ifdef __cplusplus
extern "C" {
#endif

typedef uint8_t (*getc_fn)(void *state, char *out_char);	// universal funkction to get characters

typedef struct {
	getc_fn getc;
	void *state;
} input_source_t;


typedef struct {
	input_source_t stack[GETC_MAX_SOURCES];
	int8_t count;
} input_stack_t;


uint8_t C_getc(input_stack_t *s, char *out); 	//  FORTH will use this to get next character

void add_getc(input_stack_t *s,getc_fn fn, void *state) ;

extern input_stack_t get_STK;

void C_getc_init(input_stack_t *s);

#ifdef __cplusplus
	}
#endif

