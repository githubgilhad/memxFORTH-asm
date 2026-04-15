/* vim: set ft=cpp noexpandtab fileencoding=utf-8 nomodified wrap textwidth=0 foldmethod=marker foldmarker={{{,}}} foldcolumn=4 ruler showcmd lcs=tab\:|- list: tabstop=8 linebreak showbreak=»\   */
// ,,g = gcc, exactly one space after "set"
//
#include "io.h"
#define TEXT __attribute__((section(".text.C_libs")))
TEXT char wait_for_char() {	// {{{
	char c=0;
	while (c ==0) {c=read_char();};
	write_char(c);
	if (c=='\r') write_char('\n');
	if (c=='\n') write_char('\r');
	return c;
}	// }}}
TEXT void write_str(const __memx char *c) { 	// {{{
	while (*c){write_char(*c++);};
}	// }}}
TEXT void write_eoln() { 	// {{{
	write_char('\r');
	write_char('\n');
}	// }}}
