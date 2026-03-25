; .. vim: ft=asm showbreak=--»\  noexpandtab fileencoding=utf-8 nomodified   wrap textwidth=0 foldmethod=marker foldmarker={{{,}}} foldcolumn=4 ruler showcmd lcs=tab\:|- list tabstop=8 noexpandtab nosmarttab softtabstop=0 shiftwidth=0 linebreak  tags=./tags;,tags; 


DEFWORD w_COMMENT,		FLG_IMMEDIATE,	"(",			f_COMMENT		; ( "text)"  --  ) skip comment to paired ) [----]

#define cnt r11
#define t_in r14,r15
#define ctx r16,r17
.section CURRENT_TEXT_SECTION,"ax",@progbits
gfunc f_COMMENT	; {{{ 
	push	cnt
	push	r14
	push	r15	; t_in
	push	r16
	push	r17	; ctx
	mov	r0,r1
	inc	r0		; r0 = 1 for incrementing pairs of lower registers
	mov	cnt,	r0	; name is the first (
	
	Ldi2i	t_in,	scratch_byte
	
	TCB_memberR2	TCB_GETC_CTX, ctx	; CTX for getC
	;					; 
		2:				; loop to skip comment {{{
		Set2	Cpar1, ctx
		Set2	Cpar2, t_in
		call	C_getc
		tst	Cpar1_lo	; GETC_OK=0
		breq 3f
; nop
; nop
			call func_yield
			rjmp 2b
		3:
		Set2	Zx2,t_in
		ld	Tx, Z+
		cpi	Tx, '('
		brne	4f
			inc	cnt
		4:
		cpi	Tx, ')'
		brne	4f
			dec	cnt
		4:
		tst	cnt
		brne 2b				; }}}
		
	pop	r17	; ctx
	pop	r16
	pop	r15	; t_in
	pop	r14
	pop	cnt
	jmp NEXT
; }}}


#undef cnt
#undef t_in
#undef ctx

