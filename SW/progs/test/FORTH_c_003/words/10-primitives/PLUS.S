DEFWORD w_plus,			0,		"+",			f_plus			; ( a b -- a+b ) add top two stack items

; + - add top two stack items
; ( a b -- a+b )
.section CURRENT_TEXT_SECTION,"ax",@progbits
gfunc f_plus	; {{{ #
	PopST Parsx		; Pop second item to Parsx
	add TOS_lo, Parsx_lo
	adc TOS_hi, Parsx_hi
	adc TOS_hlo, Parsx_hlo
	rjmp NEXT
	; }}}


; https://forth-standard.org/standard/core/Plus
; 
; 6.1.0120 + plus CORE
; ( n1 | u1 n2 | u2 -- n3 | u3 )
; 
; Add n2 | u2 to n1 | u1, giving the sum n3 | u3. 
