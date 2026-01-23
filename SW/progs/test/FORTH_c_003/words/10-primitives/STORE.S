DEFWORD w_store,		0,	"store",		f_store	// ( value addr -- ) store cell to address

; ! - store cell to address
; ( value addr -- )
.section CURRENT_TEXT_SECTION,"ax",@progbits
.global f_store
f_store:	; {{{ #
	PopST Parsx		; Pop value to Parsx
	Set3 Zx, TOS	; Set address to Zx
	; Store NTOS to address in TOS using W3at
	; W3at expects: Zx = address, Parsx = value to write
	call W3at		; Write 3 bytes: [Zx] = Parsx, Zx += 3
	PopST TOS		; Pop new TOS (was value, now get next item)
	rjmp NEXT
	; }}}

