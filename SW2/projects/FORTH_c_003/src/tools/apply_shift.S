; .. vim: ft=asm showbreak=--»\  noexpandtab fileencoding=utf-8 nomodified   wrap textwidth=0 foldmethod=marker foldmarker={{{,}}} foldcolumn=4 ruler showcmd lcs=tab\:|- list tabstop=8 noexpandtab nosmarttab softtabstop=0 shiftwidth=0 linebreak  tags=./tags;,tags; 
#define __SFR_OFFSET 0x00		// set the Special Function Register Offset from 0x20 to 0x00 in order to use AVR PORT definitions
#include <avr/io.h>

#include "FORTH-Defines.h"
#include "FORTH-Macros.h"

.section .text.LIBS.main
obj normal
	.asciz "1234567890-=[];,./\\'"
obj shifted
	.asciz "!@#$%^&*()_+{}:<>?|\""
gfunc apply_shift_s	; {{{ uint8_t apply_shift(uint8_t c); // shift for other chars than a..z
	push	ZL
	push	ZH
	push	Z_hlo
	in	Z_hlo,	RAMPZ
	push	Z_hlo
	push Tx
	push Ty
	Ldi3	Zx,	normal
	out	RAMPZ,	Z_hlo
	clr	Ty
1:
	elpm	Tx,	Z+
	inc	Ty
	tst	Tx
	breq	2f
	cp	Tx,	Cpar1_lo
	brne	1b
	; found
	dec	Ty
	Ldi3	Zx,	shifted
	out	RAMPZ,	Z_hlo
	add	ZL,	Ty
	adc	ZH,	r1
	elpm	Cpar1_lo,	Z
2:
	pop	Ty
	pop	Tx
	pop	Z_hlo
	out	RAMPZ,	Z_hlo
	pop	Z_hlo
	pop	ZH
	pop	ZL
	ret
;	}}}

