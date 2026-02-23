; .. vim: ft=asm showbreak=--»\  noexpandtab fileencoding=utf-8 nomodified   wrap textwidth=0 foldmethod=marker foldmarker={{{,}}} foldcolumn=4 ruler showcmd lcs=tab\:|- list tabstop=8 noexpandtab nosmarttab softtabstop=0 shiftwidth=0 linebreak  


DEFWORD w_I,			0,		"I",			f_I			; (  -- x ) return value of inner loop control variable

.section CURRENT_TEXT_SECTION,"ax",@progbits
gfunc f_I	; {{{ #
	PushST     TOS
	ReadR_N 0, TOS
	rjmp NEXT
; }}}



