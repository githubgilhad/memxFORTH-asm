; .. vim: ft=asm showbreak=--»\  noexpandtab fileencoding=utf-8 nomodified   wrap textwidth=0 foldmethod=marker foldmarker={{{,}}} foldcolumn=4 ruler showcmd lcs=tab\:|- list tabstop=8 noexpandtab nosmarttab softtabstop=0 shiftwidth=0 linebreak  

DEFWORD w_TEST,			0,		"TEST",			f_docol, yes		; ( -- 0x42 ) // just test
	P24 w_LITERAL_cw
	.byte 0x21,0,0
	P24 w_DUP_cw
	P24 w_plus_cw
	P24 w_exit_cw
