DEFWORD w_EMIT,			0,		"EMIT",			f_EMIT			; ( char -- ) output character to serial

; EMIT - output character to serial
; ( char -- )
.section CURRENT_TEXT_SECTION,"ax",@progbits
gfunc f_EMIT	; {{{ #
	mov Cpar1_lo, TOS_lo	; Move char to Cpar1_lo for TX0_Write
	call TX0_Write
	PopST TOS		; Pop new TOS (was char, now get next item)
	jmp NEXT
	; }}}

