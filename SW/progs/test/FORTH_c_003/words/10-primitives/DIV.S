DEFWORD w_div,		0,	"div",		f_div	// ( a b -- a/b ) divide second by top

; / - divide second by top
; ( a b -- a/b )
; Full 24-bit unsigned division: Parsx / TOS -> TOS
.section CURRENT_TEXT_SECTION,"ax",@progbits
.global f_div
f_div:	; {{{ #
	PopST Parsx		; Pop dividend (a) to Parsx
	
	; Check for division by zero
	tst TOS_lo
	brne f_div.not_zero
	tst TOS_hi
	brne f_div.not_zero
	tst TOS_hlo
	brne f_div.not_zero
	; Division by zero - set result to maximum
	ser r21
	mov TOS_lo, r21
	mov TOS_hi, r21
	mov TOS_hlo, r21
	rjmp NEXT
	
f_div.not_zero:
	; Save registers
	push r16
	push r17
	push r18
	push r19
	push r20
	push r21
	push r22
	
	; Initialize quotient to 0
	clr r16		; quotient_lo
	clr r17		; quotient_hi
	clr r18		; quotient_hlo
	
	; Initialize remainder to dividend
	mov r19, Parsx_lo	; remainder_lo
	mov r20, Parsx_hi	; remainder_hi
	mov r21, Parsx_hlo	; remainder_hlo
	
	; 24-bit division using shift and subtract algorithm
	; We'll do 24 iterations (one per bit)
	ldi r22, 24		; counter
	
f_div.loop:
	; Shift quotient left
	lsl r16
	rol r17
	rol r18
	
	; Shift remainder left
	lsl r19
	rol r20
	rol r21
	
	; Compare remainder with divisor
	cp r19, TOS_lo
	cpc r20, TOS_hi
	cpc r21, TOS_hlo
	brlo f_div.skip	; remainder < divisor, skip
	
	; Subtract divisor from remainder
	sub r19, TOS_lo
	sbc r20, TOS_hi
	sbc r21, TOS_hlo
	
	; Set least significant bit of quotient
	ori r16, 1
	
f_div.skip:
	dec r22
	brne f_div.loop
	
	; Move quotient to TOS
	mov TOS_lo, r16
	mov TOS_hi, r17
	mov TOS_hlo, r18
	
	; Restore registers
	pop r22
	pop r21
	pop r20
	pop r19
	pop r18
	pop r17
	pop r16
	rjmp NEXT
	; }}}

