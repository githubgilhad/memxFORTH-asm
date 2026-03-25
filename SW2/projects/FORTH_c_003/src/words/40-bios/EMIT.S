; .. vim: ft=asm showbreak=--»\  noexpandtab fileencoding=utf-8 nomodified   wrap textwidth=0 foldmethod=marker foldmarker={{{,}}} foldcolumn=4 ruler showcmd lcs=tab\:|- list tabstop=8 noexpandtab nosmarttab softtabstop=0 shiftwidth=0 linebreak  tags=./tags;,tags; 


DEFWORD w_EMIT,			0,		"EMIT",			f_EMIT			; ( c  --  ) output character [----]

.section CURRENT_TEXT_SECTION,"ax",@progbits
gfunc f_EMIT	; {{{ 
	Set2	Cpar1,	TOS2
	call_VT_member_C	VT_write_char
	PopST	TOS
	rjmp NEXT
; }}}



