DEFWORD w_KEY,			0,		"KEY",			f_KEY			; ( -- 0 | char ) read character from serial (\0 if not avaiable)

; KEY - read character from serial
; ( -- char )
.section CURRENT_TEXT_SECTION,"ax",@progbits
gfunc f_KEY	; {{{ #
	; Save TOS and call RX0_Read
	PushST TOS		; Push old TOS (if any)
	TCB_member TCB_GETC_CTX	; &TCB_GETC_CTX
		RB3at			; state
	Set2 Cpar1, Parsx2	;
	Ldi2 Cpar2, scratch_byte
	call C_getc
	lds TOS_lo, scratch_byte
;	mov TOS_hi, Cpar1_hi
	clr TOS_hi
	clr TOS_hlo		; Clear high byte (24-bit value)
	jmp NEXT
	; }}}
gfunc old_f_KEY	; {{{ #
	; Save TOS and call RX0_Read
	PushST TOS		; Push old TOS (if any)
	call RX0_Read
	mov TOS_lo, Cpar1_lo
;	mov TOS_hi, Cpar1_hi
	clr TOS_hi
	clr TOS_hlo		; Clear high byte (24-bit value)
	jmp NEXT
	; }}}

