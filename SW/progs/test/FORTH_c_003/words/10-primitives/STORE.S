DEFWORD w_store,		0,		"!",			f_store			; ( value addr -- ) store cell to address
DEFWORD w_char_store,		0,		"C!",			f_char_store		; ( byte addr -- )  store byte to address
DEFWORD w_word_store,		0,		"W!",			f_word_store		; ( word addr -- )  store word to address

DEFWORD w_plus_store,		0,		"+!",			f_plus_store		; ( value addr -- ) add cell to address
DEFWORD w_plus_char_store,	0,		"+C!",			f_plus_char_store	; ( byte addr -- )  add byte to address
DEFWORD w_plus_word_store,	0,		"+W!",			f_plus_word_store	; ( word addr -- )  add word to address

DEFWORD w_minus_store,		0,		"-!",			f_minus_store		; ( value addr -- ) sub cell from address
DEFWORD w_minus_char_store,	0,		"-C!",			f_minus_char_store	; ( byte addr -- )  sub byte from address
DEFWORD w_minus_word_store,	0,		"-W!",			f_minus_word_store	; ( word addr -- )  sub word from address

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
gfunc f_char_store	; {{{ #
	PopST Parsx		; Pop value to Parsx
	Set3 Zx, TOS
	; W1at expects: Zx = address, Parsx_lo = byte to write, ignores Parsx_hi,Parsx_hlo
	call W1at		; Write 1 byte: [Zx] = Parsx_lo, Zx += 1
	PopST TOS		; Pop new TOS (was byte, now get next item)
	rjmp NEXT
	; }}}
gfunc f_word_store	; {{{ #
	PopST Parsx		; Pop value to Parsx
	Set3 Zx, TOS
	; W1at expects: Zx = address, Parsx_lo = byte to write, ignores Parsx_hi,Parsx_hlo
	call W2at		; Write 2 byte: [Zx] = Parsx_lo,Parsx_hi, Zx += 2
	PopST TOS		; Pop new TOS (was byte, now get next item)
	rjmp NEXT
	; }}}

gfunc f_plus_store	; {{{ #
	PopST DT	; Pop value to DT
	Set3 Zx, TOS	; Set address to Zx
	call B3at
	Add3 Parsx,DT
	Set3 Zx, TOS	; Set address to Zx
	; Store NTOS to address in TOS using W3at
	; W3at expects: Zx = address, Parsx = value to write
	call W3at		; Write 3 bytes: [Zx] = Parsx, Zx += 3
	PopST TOS		; Pop new TOS (was value, now get next item)
	rjmp NEXT
	; }}}
gfunc f_plus_char_store	; {{{ #
	PopST DT		; Pop value to DT
	Set3 Zx, TOS
	call B1at
	Add3 Parsx,DT	; hi, hlo not care
	Set3 Zx, TOS	; Set address to Zx
	; W1at expects: Zx = address, Parsx_lo = byte to write, ignores Parsx_hi,Parsx_hlo
	call W1at		; Write 1 byte: [Zx] = Parsx_lo, Zx += 1
	PopST TOS		; Pop new TOS (was byte, now get next item)
	rjmp NEXT
	; }}}
gfunc f_plus_word_store	; {{{ #
	PopST DT		; Pop value to DT
	Set3 Zx, TOS
	call B2at
	Add3 Parsx,DT	; hlo not care
	; W1at expects: Zx = address, Parsx_lo = byte to write, ignores Parsx_hi,Parsx_hlo
	call W2at		; Write 2 byte: [Zx] = Parsx_lo,Parsx_hi, Zx += 2
	PopST TOS		; Pop new TOS (was byte, now get next item)
	rjmp NEXT
	; }}}

gfunc f_minus_store	; {{{ #
	PopST DT	; Pop value to DT
	Set3 Zx, TOS	; Set address to Zx
	call B3at
	Sub3 Parsx,DT
	Set3 Zx, TOS	; Set address to Zx
	; Store NTOS to address in TOS using W3at
	; W3at expects: Zx = address, Parsx = value to write
	call W3at		; Write 3 bytes: [Zx] = Parsx, Zx += 3
	PopST TOS		; Pop new TOS (was value, now get next item)
	rjmp NEXT
	; }}}
gfunc f_minus_char_store	; {{{ #
	PopST DT		; Pop value to DT
	Set3 Zx, TOS
	call B1at
	Sub3 Parsx,DT	; hi, hlo not care
	Set3 Zx, TOS	; Set address to Zx
	; W1at expects: Zx = address, Parsx_lo = byte to write, ignores Parsx_hi,Parsx_hlo
	call W1at		; Write 1 byte: [Zx] = Parsx_lo, Zx += 1
	PopST TOS		; Pop new TOS (was byte, now get next item)
	rjmp NEXT
	; }}}
gfunc f_minus_word_store	; {{{ #
	PopST DT		; Pop value to DT
	Set3 Zx, TOS
	call B2at
	Sub3 Parsx,DT	; hlo not care
	; W1at expects: Zx = address, Parsx_lo = byte to write, ignores Parsx_hi,Parsx_hlo
	call W2at		; Write 2 byte: [Zx] = Parsx_lo,Parsx_hi, Zx += 2
	PopST TOS		; Pop new TOS (was byte, now get next item)
	rjmp NEXT
	; }}}
