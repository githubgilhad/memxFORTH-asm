; .. vim: ft=asm showbreak=--»\  noexpandtab fileencoding=utf-8 nomodified   wrap textwidth=0 foldmethod=marker foldmarker={{{,}}} foldcolumn=4 ruler showcmd lcs=tab\:|- list tabstop=8 noexpandtab nosmarttab softtabstop=0 shiftwidth=0 linebreak  
; ; 
; ; DEFWORD w_TEST,			0,		"TEST",			f_docol, yes		; ( -- 0x42 ) // just test
; ; 	P24 w_LIT3_cw
; ; 	.byte 0x21,0,0
; ; 	P24 w_DUP_cw
; ; 	P24 w_plus_cw
; ; 	P24 w_exit_cw



; ; DEFWORD w_TEST,			0,		"TEST",			f_docol, yes		; ( -- ) // just test
; ; 
; ; ;	P24 w_CLS_cw
; ; 	
; ; 	P24 w_LIT3_cw
; ; 	P24 0x123456
; ; 	P24 w_LIT3_cw
; ; 	P24 w_dot_hex_cw
; ; 	P24 w_EXECUTE_cw
; ; 
; ; 	P24 w_LIT1_cw
; ; 	.byte 10
; ; 	P24 w_zero_cw
; ; 	P24 w_2toR_cw
; ; 2:
; ; 	P24 w_I_cw
; ; 	P24 w_dot_hex_cw
; ; 	P24 w_LOOP_cw
; ; 	P24 2b - .
; ; 	
; ; 	P24 w_exit_cw



DEFWORD w_TEST,			0,		"TEST",			f_docol, yes		; ( -- ) // just test

	P24 w_LIT3_cw
	P24 2f
	P24 w_COUNT_cw
	P24 w_CERROR_cw
	
	P24 w_LIT3_cw
	P24 10
	P24 w_LIT3_cw
	P24 20
	P24 w_less_cw
	P24 w_dot_hex_cw
	P24 w_KEYpress_cw
	P24 w_exit_cw
2:
	.byte lo8(3f - . - 1 )
	.ascii "### Hello World ###"
3:



DEFWORD w_TESTc,		0,		"TESTc",		f_TESTc			; ( -- ) // just test

.section CURRENT_TEXT_SECTION,"ax",@progbits
gfunc f_TESTc	; {{{ # FIXME
	PUSH_R0_R31
	Set3	Cpar2,Cpar1_lo,TOS
	mov	Cpar1_hi, r1
	call	C_test
	POP_R0_R31
	jmp NEXT
; }}}
