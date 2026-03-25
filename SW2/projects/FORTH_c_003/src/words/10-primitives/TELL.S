; .. vim: ft=asm showbreak=--»\  noexpandtab fileencoding=utf-8 nomodified   wrap textwidth=0 foldmethod=marker foldmarker={{{,}}} foldcolumn=4 ruler showcmd lcs=tab\:|- list tabstop=8 noexpandtab nosmarttab softtabstop=0 shiftwidth=0 linebreak  tags=./tags;,tags; 


DEFWORD w_TELL,			0,		"TELL",			f_TELL			; ( addr len -- ) prints out string [----]

.section CURRENT_TEXT_SECTION,"ax",@progbits
gfunc f_TELL	; {{{ 
	PopST	DT
	push	YL
	push	YH
	movw	YL,	XL
2:
	tst	TOS_lo
	breq	3f
	dec	TOS_lo
	ld	Cpar1_lo, Y+
	call_VT_member_C	VT_write_char
	rjmp	2b
3:
	pop	YH
	pop	YL
	PopST	TOS
	jmp NEXT
; }}}



