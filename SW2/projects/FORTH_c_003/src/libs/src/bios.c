/* vim: ft=cpp showbreak=--»\  noexpandtab fileencoding=utf-8 nomodified wrap textwidth=0 foldmethod=marker foldmarker={{{,}}} foldcolumn=4 ruler showcmd lcs=tab\:|- list: tabstop=8 linebreak tags=./tags;,tags; 
 * */
// ,,g = gcc, exactly one space after "set"
//
#define TEXT __attribute__((section(".text.bios")))
#define HIGHRAM __attribute__((section(".highram.bios")))
#include "bios.h"
	HIGHRAM static bool Ctrl = false;
	HIGHRAM static bool Alt = false;
	HIGHRAM static bool Shift = false;
	//
	HIGHRAM static bool Caps = false;
	HIGHRAM static bool Nums = true;
	//
	HIGHRAM static bool oCtrl = false;
	HIGHRAM static bool oAlt = false;
	HIGHRAM static bool oShift = false;
	//
	HIGHRAM static bool oCaps = false;
	HIGHRAM static bool oNums = false;
	//
#define PS2_NONE	0
#define PS2_E0		1
#define PS2_F0		2
#define PS2_E0F0	3
#define PS2_E1		4
#define PS2_E1_2	5
#define PS2_E1F0	6
	//
	HIGHRAM static uint8_t state = PS2_NONE;
