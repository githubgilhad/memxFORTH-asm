DEFWORD w_KEY,			0,		"KEY",			f_KEY			; ( -- char ) read character from serial

; KEY - read character from serial
; ( -- char )
.section CURRENT_TEXT_SECTION,"ax",@progbits
gfunc f_KEY	; {{{ #
	; Save TOS and call RX0_Read
	PushST TOS		; Push old TOS (if any)
	call RX0_Read
	mov TOS_lo, r24
;	mov TOS_hi, r25
	clr TOS_hi
	clr TOS_hlo		; Clear high byte (24-bit value)
;;	tst TOS_lo
;; 	breq 2f
;; 	ldi r24, 10
;; 	call TX0_Write
;; 	mov r24, TOS_lo
;; 	call TX0_Write
;; 	ldi r24,32
;; 	call TX0_Write
;; 2:
	rjmp NEXT
	; }}}

