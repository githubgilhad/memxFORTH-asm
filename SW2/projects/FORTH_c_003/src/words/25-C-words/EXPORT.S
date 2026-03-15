; .. vim: ft=asm showbreak=--»\  noexpandtab fileencoding=utf-8 nomodified   wrap textwidth=0 foldmethod=marker foldmarker={{{,}}} foldcolumn=4 ruler showcmd lcs=tab\:|- list tabstop=8 noexpandtab nosmarttab softtabstop=0 shiftwidth=0 linebreak


DEFWORD w_EXPORT,		0,		"EXPORT",		f_EXPORT		; ( xt --  ) exports word [xxxx]
DEFWORD w_SHOW,			0,		"SHOW",			f_SHOW			; ( xt --  ) shows word [xxxx]

.section CURRENT_TEXT_SECTION,"ax",@progbits
gfunc f_EXPORT	; {{{ #
	PUSH_R0_R31
	Set3	Cpar2,Cpar1_lo,TOS
	mov	Cpar1_hi, r1
	call	C_export
	POP_R0_R31
	PopST	TOS
	rjmp NEXT
; }}}
gfunc f_SHOW	; {{{ #
	PUSH_R0_R31
	Set3	Cpar2,Cpar1_lo,TOS
	mov	Cpar1_hi, r1
	call	C_show
	POP_R0_R31
	PopST	TOS
	rjmp NEXT
; }}}



