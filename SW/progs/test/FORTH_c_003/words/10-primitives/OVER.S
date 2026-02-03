DEFWORD w_OVER,			0,		"OVER",			f_OVER			; ( a b -- a b a ) copy second stack item to top

; OVER - copy second stack item to top
; ( a b -- a b a )
.section CURRENT_TEXT_SECTION,"ax",@progbits
gfunc f_OVER	; {{{ #
	ReadST_N 0, Parsx   ; read (a)
	PushST TOS		; Push TOS (b) to stack
	Set3 TOS, Parsx		; Set TOS to (a)
	rjmp NEXT
	; }}}

; https://forth-standard.org/standard/core/OVER
; 
; 6.1.1990 OVER CORE
; ( x1 x2 -- x1 x2 x1 )
; 
; Place a copy of x1 on top of the stack.
; 
