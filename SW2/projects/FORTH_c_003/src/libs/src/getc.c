/* vim: ft=cpp showbreak=--»\  noexpandtab fileencoding=utf-8 nomodified wrap textwidth=0 foldmethod=marker foldmarker={{{,}}} foldcolumn=4 ruler showcmd lcs=tab\:|- list: tabstop=8 linebreak tags=./tags;,tags;
 * */
// ,,g = gcc, exactly one space after "set"

#include "getc.h"

// VGA_write_char
#include "bios.h"
#define TEXT __attribute__((section(".text.C_libs")))
#define HIGRAM __attribute__((section(".highram.C_libs")))


TEXT uint8_t C_getc(input_stack_t *s, char *out) {	// {{{ FORTH will use this to get next character
//	    TX0_WriteStr(" C_getc ");
	while (s->count > 0) {
//		TX0_WriteHex8(s->count);
		input_source_t src = s->stack[s->count-1];
		uint8_t r = src.getc(src.state, out);

		if (r == GETC_OK) { 		// ECHO
			if ( ! ( *out==10 || *out==13 || *out==kb_Back || *out=='\t' ) )	// "invisible" chars
				VGA_write_char(*out);
			if ( *out=='\t') VGA_write_char(' ');
			if ( *out==kb_Back)	// Backspace
				{
					uint16_t cur;
					uint8_t x,y;
					cur=VGA_get_cursor_XY();
					x=cur & 0xFF; y=(cur >>8)&0xFF;
					if (x==0) {
						x= TextVGA_COLUMNS-1;
						y--;
					} else {
						x--;
					};
					VGA_set_cursor_XY(x, y);
					VGA_write_char(' ');
					VGA_set_cursor_XY(x, y);
				}
			TX0_Write(*out);
			if (*out==13){
				TX0_Write(10);
				VGA_cr();
			};
			if (*out==10){
				TX0_Write(13);
				VGA_cr();
			};
		};

		if (r == GETC_EOF) {
			s->count--;	// zdroj vyčerpán
			return GETC_EOF_MET;	// signal non-fatal EOF
			// continue;
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

TEXT void add_getc(input_stack_t *s,getc_fn fn, void *state) {	// {{{
//TX0_WriteStr(" add_getc("); TX0_WriteHex16((uint16_t)s);TX0_Write(',');TX0_WriteHex16((uint16_t)fn); TX0_Write(',');TX0_WriteHex16((uint16_t)state);TX0_WriteStr(" ) ");
	if( s->count < GETC_MAX_SOURCES) {
		s->stack[s->count].getc=fn;
		s->stack[s->count].state=state;
		s->count++;
//		TX0_WriteHex8(s->count);
	};
}	// }}}

HIGRAM input_stack_t get_STK;

TEXT void C_getc_init(input_stack_t *s){	// {{{
//TX0_WriteStr(" C_getc_init("); TX0_WriteHex16((uint16_t)s);TX0_WriteStr(" ) ");
	s->count=0;
}	// }}}
