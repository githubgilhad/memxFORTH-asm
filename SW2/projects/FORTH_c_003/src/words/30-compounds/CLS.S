; .. vim: ft=asm showbreak=--»\  noexpandtab fileencoding=utf-8 nomodified   wrap textwidth=0 foldmethod=marker foldmarker={{{,}}} foldcolumn=4 ruler showcmd lcs=tab\:|- list tabstop=8 noexpandtab nosmarttab softtabstop=0 shiftwidth=0 linebreak  


DEFWORD w_CLS,			0,		"CLS",			f_docol, yes		; (  --  ) CLear Screan [xxxx]

	P24 w_LIT1_cw
	.byte 0x1B ; \e
	P24 w_EMIT_cw
	
	P24 w_LIT1_cw
	.byte '['
	P24 w_EMIT_cw
	
	P24 w_LIT1_cw
	.byte '2'
	P24 w_EMIT_cw
	
	P24 w_LIT1_cw
	.byte 'J'
	P24 w_EMIT_cw
	
	P24 w_LIT1_cw
	.byte 0x1B ; \e
	P24 w_EMIT_cw
	
	P24 w_LIT1_cw
	.byte '['
	P24 w_EMIT_cw
	
	P24 w_LIT1_cw
	.byte 'H'
	P24 w_EMIT_cw

	P24 w_exit_cw
