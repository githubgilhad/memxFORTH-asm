; .. vim: ft=asm showbreak=--»\  noexpandtab fileencoding=utf-8 nomodified   wrap textwidth=0 foldmethod=marker foldmarker={{{,}}} foldcolumn=4 ruler showcmd lcs=tab\:|- list tabstop=8 noexpandtab nosmarttab softtabstop=0 shiftwidth=0 linebreak  


DEFWORD w_DOT_S,		0,		".S",		f_DOT_S		; (  --  ) list data stack [xxxx]

#define dst_ptr XL,XH

.section CURRENT_TEXT_SECTION,"ax",@progbits
gfunc f_DOT_S	; {{{ #  FIXME
	PUSH_R2_R17
	TCB_member	TCB_DataStackLast
		RB3at
	Set2		dst_ptr, Parsx2
	ldi		Tx, 6
	Sub21		dst_ptr, Tx
	Cmp2		dst_ptr, DST
	brlo	.f_DOT_S.noTOS
	breq	.f_DOT_S.end
2:
	ld	r24, -X
	call TX0_WriteHex8
	ld	r24, -X
	call TX0_WriteHex8
	ld	r24, -X
	call TX0_WriteHex8
	ldi	r24, ' '
	call TX0_Write
	Cmp2	DST,dst_ptr
	brlo	2b ; branch if DST< dst_ptr
.f_DOT_S.end:
	Set3	Parsx,TOS
	call TX0_WriteHex24
	ldi	r24, ' '
	call TX0_Write
.f_DOT_S.noTOS:
	POP_R2_R17
	jmp NEXT
; }}}

#undef dst_ptr

