; .. vim: ft=asm showbreak=--»\  noexpandtab fileencoding=utf-8 nomodified   wrap textwidth=0 foldmethod=marker foldmarker={{{,}}} foldcolumn=4 ruler showcmd lcs=tab\:|- list tabstop=8 noexpandtab nosmarttab softtabstop=0 shiftwidth=0 linebreak  

DEFWORD w_docol,		0,		"docol",		f_docol			; ( XX )  enter colon word

; DOCOL - enter colon word
.section CURRENT_TEXT_SECTION,"ax",@progbits
gfunc f_docol	; {{{ #
	rjmp DOCOL
	; }}}

