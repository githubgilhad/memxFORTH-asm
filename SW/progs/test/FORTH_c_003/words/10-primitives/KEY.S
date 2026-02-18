DEFWORD w_KEY,			0,		"KEY",			f_KEY			; ( -- char ) read character from serial

; KEY - read character from serial
; ( -- char )
.section CURRENT_TEXT_SECTION,"ax",@progbits
gfunc f_KEY	; {{{ #
	; Save TOS and call RX0_Read
	PushST TOS		; Push old TOS (if any)
	call RX0_Read
	mov TOS_lo, Cpar1_lo
;	mov TOS_hi, Cpar1_hi
	clr TOS_hi
	clr TOS_hlo		; Clear high byte (24-bit value)
;;	tst TOS_lo
;; 	breq 2f
;; 	ldi Cpar1_lo, 10
;; 	call TX0_Write
;; 	mov Cpar1_lo, TOS_lo
;; 	call TX0_Write
;; 	ldi Cpar1_lo, 32
;; 	call TX0_Write
;; 2:
	jmp NEXT
	; }}}