TEXT uint8_t process_scan_code(uint8_t code) {										// {{{
//
	uint8_t c;
	if (code == 0xE0) {	// {{{
		switch (state) { 
		case PS2_NONE:
			state = PS2_E0;
			break;
		case PS2_E0:
			break;
		case PS2_F0:
			state = PS2_E0F0;
			break;
		case PS2_E0F0:
			break;
		default:
			state=PS2_E0;
		};
		return 0;
	};	// }}}
	if (code == 0xE1) {	// {{{
		switch (state) { 
		case PS2_NONE:
			state = PS2_E1;
			break;
		case PS2_E1:
			break;
		case PS2_F0:
			state = PS2_E1F0;
			break;
		case PS2_E1F0:
			break;
		default:
			state=PS2_E1;
		};
		return 0;
	};	// }}}
	if (code == 0xF0) {// {{{ 
		switch (state) { 
		case PS2_NONE:
			state = PS2_F0;
			break;
		case PS2_E0:
			state = PS2_E0F0;
			break;
		case PS2_F0:
			break;
		case PS2_E0F0:
			break;
		default:
			state=PS2_F0;
		};
		return 0;
	};	// }}}
	switch (state) {
		case PS2_NONE:
			c=pgm_read_byte_far(&ScanToASCII[0][code & 0x7F]);
			if (code == 0x83 ) c=kb_F7;
			switch (c) {
				case kb_ShiftL: case kb_ShiftR:  Shift=true; return 0; break;
				case kb_CtrlL: case kb_CtrlR:  Ctrl=true; return 0; break;
				case kb_AltL: case kb_AltR:  Alt=true; return 0; break;
				case kb_CapsLck: Caps = !Caps; return 0; break;
				case kb_NumLck: Nums = !Nums; return 0; break;
				default: // nothing
			};
			if ((c>='a') && (c<='z')) {	// a..z
				if (Ctrl) return c+kb__Ctrl;
				if (Alt) return c+kb__Alt;
				if (Shift ^ Caps) return c+'A'-'a';
				return c;
			};
			if (Shift) c = apply_shift_s(c);	// non a..z
			;
			if (Shift ^ Nums) {	// numeric block
				if ((c >=kb_x0) && (c <= kb_x9)) return c-0x80;
				if ( c == kb_xDot ) return c-0x80;
			};
			if ((c ==kb_xStar) || (c == kb_xMinus) || ( c == kb_xPlus ) ) return c-0x80;		// so far treat it as normal everytime
			return c;
			break;
		case PS2_E0:
			c=pgm_read_byte_far(&ScanToASCII[1][code & 0x7F]);
			switch (c) {
				case kb_ShiftL: case kb_ShiftR:  Shift=true; return 0; break;
				case kb_CtrlL: case kb_CtrlR:  Ctrl=true; return 0; break;
				case kb_AltL: case kb_AltR:  Alt=true; return 0; break;
				default: // nothing
			};
			if (( c == kb_xSlash ) || ( c == kb_xEnter ) ) return c-0x80;		// so far treat it as normal everytime
			return c;
			break;
		case PS2_F0:
			state = PS2_NONE;
			c=pgm_read_byte_far(&ScanToASCII[0][code & 0x7F]);
			switch (c) {
				case kb_ShiftL: case kb_ShiftR:  Shift=false; return 0; break;
				case kb_CtrlL: case kb_CtrlR:  Ctrl=false; return 0; break;
				case kb_AltL: case kb_AltR:  Alt=false; return 0; break;
				default: // nothing
			};
			return 0;	// eat code, was released
			break;
		case PS2_E1:
			state = PS2_E1_2;
			return 0;	// eat code(14), waiting for next(77) for Pause
			break;
		case PS2_E1_2:
			state = PS2_NONE;
			return kb_Pause;	// eaten code(14), eat code(77), its Pause
			break;
		case PS2_E1F0:
			state = PS2_NONE;
			return 0;	// eat code, was released
			break;
		case PS2_E0F0:
			state = PS2_NONE;
			c=pgm_read_byte_far(&ScanToASCII[1][code & 0x7F]);
			switch (c) {
				case kb_ShiftL: case kb_ShiftR:  Shift=false; return 0; break;
				case kb_CtrlL: case kb_CtrlR:  Ctrl=false; return 0; break;
				case kb_AltL: case kb_AltR:  Alt=false; return 0; break;
				default: // nothing
			};
			return 0;	// eat code, was released
			break;
		default:
		};
	return 0;	// should not came here
}	// }}}
TEXT uint8_t ps2_getc(void *state, char *out_char) { 	// {{{
	(void)state;	// state UNUSED, no compiler complains
	uint16_t ch;
	while (BUF_Free_C(&PS2_ASCII) && BUF_Used_C(&PS2_input))	{
		ch = BUF_Read_C(&PS2_input);
		if (ch >>8) { 
			ch=process_scan_code(ch&0xFF);
			if (ch) BUF_Write_C(&PS2_ASCII,ch);
		};
	};
	if ( (Ctrl!=oCtrl) || (Alt!=oAlt) || (Shift!=oShift) || (Caps !=oCaps ) || (Nums !=oNums ) ) {
		oCtrl=Ctrl;
		oAlt=Alt;
		oShift=Shift;
		oCaps =Caps ;
		oNums =Nums ;
#ifndef NO_VGA
		DebugLEDs_setRGB(0,Caps?0x80:0,0,0);
		DebugLEDs_setRGB(1,0,Nums?0x80:0,0);
		DebugLEDs_setRGB(2,Ctrl?0x80:0,0,0);
		DebugLEDs_setRGB(3,0,0,Alt?0x80:0);
		DebugLEDs_setRGB(4,0,Shift?0x80:0,0);
		DebugLEDs_show();
#endif
	};
	ch = BUF_Read_C(&PS2_ASCII);
	*out_char = (ch & 0xFF);
	return (ch >> 8)? GETC_OK:GETC_AGAIN;
}	// }}}


HIGHRAM static uint8_t cursor_X = 0;
HIGHRAM static uint8_t cursor_Y = 0;
HIGHRAM static bool cursor_visible = true;
HIGHRAM static char cursor_char = 151; // block
HIGHRAM static uint8_t def_color = VGA_none;
HIGHRAM static uint8_t def_char = ' ';
#define Fix_Cursor TextVGA_cursor_ptr=&VRAM[cursor_Y][cursor_X];
TEXT void bios_setup() {	// {{{
	Ctrl = false;
	Alt = false;
	Shift = false;
	
	Caps = false;
	Nums = true;
	
	oCtrl = false;
	oAlt = false;
	oShift = false;
	
	oCaps = false;
	oNums = false;
	
	state = PS2_NONE;
	cursor_X = 0;
	cursor_Y = 0;
	cursor_visible = true;
	cursor_char = 151; // block
	def_color = VGA_none;
	def_char = ' ';
}	// }}}

