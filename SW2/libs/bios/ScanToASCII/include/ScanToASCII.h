/* vim: ft=cpp showbreak=--»\  noexpandtab fileencoding=utf-8 nomodified wrap textwidth=0 foldmethod=marker foldmarker={{{,}}} foldcolumn=4 ruler showcmd lcs=tab\:|- list: tabstop=8 linebreak tags=./tags;,tags; 
 * */
// ,,g = gcc, exactly one space after "set"
//
#pragma once
#ifndef __ASSEMBLER__
#include <inttypes.h>
#include <avr/pgmspace.h>

extern const uint16_t ScanToASCII[2][128] PROGMEM ; // [x][..]: [x][...] --/E0 keystate , [..][y]: PS/2 scancode = ASCII code
#endif

// {{{				special chars
#define	kb_Esc		27	// '\e'
#define	kb_Tab		9	// '\t'
#define	kb_Back		'\b'
#define	kb_Enter	'\n'
#define	kb_Space	' '

#define	kb_CapsLck	( '`'+0x80 )
#define	kb_NumLck	( '~'+0x80 )

#define	kb_ShiftL	( '@'+0x80 )
#define	kb_ShiftR	( '#'+0x80 )
#define	kb_CtrlL	( '$'+0x80 )
#define	kb_CtrlR	( '%'+0x80 )
#define	kb_AltL		( '^'+0x80 )
#define	kb_AltR		( '&'+0x80 )

#define	kb_WinL		( '('+0x80 )
#define	kb_WinR		( ')'+0x80 )

#define	kb_Menu		( '_'+0x80 )

#define	kb_xStar	( '*'+0x80 )
#define	kb_xMinus	( '-'+0x80 )
#define	kb_xPlus	( '+'+0x80 )
#define	kb_xSlash	( '/'+0x80 )
#define	kb_xDot		( '.'+0x80 )
#define	kb_xEnter	( '\n'+0x80 )

#define	kb_PrtScr1	( '='+0x80 )
#define	kb_PrtScr2	( ']'+0x80 )
#define	kb_ScrLck	( '['+0x80 )

/* remap arrows to num keys
 * 
#define	kb_Ins		( '{'+0x80 )
#define	kb_Del		( '}'+0x80 )
#define	kb_Home		( '|'+0x80 )
#define	kb_End		( '\\'+0x80 )
#define	kb_PgUp		( ':'+0x80 )
#define	kb_PgDn		( ';'+0x80 )

#define	kb_Left		( '<'+0x80 )
#define	kb_Up		( ','+0x80 )
#define	kb_Down		( '.'+0x80 )
#define	kb_Right	( '>'+0x80 )
 *
 */
#define	kb_Ins		kb_x0
#define	kb_Del		kb_xDot
#define	kb_Home		kb_x7
#define	kb_End		kb_x1
#define	kb_PgUp		kb_x9
#define	kb_PgDn		kb_x3

#define	kb_Left		kb_x4
#define	kb_Up		kb_x8
#define	kb_Down		kb_x2
#define	kb_Right	kb_x6

/*
 *
 */

#define	kb_x0		( '0'+0x80 )
#define	kb_x1		( '1'+0x80 )
#define	kb_x2		( '2'+0x80 )
#define	kb_x3		( '3'+0x80 )
#define	kb_x4		( '4'+0x80 )
#define	kb_x5		( '5'+0x80 )
#define	kb_x6		( '6'+0x80 )
#define	kb_x7		( '7'+0x80 )
#define	kb_x8		( '8'+0x80 )
#define	kb_x9		( '9'+0x80 )

#define	kb_F1		( 1+0x80 )
#define	kb_F2		( 2+0x80 )
#define	kb_F3		( 3+0x80 )
#define	kb_F4		( 4+0x80 )
#define	kb_F5		( 5+0x80 )
#define	kb_F6		( 6+0x80 )
#define	kb_F7		( 7+0x80 )
#define	kb_F8		( 8+0x80 )
#define	kb_F9		( 9+0x80 )
#define	kb_F10		( 10+0x80 )
#define	kb_F11		( 11+0x80 )
#define	kb_F12		( 12+0x80 )

