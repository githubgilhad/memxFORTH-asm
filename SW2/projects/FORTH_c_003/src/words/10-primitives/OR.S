; .. vim: ft=asm showbreak=--»\  noexpandtab fileencoding=utf-8 nomodified   wrap textwidth=0 foldmethod=marker foldmarker={{{,}}} foldcolumn=4 ruler showcmd lcs=tab\:|- list tabstop=8 noexpandtab nosmarttab softtabstop=0 shiftwidth=0 linebreak  

DEFWORD w_OR,			0,		"OR",			f_OR			; ( a b -- a|b ) bitwise OR of two stack items
DEFWORD w_LOR,			0,		"||",			f_LOR			; ( a b -- a||b ) logical OR of two stack items

.section CURRENT_TEXT_SECTION,"ax",@progbits
gfunc f_OR	; {{{ #
	PopST Parsx		; Pop second item to Parsx
	or TOS_lo, Parsx_lo
	or TOS_hi, Parsx_hi
	or TOS_hlo, Parsx_hlo
	jmp NEXT
	; }}}
gfunc f_LOR	; {{{ #
	PopST Parsx		; Pop second item to Parsx
	or	Parsx_lo,	TOS_lo
	brne	2f				; nonzero - probably something will be in low bytes and then we know the result fast
	or	Parsx_lo, 	TOS_hi
	or	Parsx_lo, 	TOS_hlo
	or	Parsx_lo,	Parsx_hi
	or	Parsx_lo,	Parsx_hlo	; NOS = 0 => 0
	breq	3f
2:
	ldi	Parsx_lo,	0xFF
3:
	Set3	TOS, Parsx_lo,Parsx_lo,Parsx_lo
	jmp NEXT
	; }}}

; https://forth-storard.org/storard/core/OR
; 
; OR CORE
; ( x1 x2 -- x3 )
; 
; x3 is the bit-by-bit logical "or" of x1 with x2. 
