; .. vim: ft=asm showbreak=--»\  noexpandtab fileencoding=utf-8 nomodified   wrap textwidth=0 foldmethod=marker foldmarker={{{,}}} foldcolumn=4 ruler showcmd lcs=tab\:|- list tabstop=8 noexpandtab nosmarttab softtabstop=0 shiftwidth=0 linebreak  


DEFWORD w_WORDS,			0,		"WORDS",			f_WORDS			; (  --  ) print all words [xxxx]

.section CURRENT_TEXT_SECTION,"ax",@progbits
gfunc f_WORDS	; {{{ # 
	call C_words
	rjmp NEXT
; }}}



