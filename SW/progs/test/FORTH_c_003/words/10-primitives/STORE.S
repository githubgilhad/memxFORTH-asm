DEFWORD w_store,		0,		"!",			f_store			; ( value addr -- ) store cell to address

; ! - store cell to address
; ( value addr -- )
.section CURRENT_TEXT_SECTION,"ax",@progbits
gfunc f_store	; {{{ #
	PopST Parsx		; Pop value to Parsx
	Set3 Zx, TOS	; Set address to Zx
	; Store NTOS to address in TOS using W3at
	; W3at expects: Zx = address, Parsx = value to write
	call W3at		; Write 3 bytes: [Zx] = Parsx, Zx += 3
	PopST TOS		; Pop new TOS (was value, now get next item)
	rjmp NEXT
	; }}}

DEFWORD w_char_store,		0,		"C!",			f_char_store		; ( byte addr -- ) store byte to address

; C! - store byte to address
; ( byte addr -- )
.section CURRENT_TEXT_SECTION,"ax",@progbits
gfunc f_char_store	; {{{ #
	PopST Parsx		; Pop value to Parsx
	Set3 Zx, TOS
	; W1at expects: Zx = address, Parsx_lo = byte to write, ignores Parsx_hi,Parsx_hlo
	call W1at		; Write 1 byte: [Zx] = Parsx_lo, Zx += 1
	PopST TOS		; Pop new TOS (was byte, now get next item)
	rjmp NEXT
	; }}}

DEFWORD w_word_store,		0,		"W!",			f_word_store		; ( word addr -- ) store word to address

; W! - store word to address
; ( word addr -- )
.section CURRENT_TEXT_SECTION,"ax",@progbits
gfunc f_word_store	; {{{ #
	PopST Parsx		; Pop value to Parsx
	Set3 Zx, TOS
	; W1at expects: Zx = address, Parsx_lo = byte to write, ignores Parsx_hi,Parsx_hlo
	call W2at		; Write 2 byte: [Zx] = Parsx_lo,Parsx_hi, Zx += 2
	PopST TOS		; Pop new TOS (was byte, now get next item)
	rjmp NEXT
	; }}}
