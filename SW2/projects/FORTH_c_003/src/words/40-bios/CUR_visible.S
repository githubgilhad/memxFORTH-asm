; .. vim: ft=asm showbreak=--»\  noexpandtab fileencoding=utf-8 nomodified   wrap textwidth=0 foldmethod=marker foldmarker={{{,}}} foldcolumn=4 ruler showcmd lcs=tab\:|- list tabstop=8 noexpandtab nosmarttab softtabstop=0 shiftwidth=0 linebreak  tags=./tags;,tags; 


DEFWORD w_CUR_visible,			0,		"CUR_visible",			f_CUR_visible			; ( flag --  ) set cursor visibility

.section CURRENT_TEXT_SECTION,"ax",@progbits
gfunc f_CUR_visible	; {{{ 
	Set2	Cpar1,	TOS2
	call_VT_member_C	VT_set_cursor_visible
	PopST	TOS
	jmp NEXT
; }}}



