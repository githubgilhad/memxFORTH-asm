; .. vim: ft=asm showbreak=--»\  noexpandtab fileencoding=utf-8 nomodified   wrap textwidth=0 foldmethod=marker foldmarker={{{,}}} foldcolumn=4 ruler showcmd lcs=tab\:|- list tabstop=8 noexpandtab nosmarttab softtabstop=0 shiftwidth=0 linebreak  tags=./tags;,tags; 


DEFWORD w_ABS,		0,		"ABS",		f_ABS		; ( x -- |x| ) absolute value
DEFWORD w_NEG,		0,		"NEG",		f_NEG		; ( x -- -x ) negation

.section CURRENT_TEXT_SECTION,"ax",@progbits
gfunc f_ABS	; {{{
	mov	Tx,	r1
	dec	Tx
	sbrs	TOS_hlo,	7
	jmp NEXT
	com	TOS_hlo
	com	TOS_hi
	neg	TOS_lo
	sbc	TOS_hi, 	Tx
	sbc	TOS_hlo,	Tx
	jmp NEXT

; }}}
gfunc f_NEG	; {{{
	mov	Tx,	r1
	dec	Tx
	com	TOS_hlo
	com	TOS_hi
	neg	TOS_lo
	sbc	TOS_hi, 	Tx
	sbc	TOS_hlo,	Tx
	jmp NEXT

; }}}



