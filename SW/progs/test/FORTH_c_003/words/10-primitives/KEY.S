DEFWORD w_KEY,			0,		"KEY",			f_KEY			; ( -- char ) read character from serial

; KEY - read character from serial
; ( -- char )
.section CURRENT_TEXT_SECTION,"ax",@progbits
gfunc f_KEY	; {{{ #
	; Save TOS and call RX0_Read
	PushST TOS		; Push old TOS (if any)
	call RX0_Read
	mov TOS_lo, r24
	mov TOS_hi, r25
	clr TOS_hlo		; Clear high byte (24-bit value)
	rjmp NEXT
	; }}}

