DEFWORD w_char_store,		0,	"char_store",		f_char_store	// ( byte addr -- ) store byte to address

; C! - store byte to address
; ( byte addr -- )
.section CURRENT_TEXT_SECTION,"ax",@progbits
.global f_char_store
f_char_store:	; {{{ #
	PopST Parsx		; Pop value to Parsx
	Set3 Zx, TOS
	; W1at expects: Zx = address, Parsx_lo = byte to write, ignores Parsx_hi,Parsx_hlo
	call W1at		; Write 1 byte: [Zx] = Parsx_lo, Zx += 1
	PopST TOS		; Pop new TOS (was byte, now get next item)
	rjmp NEXT
	; }}}

