; .. vim: ft=asm showbreak=--»\  noexpandtab fileencoding=utf-8 nomodified   wrap textwidth=0 foldmethod=marker foldmarker={{{,}}} foldcolumn=4 ruler showcmd lcs=tab\:|- list tabstop=8 noexpandtab nosmarttab softtabstop=0 shiftwidth=0 linebreak  

/*
DEFCONSTI1 "K_ENTER",		K_ENTER,	'\n'
DEFCONSTI1 "K_LEFT",		K_LEFT,		'4'+0x80
DEFCONSTI1 "K_RIGHT",		K_RIGHT,	'6'+0x80
DEFCONSTI1 "K_DEL",		K_DEL,		'.'+0x80
DEFCONSTI1 "K_BACKSPACE",	K_BACKSPACE,	'\b'
DEFCONSTI1 "K_ESC",		K_ESC,		'\e'

DEFCONSTI1 "BL",		BL,		' '
*/

DEFCONSTI1 "K_ENTER",		K_ENTER,	0x0d
DEFCONSTI1 "K_LEFT",		K_LEFT,		'['
DEFCONSTI1 "K_RIGHT",		K_RIGHT,	']'
DEFCONSTI1 "K_DEL",		K_DEL,		'}'
DEFCONSTI1 "K_BACKSPACE",	K_BACKSPACE,	0x7f
DEFCONSTI1 "K_ESC",		K_ESC,		0x1b

DEFCONSTI1 "BL",		BL,		'~'
/**/



DEFVAR "PROMPT_X",	PROMPT_X
DEFVAR "PROMPT_Y",	PROMPT_Y
