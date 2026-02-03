; .. vim: ft=asm showbreak=--»\  noexpandtab fileencoding=utf-8 nomodified   wrap textwidth=0 foldmethod=marker foldmarker={{{,}}} foldcolumn=4 ruler showcmd lcs=tab\:|- list tabstop=8 noexpandtab nosmarttab softtabstop=0 shiftwidth=0 linebreak  


DEFWORD w_CERROR,		0,		"CERROR",		f_docol, yes	; ( c-address u  -- ) reports error with string [xxxx]
	P24 w_LIT1_cw
	.byte '<'
	P24 w_LIT1_cw
	.byte '?'
	P24 w_TYPE_cw
	P24 w_LIT1_cw
	.byte '>'
	P24 w_exit_cw


