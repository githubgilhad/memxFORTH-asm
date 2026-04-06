; .. vim: ft=asm showbreak=--»\  noexpandtab fileencoding=utf-8 nomodified   wrap textwidth=0 foldmethod=marker foldmarker={{{,}}} foldcolumn=4 ruler showcmd lcs=tab\:|- list tabstop=8 noexpandtab nosmarttab softtabstop=0 shiftwidth=0 linebreak  tags=./tags;,tags; 


DEFWORD w_VER,			0,		"VER",			f_CONSTSTRING		; (  -- addr u ) version string
	.byte 2f - . -1
	.ascii "ver. " VERSION_STRING " (" VERSION_MESSAGE ")"
2:
DEFWORD w_VER_MESSAGE,		0,		"VER_MESSAGE",		f_CONSTSTRING		; (  --  addr u ) version message
	.byte 2f - . -1
	.ascii VERSION_MESSAGE 
2:
DEFWORD w_VERSION,		0,		"VERSION",		f_CONSTSTRING		; (  --  addr u ) just version
	.byte 2f - . -1
	.ascii VERSION_STRING
2:
DEFWORD w_COMMIT,		0,		"COMMIT",		f_CONSTSTRING		; (  --  addr u ) just commit
	.byte 2f - . -1
	.ascii VERSION_COMMIT
2:



