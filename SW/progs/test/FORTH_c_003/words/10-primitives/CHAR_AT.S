DEFWORD w_char_at,		0,	"char_at",		f_char_at	// ( addr -- byte ) fetch byte from address

; C@ - fetch byte from address
; ( addr -- byte )
.section CURRENT_TEXT_SECTION,"ax",@progbits
.global f_char_at
f_char_at:	; {{{ #
	Set3 Zx, TOS
	call B1at
	mov TOS_lo, Parsx_lo
	clr TOS_hi
	clr TOS_hlo
	rjmp NEXT
	; }}}