#define	kb_Pause	( 13+0x80 )
// }}}

#define	kb__Ctrl	(0x80+'A'-'a' )		// A..Z + Ctrl = 0x80 + A..Z	// NOTE, we get small letters from PS/2 as default
#define	kb__Alt		(0x80)			// A..Z + Alt  = 0x80 + a..z


#define	kb_Ctrl_A	('A' + kb__Ctrl)
#define	kb_Ctrl_B	('B' + kb__Ctrl)
#define	kb_Ctrl_C	('C' + kb__Ctrl)
#define	kb_Ctrl_D	('D' + kb__Ctrl)
#define	kb_Ctrl_E	('E' + kb__Ctrl)
#define	kb_Ctrl_F	('F' + kb__Ctrl)
#define	kb_Ctrl_G	('G' + kb__Ctrl)
#define	kb_Ctrl_H	('H' + kb__Ctrl)
#define	kb_Ctrl_I	('I' + kb__Ctrl)
#define	kb_Ctrl_J	('J' + kb__Ctrl)
#define	kb_Ctrl_K	('K' + kb__Ctrl)
#define	kb_Ctrl_L	('L' + kb__Ctrl)
#define	kb_Ctrl_M	('M' + kb__Ctrl)
#define	kb_Ctrl_N	('N' + kb__Ctrl)
#define	kb_Ctrl_O	('O' + kb__Ctrl)
#define	kb_Ctrl_P	('P' + kb__Ctrl)
#define	kb_Ctrl_Q	('Q' + kb__Ctrl)
#define	kb_Ctrl_R	('R' + kb__Ctrl)
#define	kb_Ctrl_S	('S' + kb__Ctrl)
#define	kb_Ctrl_T	('T' + kb__Ctrl)
#define	kb_Ctrl_U	('U' + kb__Ctrl)
#define	kb_Ctrl_V	('V' + kb__Ctrl)
#define	kb_Ctrl_W	('W' + kb__Ctrl)
#define	kb_Ctrl_X	('X' + kb__Ctrl)
#define	kb_Ctrl_Y	('Y' + kb__Ctrl)
#define	kb_Ctrl_Z	('Z' + kb__Ctrl)

#define	kb_Alt_A	('A' + kb__Alt)
#define	kb_Alt_B	('B' + kb__Alt)
#define	kb_Alt_C	('C' + kb__Alt)
#define	kb_Alt_D	('D' + kb__Alt)
#define	kb_Alt_E	('E' + kb__Alt)
#define	kb_Alt_F	('F' + kb__Alt)
#define	kb_Alt_G	('G' + kb__Alt)
#define	kb_Alt_H	('H' + kb__Alt)
#define	kb_Alt_I	('I' + kb__Alt)
#define	kb_Alt_J	('J' + kb__Alt)
#define	kb_Alt_K	('K' + kb__Alt)
#define	kb_Alt_L	('L' + kb__Alt)
#define	kb_Alt_M	('M' + kb__Alt)
#define	kb_Alt_N	('N' + kb__Alt)
#define	kb_Alt_O	('O' + kb__Alt)
#define	kb_Alt_P	('P' + kb__Alt)
#define	kb_Alt_Q	('Q' + kb__Alt)
#define	kb_Alt_R	('R' + kb__Alt)
#define	kb_Alt_S	('S' + kb__Alt)
#define	kb_Alt_T	('T' + kb__Alt)
#define	kb_Alt_U	('U' + kb__Alt)
#define	kb_Alt_V	('V' + kb__Alt)
#define	kb_Alt_W	('W' + kb__Alt)
#define	kb_Alt_X	('X' + kb__Alt)
#define	kb_Alt_Y	('Y' + kb__Alt)
#define	kb_Alt_Z	('Z' + kb__Alt)
