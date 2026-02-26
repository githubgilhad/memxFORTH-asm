/* vim: ft=cpp showbreak=--»\  noexpandtab fileencoding=utf-8 nomodified wrap textwidth=0 foldmethod=marker foldmarker={{{,}}} foldcolumn=4 ruler showcmd lcs=tab\:|- list: tabstop=8 linebreak  
// ,,g = gcc, exactly one space after "set" */
//
#include "getc.h"



uint8_t input_getc(input_stack_t *s, char *out) {	// {{{ FORTH will use this to get next character
	while (s->top >= 0) {
		input_source_t src = s->stack[s->top];
		uint8_t r = src.getc(src.state, out);

		if (r == GETC_EOF) {
			s->top--;	// zdroj vyčerpán
			continue;
		}
/*
		if (r == GETC_OK)
			return GETC_OK;

		if (r == GETC_AGAIN)
			return GETC_AGAIN;

*/
		return r; // error
	}

	return GETC_EOF;
}	// }}}

void add_getc(input_stack_t *s,getc_fn fn, void *state) {	// {{{
	if( s->top < GETC_MAX_SOURCES-1) {
		s->top++;
		s->stack[s->top].getc=fn;
		s->stack[s->top].state=state;
	};
}	// }}}

input_stack_t get_STK;

void input_getc_init(){	// {{{
	get_STK.top=-1;
}	// }}}
