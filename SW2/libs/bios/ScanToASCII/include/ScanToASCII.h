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

#define	kb_Esc		'\e'
#define	kb_Tab		'\t'
#define	kb_Back		'\b'
#define	kb_Enter	'\n'

#define	kb_CapsLck	'`'+0x80
#define	kb_NumLck	'~'+0x80

#define	kb_ShiftL	'@'+0x80
#define	kb_ShiftR	'#'+0x80
#define	kb_CtrlL	'$'+0x80
#define	kb_CtrlR	'%'+0x80
#define	kb_AltL		'^'+0x80
#define	kb_AltR		'&'+0x80

#define	kb_WinL		'('+0x80
#define	kb_WinR		')'+0x80

#define	kb_Menu		'_'+0x80

#define	kb_xStar	'*'+0x80
#define	kb_xMinus	'-'+0x80
#define	kb_xPlus	'+'+0x80
#define	kb_xSlash	'/'+0x80
#define	kb_xDot		'.'+0x80
#define	kb_xEnter	'\n'+0x80

#define	kb_PrtScr1	'='+0x80
#define	kb_PrtScr2	']'+0x80
#define	kb_ScrLck	'['+0x80

#define	kb_Ins		'{'+0x80
#define	kb_Del		'}'+0x80
#define	kb_Home		'|'+0x80
#define	kb_End		'\\'+0x80
#define	kb_PgUp		':'+0x80
#define	kb_PgDn		';'+0x80

#define	kb_Left		'<'+0x80
#define	kb_Up		','+0x80
#define	kb_Down		'.'+0x80
#define	kb_Right	'>'+0x80

#define	kb_x0		'0'+0x80
#define	kb_x1		'1'+0x80
#define	kb_x2		'2'+0x80
#define	kb_x3		'3'+0x80
#define	kb_x4		'4'+0x80
#define	kb_x5		'5'+0x80
#define	kb_x6		'6'+0x80
#define	kb_x7		'7'+0x80
#define	kb_x8		'8'+0x80
#define	kb_x9		'9'+0x80

#define	kb_F1		1+0x80
#define	kb_F2		2+0x80
#define	kb_F3		3+0x80
#define	kb_F4		4+0x80
#define	kb_F5		5+0x80
#define	kb_F6		6+0x80
#define	kb_F7		14+0x80
#define	kb_F8		15+0x80
#define	kb_F9		16+0x80
#define	kb_F10		17+0x80
#define	kb_F11		18+0x80
#define	kb_F12		19+0x80

#define	kb_Pause	20+0x80
