; .. vim: ft=asm showbreak=--»\  noexpandtab fileencoding=utf-8 nomodified   wrap textwidth=0 foldmethod=marker foldmarker={{{,}}} foldcolumn=4 ruler showcmd lcs=tab\:|- list tabstop=8 noexpandtab nosmarttab softtabstop=0 shiftwidth=0 linebreak  

DEFWORD w_INIT,			0,		"INIT",			f_INIT			; (  -- ) Set stacks and all other data to init values

.section CURRENT_TEXT_SECTION,"ax",@progbits
gfunc f_INIT	; {{{ # TODO
	rjmp NEXT
	; }}}

