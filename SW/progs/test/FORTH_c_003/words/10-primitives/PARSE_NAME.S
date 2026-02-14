; .. vim: ft=asm showbreak=--»\  noexpandtab fileencoding=utf-8 nomodified   wrap textwidth=0 foldmethod=marker foldmarker={{{,}}} foldcolumn=4 ruler showcmd lcs=tab\:|- list tabstop=8 noexpandtab nosmarttab softtabstop=0 shiftwidth=0 linebreak  


DEFWORD w_PARSE_NAME,		0,		"PARSE-NAME",		f_PARSE_NAME		; ( -- c-address u ) parse name from TIB [xxxx]

#define t_max r20, r21
#define t_in r22, r23


.section CURRENT_TEXT_SECTION,"ax",@progbits
gfunc func_PARSE_NAME	; {{{ #
	PushST	TOS
	mov	r0,r1
	inc	r0		; r0 = 1
	TCB_member	TCB_TIB_len   ; #TIB
		ld r20, Z+
		ld r21, Z+
	TCB_member	TCB_TIB_cur   ; >IN 
		ld r22, Z+
		ld r23, Z+
	TCB_member	TCB_TIB       ;  TIB
		movw XL, ZL
		;
		add XL, r22
		adc XH, r23
		;
		ZERO	TOS
		; search start of word
.f_PARSE_NAME.loop1:
		Cmp2	t_in, t_max
		breq	.f_PARSE_NAME.loop1.end
		Add21	t_in, r0	; >IN move, we consume the char
;		Add31	TOS,r0
		ld	Tx, X+
		cpi	Tx, ' ' + 1
		brsh	.f_PARSE_NAME.found_start       ; c > ' '
		rjmp	.f_PARSE_NAME.loop1
.f_PARSE_NAME.loop1.end:
	PushST	TOS	; do not care
	rjmp .f_PARSE_NAME.end
.f_PARSE_NAME.found_start:
		movw	r24, XL
		Sub21	r24,r25, r0
		ldi	Tx, 0x80
		PushST	r24,r25, Tx
		Add31	TOS,r0
.f_PARSE_NAME.loop2:
		Cmp2	t_in, t_max
		breq	.f_PARSE_NAME.end
		Add21	t_in, r0
		ld	Tx, X+
		cpi	Tx, ' ' + 1
		brlo	.f_PARSE_NAME.end       ; c <= ' '
		Add31	TOS,r0
		rjmp	.f_PARSE_NAME.loop2
		
.f_PARSE_NAME.end:
	TCB_member	TCB_TIB_cur
		st	Z+, r22
		st	Z+, r23
	ret
; }}}
gfunc f_PARSE_NAME	; {{{ #
	call func_PARSE_NAME
	jmp NEXT
; }}}


