; .. vim: ft=asm showbreak=--»\  noexpandtab fileencoding=utf-8 nomodified   wrap textwidth=0 foldmethod=marker foldmarker={{{,}}} foldcolumn=4 ruler showcmd lcs=tab\:|- list tabstop=8 noexpandtab nosmarttab softtabstop=0 shiftwidth=0 linebreak  


DEFWORD w_DOT_S,		0,		".S",			f_DOT_S			; (  --  ) list data Stack [xxxx]
DEFWORD w_DOT_D,		0,		".D",			f_DOT_S			; (  --  ) list data D stack [xxxx]
DEFWORD w_DOT_R,		0,		".R",			f_DOT_R			; (  --  ) list return R stack [xxxx]
DEFWORD w_DOT_L,		0,		".L",			f_DOT_L			; (  --  ) list secondary L stack [xxxx]

#define dst_ptr XL,XH

.section CURRENT_TEXT_SECTION,"ax",@progbits
gfunc f_DOT_S	; {{{ #  
	PUSH_R2_R17
	TCB_member	TCB_DataStackLast
		RB2at
	Set2		dst_ptr, Parsx2
	ldi		Tx, 3
	Sub21		dst_ptr, Tx
	Cmp2		dst_ptr, DST
	brlo	.L_f_DOT_S__noTOS
	breq	.L_f_DOT_S__end
2:
	ld	r24, -X
	call VGA0_WriteHex8
	ld	r24, -X
	call VGA0_WriteHex8
	ld	r24, -X
	call VGA0_WriteHex8
	ldi	r24, ' '
	call VGA0_Write
	Cmp2	DST,dst_ptr
	brlo	2b ; branch if DST< dst_ptr
.L_f_DOT_S__end:
	Set3	Parsx,TOS
	call VGA0_WriteHex24
	ldi	r24, ' '
	call VGA0_Write
.L_f_DOT_S__noTOS:
	POP_R2_R17
	jmp NEXT
; }}}
gfunc f_DOT_R	; {{{ #  
	PUSH_R2_R17
	TCB_member	TCB_ReturnStackLast
		RB2at
	Set2		dst_ptr, Parsx2
;	ldi		Tx, 4
;	Sub21		dst_ptr, Tx
	Cmp2		RST, dst_ptr	; RST - dst_ptr
	brsh	.L_f_DOT_R__end		; branch if RST was Same or Higher (stack empty/underflown)
2:
	ld	r24, -X
	call VGA0_WriteHex8
	ld	r24, -X
	call VGA0_WriteHex8
	ld	r24, -X
	call VGA0_WriteHex8
	ldi	r24, ' '
	call VGA0_Write
	Cmp2	RST,dst_ptr
	brlo	2b ; branch if DST< dst_ptr
.L_f_DOT_R__end:
	POP_R2_R17
	jmp NEXT
; }}}
gfunc f_DOT_L	; {{{ #  
	PUSH_R2_R17
	TCB_member	TCB_LStackLast
		RB2at
	Set2		dst_ptr, Parsx2
;	ldi		Tx, 3
;	Sub21		dst_ptr, Tx
	Cmp2		LST, dst_ptr	; LST - dst_ptr
	brsh	.L_f_DOT_L__end		; branch if LST was Same or Higher (stack empty/underflown)
2:
	ld	r24, -X
	call VGA0_WriteHex8
	ld	r24, -X
	call VGA0_WriteHex8
	ld	r24, -X
	call VGA0_WriteHex8
	ldi	r24, ' '
	call VGA0_Write
	Cmp2	LST,dst_ptr
	brlo	2b ; branch if LST< dst_ptr
.L_f_DOT_L__end:
	POP_R2_R17
	jmp NEXT
; }}}

#undef dst_ptr

