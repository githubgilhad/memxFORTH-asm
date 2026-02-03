; .. vim: ft=asm showbreak=--»\  noexpandtab fileencoding=utf-8 nomodified   wrap textwidth=0 foldmethod=marker foldmarker={{{,}}} foldcolumn=4 ruler showcmd lcs=tab\:|- list tabstop=8 noexpandtab nosmarttab softtabstop=0 shiftwidth=0 linebreak  


DEFWORD w_PLUSLOOP, FLG_IMMEDIATE + FLG_ARG_2,	"+LOOP",		f_PLUSLOOP		; (  --  ) do something TODO

.section CURRENT_TEXT_SECTION,"ax",@progbits
gfunc f_PLUSLOOP	; {{{ # FIXME
	rjmp NEXT
; }}}



