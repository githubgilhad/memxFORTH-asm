; .. vim: ft=asm showbreak=--»\  noexpandtab fileencoding=utf-8 nomodified   wrap textwidth=0 foldmethod=marker foldmarker={{{,}}} foldcolumn=4 ruler showcmd lcs=tab\:|- list tabstop=8 noexpandtab nosmarttab softtabstop=0 shiftwidth=0 linebreak  tags=./tags;,tags; 


DEFWORD w_HEADLESS,		0,		"HEADLESS",		f_HEADLESS		; (  --  ) stop generation of VGA signal [----]
DEFWORD w_HEADMORE,		0,		"HEADMORE",		f_HEADMORE		; (  --  ) start generation of VGA signal again [----]

.section CURRENT_TEXT_SECTION,"ax",@progbits
gfunc f_HEADLESS	; {{{ 
	lds r24,TIMSK1
	andi r24, ~(1 << TOIE1)
	sts TIMSK1, r24
	jmp NEXT
; }}}
gfunc f_HEADMORE	; {{{ 
	lds r24,TIMSK1
	ori r24, (1 << TOIE1)
	sts TIMSK1, r24
	jmp NEXT
; }}}



