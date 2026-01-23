DEFWORD w_over,		0,	"over",		f_over	// ( a b -- a b a ) copy second stack item to top

; OVER - copy second stack item to top
; ( a b -- a b a )
.section CURRENT_TEXT_SECTION,"ax",@progbits
.global f_over
f_over:	; {{{ #
	ReadST_N 0, Parsx   ; read (a)
	PushST TOS		; Push TOS (b) to stack
	Set3 TOS, Parsx		; Set TOS to (a)
	rjmp NEXT
	; }}}

