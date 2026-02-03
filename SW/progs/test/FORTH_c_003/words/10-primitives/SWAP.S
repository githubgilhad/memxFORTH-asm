DEFWORD w_SWAP,			0,		"SWAP",			f_SWAP			; ( a b -- b a ) SWAP top two stack items

; SWAP - SWAP top two stack items
; ( a b -- b a )
.section CURRENT_TEXT_SECTION,"ax",@progbits
gfunc f_SWAP	; {{{ #
	Set3 Parsx, TOS ; TOS (b) -> Parsx
	ReadST_N 0, TOS ; a-> TOS
	WriteST_N 0, Parsx  ; b -> stack
	rjmp NEXT
	; }}}

