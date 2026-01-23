DEFWORD w_drop,		0,	"drop",		f_drop	// ( a -- ) drop top of stack

; DROP - drop top of stack
; ( a -- )
.section CURRENT_TEXT_SECTION,"ax",@progbits
.global f_drop
f_drop:	; {{{ #
	PopST TOS
	rjmp NEXT
	; }}}

