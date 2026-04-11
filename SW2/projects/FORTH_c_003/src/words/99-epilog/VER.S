; .. vim: ft=asm showbreak=--»\  noexpandtab fileencoding=utf-8 nomodified   wrap textwidth=0 foldmethod=marker foldmarker={{{,}}} foldcolumn=4 ruler showcmd lcs=tab\:|- list tabstop=8 noexpandtab nosmarttab softtabstop=0 shiftwidth=0 linebreak  tags=./tags;,tags; 


DEFWORD w_VER,			0,		"VER",			f_CONSTSTRING		; (  -- addr u ) version string
	.byte 2f - . -1
	.ascii "ver. " VERSION_STRING " (" VERSION_MESSAGE ") from " BUILD_DATE " " BUILD_TIME " "
2:
DEFWORD w_VER_MESSAGE,		0,		"VER_MESSAGE",		f_CONSTSTRING		; (  --  addr u ) version message
	.byte 2f - . -1
	.ascii VERSION_MESSAGE 
2:
DEFWORD w_VER_NUM,		0,		"VER_NUM",		f_CONSTSTRING		; (  --  addr u ) just version
	.byte 2f - . -1
	.ascii VERSION_STRING
2:
DEFWORD w_VER_GIT,		0,		"VER_GIT",		f_CONSTSTRING		; (  --  addr u ) just commit
	.byte 2f - . -1
	.ascii VERSION_COMMIT
2:
DEFWORD w_VER_DATE,		0,		"VER_DATE",		f_CONSTSTRING		; (  --  addr u ) just date
	.byte 2f - . -1
	.ascii BUILD_DATE
2:
DEFWORD w_VER_TIME,		0,		"VER_TIME",		f_CONSTSTRING		; (  --  addr u ) just time
	.byte 2f - . -1
	.ascii BUILD_TIME
2:



