DEFWORD w_minus,		0,		"-",			f_minus			; ( a b -- a-b ) subtract top from second

; - - subtract top from second
; ( a b -- a-b )
.section CURRENT_TEXT_SECTION,"ax",@progbits
gfunc f_minus	; {{{ #
	PopST Parsx		; Pop second item to Parsx
	Sub3 Parsx, TOS
	Set3 TOS, Parsx
	rjmp NEXT
	; }}}

