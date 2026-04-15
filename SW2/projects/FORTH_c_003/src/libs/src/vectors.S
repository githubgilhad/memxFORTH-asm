; .. vim: ft=asm showbreak=--»\  noexpandtab fileencoding=utf-8 nomodified   wrap textwidth=0 foldmethod=marker foldmarker={{{,}}} foldcolumn=4 ruler showcmd lcs=tab\:|- list tabstop=8 noexpandtab nosmarttab softtabstop=0 shiftwidth=0 linebreak  tags=./tags;,tags; 

/*
	Handle interrupt handlers in crude fast way:
	every handler MUST be set 
		to lower half of FLASH 
		16bit WORD addres
		BEFORE interrupt is enabled
	free handler by assigning EMPTY_HANDLER
	only ZL,ZH and SREG are saved, the rest is on handler itself (read - no C functions!!!)
	
	example.c:
		extern isr_handler asm_function;
		TIMER1_COMPA_vect_handler=asm_function;
	example.S:
		ldi	r24,	lo8(gs(asm_function))
		ldi	r25,	hi8(gs(asm_function))
		st	TIMER1_COMPA_vect_handler, r24
		st	TIMER1_COMPA_vect_handler+1, r25
*/

#define __SFR_OFFSET 0x00		// set the Special Function Register Offset from 0x20 to 0x00 in order to use AVR PORT definitions
#include <avr/io.h>			// include PORTB, DDRD, ... symbols for easier register access
#include "FORTH-Macros.h"

.section .text.vectors

gfunc EMPTY_HANDLER		; just returns
	ret
;
.macro	vector	name, cname	; {{{	16bit word addres handler, use hi8/lo8(gs(function))
.section	.bss.vectors
gobj	\cname\()_handler
	.word 0		; 16bit word address, maybe trampoline
.section	.text.vectors
gfunc \name
	push	ZL
	push	ZH
	in	ZH,	SREG
	push	ZH
;
	lds	ZL,	\cname\()_handler+0
	lds	ZH,	\cname\()_handler+1
	icall
;
	pop	ZH
	out	SREG,	ZH
	pop	ZH
	pop	ZL
	reti
.endm			; }}}

vector	TIMER1_COMPA_vect,	"TIMER1_COMPA_vect"
vector	TIMER3_COMPA_vect,	"TIMER3_COMPA_vect"
vector	TIMER3_COMPC_vect,	"TIMER3_COMPC_vect"

