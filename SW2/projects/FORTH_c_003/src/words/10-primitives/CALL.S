; .. vim: ft=asm showbreak=--»\  noexpandtab fileencoding=utf-8 nomodified   wrap textwidth=0 foldmethod=marker foldmarker={{{,}}} foldcolumn=4 ruler showcmd lcs=tab\:|- list tabstop=8 noexpandtab nosmarttab softtabstop=0 shiftwidth=0 linebreak  tags=./tags;,tags; 


DEFWORD w_CALL,			0,		"CALL",			f_CALL			; ( a addr  -- a b ) call C func on addr with param a, save result to b

.section CURRENT_TEXT_SECTION,"ax",@progbits
gfunc f_CALL	; {{{ # FIXME
	ReadR_N_x	0,	Cpar1, Tx
	Set2	Zx2,TOS2
	icall
	Set3	TOS, Cpar1,r1

	jmp NEXT
; }}}



