/* vim: ft=cpp showbreak=--»\  noexpandtab fileencoding=utf-8 nomodified wrap textwidth=0 foldmethod=marker foldmarker={{{,}}} foldcolumn=4 ruler showcmd lcs=tab\:|- list: tabstop=8 linebreak  
// ,,g = gcc, exactly one space after "set" */
//
#include "getc.h"



uint8_t input_getc(input_stack_t *s, char *out) {	// {{{ FORTH will use this to get next character
	while (s->count > 0) {
		input_source_t src = s->stack[s->count-1];
		uint8_t r = src.getc(src.state, out);

		if (r == GETC_EOF) {
			s->count--;	// zdroj vyčerpán
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
	if( s->count < GETC_MAX_SOURCES) {
		s->stack[s->count].getc=fn;
		s->stack[s->count].state=state;
		s->count++;
	};
}	// }}}

input_stack_t get_STK;

void input_getc_init(input_stack_t *s){	// {{{
	s->count=0;
}	// }}}
