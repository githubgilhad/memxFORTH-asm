DEFWORD w_dup,		0,	"dup",		f_dup	// ( a -- a a ) duplicate top of stack

; DUP - duplicate top of stack
; ( a -- a a )
.section CURRENT_TEXT_SECTION,"ax",@progbits
.global f_dup
f_dup:	; {{{ #
	PushST TOS
	rjmp NEXT
	; }}}

