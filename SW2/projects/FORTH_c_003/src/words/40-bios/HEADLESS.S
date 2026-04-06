; .. vim: ft=asm showbreak=--»\  noexpandtab fileencoding=utf-8 nomodified   wrap textwidth=0 foldmethod=marker foldmarker={{{,}}} foldcolumn=4 ruler showcmd lcs=tab\:|- list tabstop=8 noexpandtab nosmarttab softtabstop=0 shiftwidth=0 linebreak  tags=./tags;,tags; 


DEFWORD w_HEADLESS,		0,		"HEADLESS",		f_HEADLESS		; (  --  ) stop generation of VGA signal [----]
DEFWORD w_HEADMORE,		0,		"HEADMORE",		f_HEADMORE		; (  --  ) start generation of VGA signal again [----]

.section CURRENT_TEXT_SECTION,"ax",@progbits
gfunc f_HEADLESS	; {{{ 
	call_VT_member_C	VT_HEADLESS
	jmp NEXT
; }}}
gfunc f_HEADMORE	; {{{ 
	call_VT_member_C	VT_HEADMORE
	jmp NEXT
; }}}



