; .. vim: ft=asm showbreak=--»\  noexpandtab fileencoding=utf-8 nomodified   wrap textwidth=0 foldmethod=marker foldmarker={{{,}}} foldcolumn=4 ruler showcmd lcs=tab\:|- list tabstop=8 noexpandtab nosmarttab softtabstop=0 shiftwidth=0 linebreak  

DEFWORD w_at,		0,	"at",		f_at	// ( addr -- value ) fetch cell from address

; @ - fetch cell from address
; ( addr -- value )
.section CURRENT_TEXT_SECTION,"ax",@progbits
gfunc f_at	; {{{ #
	Set3 Zx, TOS
	call B3at
	Set3 TOS, Parsx
	rjmp NEXT
	; }}}
