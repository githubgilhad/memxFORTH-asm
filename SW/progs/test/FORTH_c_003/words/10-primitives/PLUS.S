DEFWORD w_plus,		0,	"plus",		f_plus	// ( a b -- a+b ) add top two stack items

; + - add top two stack items
; ( a b -- a+b )
.section CURRENT_TEXT_SECTION,"ax",@progbits
.global f_plus
f_plus:	; {{{ #
	PopST Parsx		; Pop second item to Parsx
	add TOS_lo, Parsx_lo
	adc TOS_hi, Parsx_hi
	adc TOS_hlo, Parsx_hlo
	rjmp NEXT
	; }}}

