; .. vim: ft=asm showbreak=--»\  noexpandtab fileencoding=utf-8 nomodified   wrap textwidth=0 foldmethod=marker foldmarker={{{,}}} foldcolumn=4 ruler showcmd lcs=tab\:|- list tabstop=8 noexpandtab nosmarttab softtabstop=0 shiftwidth=0 linebreak  tags=./tags;,tags; 


DEFWORD w_TELL,			0,		"TELL",			f_TELL			; ( addr len -- ) prints out string [----]

.section CURRENT_TEXT_SECTION,"ax",@progbits
gfunc f_TELL	; {{{ 
	PopST	DT
	push	DT_lo
	push	DT_hi
	push	DT_hlo
2:
	tst	TOS_lo
	breq	3f
	dec	TOS_lo
	pop	Z_hlo
	pop	Z_hi
	pop	Z_lo
	call	B1at
	push	Z_lo
	push	Z_hi
	push	Z_hlo
	mov	Cpar1_lo, Parsx_lo
	call_VT_member_C	VT_write_char
	rjmp	2b
3:
	pop	Z_hlo
	pop	Z_hi
	pop	Z_lo
	PopST	TOS
	jmp NEXT
; }}}



