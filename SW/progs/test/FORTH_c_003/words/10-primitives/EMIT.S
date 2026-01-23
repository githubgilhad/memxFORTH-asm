DEFWORD w_emit,		0,	"emit",		f_emit	// ( char -- ) output character to serial

; EMIT - output character to serial
; ( char -- )
.section CURRENT_TEXT_SECTION,"ax",@progbits
.global f_emit
f_emit:	; {{{ #
	mov r24, TOS_lo		; Move char to r24 for TX0_Write
	call TX0_Write
	PopST TOS		; Pop new TOS (was char, now get next item)
	rjmp NEXT
	; }}}