TEXT void scroll () {	// {{{
			cursor_Y--;
			for (uint8_t y=0; y < TextVGA_LINES-1; y++) 
				for (uint8_t x=0; x < TextVGA_COLUMNS; x++) 
					VRAM[y][x] = VRAM[y+1][x];
			for (uint8_t x=0; x < TextVGA_COLUMNS; x++) 
				VRAM[TextVGA_LINES-1][x] = def_char;
			for (uint8_t y=0; y < TextVGA_LINES-1; y++) 
				CRAM[y]=CRAM[y+1];
			CRAM[TextVGA_LINES-1]= def_color;
			Fix_Cursor;
}	// }}}

TEXT void VGA_write_char(uint8_t c) {			// {{{  write char to cursor, move cursor, scroll screen if needed
	VRAM[cursor_Y][cursor_X++] = c;
	if (cursor_X >=TextVGA_COLUMNS) {
		cursor_X = 0;
		cursor_Y ++;
		if (cursor_Y >=TextVGA_LINES) {
			scroll();
		};
	};
	Fix_Cursor;
}	// }}}
TEXT void VGA_cls() {			// {{{  clear screen with default character and color, moves cursor to 0,0
	for (uint8_t y=0; y < TextVGA_LINES; y++) 
		for (uint8_t x=0; x < TextVGA_COLUMNS; x++) 
			VRAM[y][x] = def_char;
	
	for (uint8_t y=0; y < TextVGA_LINES; y++) 
		CRAM[y] = def_color;
	cursor_X = 0;
	cursor_Y = 0;
	Fix_Cursor;
}	// }}}
TEXT void VGA_set_cursor_visible(bool c) {			// {{{  set new value, return old
	cursor_visible = c;
}	// }}}
TEXT void VGA_set_cursor_char(uint8_t c) {		// {{{  set new value, return old
	cursor_char = c;
}	// }}}
TEXT void VGA_set_cursor_X(uint8_t x) {			// {{{  set new value, return old
	cursor_X = x;
	Fix_Cursor;
}	// }}}
TEXT void VGA_set_cursor_Y(uint8_t y) {			// {{{  set new value, return old
	cursor_Y = y;
	Fix_Cursor;
}	// }}}
TEXT void VGA_set_cursor_XY(uint8_t x, uint8_t y) {		// {{{  set new value
	cursor_X = x;
	cursor_Y = y;
	Fix_Cursor;
}	// }}}
TEXT uint16_t VGA_get_cursor_XY() {				// get value (r24 = X, r25 = Y) X+256*Y
	return cursor_X + 256* cursor_Y;
}	// }}
TEXT void VGA_put_char_XY(char c, uint8_t x, uint8_t y) {	// {{{  put char on screen without moving cursor
	VRAM[y][x] = c;
}	// }}}
TEXT void VGA_set_def_color(uint8_t col) {		// {{{  set current row color
	def_color = col;
}	// }}}
TEXT void VGA_set_def_char(uint8_t c) {		// {{{  set current row color
	def_char = c;
}	// }}}
TEXT void VGA_set_row_color(uint8_t col) {		// {{{  set current row color
	CRAM[cursor_Y] = col;
}	// }}}
TEXT void VGA_set_row_color_Y(uint8_t col, uint8_t y) {	// {{{  set row color
	CRAM[y] = col;
}	// }}}
TEXT uint8_t VGA_char_at_XY(uint8_t x, uint8_t y) {		// {{{  return char at X,Y
	return VRAM[y][x];
}	// }}}
TEXT uint8_t VGA_MAX_LINES() {				// {{{
	return TextVGA_LINES;
}	// }}}
TEXT uint8_t VGA_MAX_COLUMNS() {				// {{{
	return TextVGA_COLUMNS;
}	// }}}
TEXT void VGA_cr() {	// {{{  go to new line
	cursor_X=0;
	cursor_Y++;
	if (cursor_Y >=TextVGA_LINES) {
		scroll();
	};
	Fix_Cursor;
}	// }}}
TEXT void VGA_HEADLESS() {
	TextVGA_HEADLESS();
}
TEXT void VGA_HEADMORE(){
	TextVGA_HEADMORE();
}

