DEFWORD w_SWAP,			0,		"SWAP",			f_SWAP			; ( a b -- b a ) SWAP top two stack items
DEFWORD w_SWAP2,		0,		"SWAP2",		f_SWAP2			; ( a b c d -- c d b a ) SWAP top two pairs of stack items

; SWAP - SWAP top two stack items
; ( a b -- b a )
.section CURRENT_TEXT_SECTION,"ax",@progbits
gfunc f_SWAP	; {{{ #
	Set3 Parsx, TOS ; TOS (b) -> Parsx
	ReadST_N_x 0, TOS ; a-> TOS
	WriteST_N_x 0, Parsx  ; b -> stack
	jmp NEXT
	; }}}
gfunc f_SWAP2	; {{{ #
	Set3 Parsx, TOS
	ReadST_N_x 1, TOS
	WriteST_N_x 1, Parsx

	ReadST_N_x 0, Temp
	ReadST_N_x 2, DT
	WriteST_N_x 2, Temp
	WriteST_N_x 0, DT
	
	jmp NEXT
	; }}}

