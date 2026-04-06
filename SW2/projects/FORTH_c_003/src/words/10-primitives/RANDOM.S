; .. vim: ft=asm showbreak=--»\  noexpandtab fileencoding=utf-8 nomodified   wrap textwidth=0 foldmethod=marker foldmarker={{{,}}} foldcolumn=4 ruler showcmd lcs=tab\:|- list tabstop=8 noexpandtab nosmarttab softtabstop=0 shiftwidth=0 linebreak  tags=./tags;,tags; 


DEFWORD w_RANDOM,		0,		"RANDOM",		f_RANDOM		; ( max -- rnd ) rnd 0..(max -1)

.section CURRENT_TEXT_SECTION,"ax",@progbits
gfunc f_RANDOM	; {{{ 
	Set3	Cpar2, Cpar1_lo 	TOS
	mov	Cpar1_hi,		r1
	call	C_RANDOM
	Set3	TOS, 		Cpar2, Cpar1_lo
	jmp NEXT
; }}}



