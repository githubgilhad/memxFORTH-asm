DEFWORD w_times,	0,	"times",	f_times	// ( a b -- a*b ) multiply top two stack items (24-bit result, may overflow)

; * - multiply top two stack items (24-bit result, may overflow)
; ( a b -- a*b )
; Full 24-bit multiplication: Parsx * TOS -> TOS
.section CURRENT_TEXT_SECTION,"ax",@progbits
.global f_times
f_times:	; {{{ #
	PopST Parsx		; Pop second item (a) to Parsx
	; 24-bit × 24-bit multiplication
	; Result can be up to 48 bits, but we only keep 24 bits
	; Algorithm: (a2 a1 a0) × (b2 b1 b0) = sum of all partial products
	
	; Save registers we'll use
	push r16
	push r17
	push r18
	push r19
	push r20
	
	; Initialize result to 0
	clr r16		; result_lo
	clr r17		; result_hi
	clr r18		; result_hlo
	
	; Multiply Parsx_lo × TOS_lo (low × low)
	mul Parsx_lo, TOS_lo
	mov r16, r0
	mov r17, r1
	
	; Multiply Parsx_lo × TOS_hi (low × mid)
	mul Parsx_lo, TOS_hi
	add r17, r0
	adc r18, r1
	
	; Multiply Parsx_hi × TOS_lo (mid × low)
	mul Parsx_hi, TOS_lo
	add r17, r0
	adc r18, r1
	
	; Multiply Parsx_lo × TOS_hlo (low × high)
	mul Parsx_lo, TOS_hlo
	add r18, r0
	; r1 would go to next byte, ignore for 24-bit result
	
	; Multiply Parsx_hi × TOS_hi (mid × mid)
	mul Parsx_hi, TOS_hi
	add r18, r0
	; r1 would go to next byte, ignore for 24-bit result
	
	; Multiply Parsx_hlo × TOS_lo (high × low)
	mul Parsx_hlo, TOS_lo
	add r18, r0
	; r1 would go to next byte, ignore for 24-bit result
	
	; Move result to TOS (24-bit, truncate if needed)
	mov TOS_lo, r16
	mov TOS_hi, r17
	mov TOS_hlo, r18
	
	; Restore registers
	pop r20
	pop r19
	pop r18
	pop r17
	pop r16
	clr r1
	rjmp NEXT
	; }}}

