DEFWORD w_EMIT,			0,		"EMIT",			f_EMIT			; ( char -- ) output character to serial

; EMIT - output character to serial
; ( char -- )
.section CURRENT_TEXT_SECTION,"ax",@progbits
gfunc f_EMIT	; {{{ #
	mov r24, TOS_lo		; Move char to r24 for TX0_Write
	call TX0_Write
	PopST TOS		; Pop new TOS (was char, now get next item)
	rjmp NEXT
	; }}}

