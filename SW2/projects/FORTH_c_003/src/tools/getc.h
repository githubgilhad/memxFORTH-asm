/* vim: ft=cpp showbreak=--»\  noexpandtab fileencoding=utf-8 nomodified wrap textwidth=0 foldmethod=marker foldmarker={{{,}}} foldcolumn=4 ruler showcmd lcs=tab\:|- list: tabstop=8 linebreak  
// ,,g = gcc, exactly one space after "set" */
//
#pragma once

#include <stdint.h>


#define GETC_MAX_SOURCES 8

#define GETC_OK		   0   // znak byl vrácen
#define GETC_EOF	   1   // definitivní konec zdroje
#define GETC_AGAIN	   2   // teď nic, zkus později (neblokující zdroj)


typedef uint8_t (*getc_fn)(void *state, char *out_char);	// universal funkction to get characters

typedef struct {
	getc_fn getc;
	void *state;
} input_source_t;


typedef struct {
	input_source_t stack[GETC_MAX_SOURCES];
	int8_t top;
} input_stack_t;


uint8_t input_getc(input_stack_t *s, char *out); 	//  FORTH will use this to get next character

void add_getc(input_stack_t *s,getc_fn fn, void *state) ;

extern input_stack_t get_STK;

void input_getc_init();
