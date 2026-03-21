DEFWORD w_DIVMOD,		0,		"DIVMOD",		f_DIVMOD		// ( a b -- mod div ) divide second by top, get remainder and quotient [xxxx]
DEFWORD w_DIV,			0,		"/",			f_DIV			// ( a b -- div ) divide second by top, get quotient [xxxx]
DEFWORD w_MOD,			0,		"%",			f_MOD			// ( a b -- mod ) divide second by top, get remainder (modulo)  [xxxx]


#define range (16,18)
.section CURRENT_TEXT_SECTION,"ax",@progbits
gfunc func_DIVMOD	; {{{
	PUSHXr(range)	; r0,r1 destroyed too

	PopST	Parsx
	Set3	Zx,Parsx
			; r30:r31:r25 = dividend = Zx
			; r4:r5:r6    = divisor  = TOS
			; result:
			; r18:r19:r20 = quotient
			; r21:r22:r23 = remainder


;--------------------------------
; check division by zero
;--------------------------------

	mov r16,r4
	or  r16,r5
	or  r16,r6
	brne div24_start

			; divisor == 0 => FFFF rem. all
	PushST Parsx
	ser	Tx
	Set3	TOS, Tx,Tx,Tx
	ret

;--------------------------------
div24_start:

	; quotient = 0
	clr r18
	clr r19
	clr r20

	; remainder = 0
	clr r21
	clr r22
	clr r23

	; loop counter
	ldi r17,24

div24_loop:		; {{{

	; shift dividend left -> carry
	lsl r30
	rol r31
	rol r25

	; shift remainder left + bring bit
	rol r21
	rol r22
	rol r23

	; remainder - divisor
	mov r0,r21
	mov r1,r22
	mov r16,r23

	sub r0,r4
	sbc r1,r5
	sbc r16,r6

	brcs div24_skip

	; remainder >= divisor
	mov r21,r0
	mov r22,r1
	mov r23,r16

	; quotient |= 1
	lsl r18
	rol r19
	rol r20
	ori r18,1
	rjmp div24_next

div24_skip:

	; quotient <<= 1
	lsl r18
	rol r19
	rol r20

div24_next:

	dec r17
	brne div24_loop		; }}}

	clr	r1
	PushST	r21, r22, r23		; r21:r22:r23 = remainder
	Set3	TOS, r18,r19,r20	; r18:r19:r20 = quotient
	POPXr(range)
	ret
; }}}
gfunc f_DIVMOD		; {{{
	call	func_DIVMOD
	jmp	NEXT
; }}}
gfunc f_DIV		; {{{
	call	func_DIVMOD
	PopST	Temp
	jmp	NEXT
; }}}
gfunc f_MOD		; {{{
	call	func_DIVMOD
	PopST	TOS
	jmp	NEXT
; }}}

#undef range
