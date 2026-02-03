; .. vim: ft=asm showbreak=--»\  noexpandtab fileencoding=utf-8 nomodified   wrap textwidth=0 foldmethod=marker foldmarker={{{,}}} foldcolumn=4 ruler showcmd lcs=tab\:|- list tabstop=8 noexpandtab nosmarttab softtabstop=0 shiftwidth=0 linebreak  

DEFWORD w_AND,			0,		"AND",			f_AND			; ( a b -- a&b ) bitwise AND of two stack items

.section CURRENT_TEXT_SECTION,"ax",@progbits
gfunc f_AND	; {{{ #
	PopST Parsx		; Pop second item to Parsx
	and TOS_lo, Parsx_lo
	and TOS_hi, Parsx_hi
	and TOS_hlo, Parsx_hlo
	rjmp NEXT
	; }}}

; https://forth-standard.org/standard/core/AND
; 
; 6.1.0720 AND CORE
; ( x1 x2 -- x3 )
; 
; x3 is the bit-by-bit logical "and" of x1 with x2. 
