; .. vim: ft=asm showbreak=--»\  noexpandtab fileencoding=utf-8 nomodified   wrap textwidth=0 foldmethod=marker foldmarker={{{,}}} foldcolumn=4 ruler showcmd lcs=tab\:|- list tabstop=8 noexpandtab nosmarttab softtabstop=0 shiftwidth=0 linebreak  


DEFWORD w_ROT,			0,		"ROT",			f_ROT			; ( a b c -- b c a ) rotate 3. item up [----]
DEFWORD w_revROT,		0,		"-ROT",			f_revROT		; ( a b c -- c a b ) rotate 1. item to 3. [----]

.section CURRENT_TEXT_SECTION,"ax",@progbits
gfunc f_ROT	; {{{ 
	ReadST_N	0, Temp	; b
	ReadST_N	1, DT	; a
	
	WriteST_N	0, TOS	; c
	WriteST_N	1, Temp	; b
	Set3		TOS, DT	; a
	jmp NEXT
; }}}
gfunc f_revROT	; {{{ 
	ReadST_N	0, Temp		; b
	ReadST_N	1, DT		; a
	
	WriteST_N	0, DT		; a
	WriteST_N	1, TOS		; c
	Set3		TOS, Temp	; b
	jmp NEXT
; }}}



