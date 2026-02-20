; .. vim: ft=asm showbreak=--»\  noexpandtab fileencoding=utf-8 nomodified   wrap textwidth=0 foldmethod=marker foldmarker={{{,}}} foldcolumn=4 ruler showcmd lcs=tab\:|- list tabstop=8 noexpandtab nosmarttab softtabstop=0 shiftwidth=0 linebreak  


DEFWORD w_DUMP,			0,		"DUMP",			f_DUMP			; ( addr  --  ) dump memory around addr  [----]

.section CURRENT_TEXT_SECTION,"ax",@progbits
gfunc f_DUMP	; {{{ # FIXME
	PUSH_R0_R31
	Set3	Cpar2,Cpar1_lo,TOS
	mov	Cpar1_hi, r1
	call	C_dump
	POP_R0_R31
	PopST	TOS
	jmp NEXT
; }}}



