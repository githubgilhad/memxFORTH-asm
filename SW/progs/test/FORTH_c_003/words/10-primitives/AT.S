; .. vim: ft=asm showbreak=--»\  noexpandtab fileencoding=utf-8 nomodified   wrap textwidth=0 foldmethod=marker foldmarker={{{,}}} foldcolumn=4 ruler showcmd lcs=tab\:|- list tabstop=8 noexpandtab nosmarttab softtabstop=0 shiftwidth=0 linebreak  

DEFWORD w_at,			0,		"@",			f_at			; ( addr -- value ) fetch cell from address

; @ - fetch cell from address
; ( addr -- value )
.section CURRENT_TEXT_SECTION,"ax",@progbits
gfunc f_at	; {{{ #
	Set3 Zx, TOS
	call B3at
	Set3 TOS, Parsx
	rjmp NEXT
	; }}}

DEFWORD w_char_at,		0,		"C@",			f_char_at		; ( addr -- byte ) fetch byte from address

; C@ - fetch byte from address
; ( addr -- byte )
.section CURRENT_TEXT_SECTION,"ax",@progbits
gfunc f_char_at	; {{{ #
	Set3 Zx, TOS
	call B1at
	mov TOS_lo, Parsx_lo
	clr TOS_hi
	clr TOS_hlo
	rjmp NEXT
	; }}}

DEFWORD w_word_at,		0,		"W@",			f_word_at		; ( addr -- word ) fetch word (2bytes) from address

; W@ - fetch word from address
; ( addr -- word )
.section CURRENT_TEXT_SECTION,"ax",@progbits
gfunc f_word_at	; {{{ #
	Set3 Zx, TOS
	call B2at
	mov TOS_lo, Parsx_lo
	mov TOS_hi, Parsx_hi
	clr TOS_hlo
	rjmp NEXT
	; }}}
