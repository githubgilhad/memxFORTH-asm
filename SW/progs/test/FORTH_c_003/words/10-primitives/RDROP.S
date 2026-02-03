; .. vim: ft=asm showbreak=--»\  noexpandtab fileencoding=utf-8 nomodified   wrap textwidth=0 foldmethod=marker foldmarker={{{,}}} foldcolumn=4 ruler showcmd lcs=tab\:|- list tabstop=8 noexpandtab nosmarttab softtabstop=0 shiftwidth=0 linebreak  
DEFWORD w_RDROP,		0,		"RDROP",		f_RDROP			; ( -- ) ( R: x -- ) DROP for return stack
DEFWORD w_2RDROP,		0,		"2RDROP",		f_2RDROP		; ( -- ) ( R: x y -- ) 2DROP for return stack

.section CURRENT_TEXT_SECTION,"ax",@progbits
gfunc f_RDROP	; {{{ #
	PopR   Parsx
	rjmp NEXT
; }}}
gfunc f_2RDROP	; {{{ #
	PopR   Parsx
	PopR   Parsx
	rjmp NEXT
; }}}


