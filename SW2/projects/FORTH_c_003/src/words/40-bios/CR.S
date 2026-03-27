; .. vim: ft=asm showbreak=--»\  noexpandtab fileencoding=utf-8 nomodified   wrap textwidth=0 foldmethod=marker foldmarker={{{,}}} foldcolumn=4 ruler showcmd lcs=tab\:|- list tabstop=8 noexpandtab nosmarttab softtabstop=0 shiftwidth=0 linebreak  tags=./tags;,tags; 


DEFWORD w_CR,			0,		"CR",			f_CR			; (  --  ) do new line 

.section CURRENT_TEXT_SECTION,"ax",@progbits
gfunc f_CR	; {{{ 
	call_VT_member_C	VT_cr
	jmp NEXT
; }}}



