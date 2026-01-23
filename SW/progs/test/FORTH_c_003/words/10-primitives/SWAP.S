DEFWORD w_swap,		0,	"swap",		f_swap	// ( a b -- b a ) swap top two stack items

; SWAP - swap top two stack items
; ( a b -- b a )
.section CURRENT_TEXT_SECTION,"ax",@progbits
.global f_swap
f_swap:	; {{{ #
	Set3 Parsx, TOS ; TOS (b) -> Parsx
	ReadST_N 0, TOS ; a-> TOS
	WriteST_N 0, Parsx  ; b -> stack
	rjmp NEXT
	; }}}

