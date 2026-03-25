; .. vim: ft=asm showbreak=--»\  noexpandtab fileencoding=utf-8 nomodified   wrap textwidth=0 foldmethod=marker foldmarker={{{,}}} foldcolumn=4 ruler showcmd lcs=tab\:|- list tabstop=8 noexpandtab nosmarttab softtabstop=0 shiftwidth=0 linebreak  tags=./tags;,tags; 


DEFWORD w_CUR_yx,		0,		"CUR_yx",		f_CUR_yx		; ( y x  --  ) move cursor to Y,X  [----]

.section CURRENT_TEXT_SECTION,"ax",@progbits
gfunc f_CUR_yx	; {{{ 
	PopST	Parsx	; Cpar2 + Cpar1_lo
	Set2	Cpar1,	TOS2
	call_VT_member_C	VT_set_cursor_XY
	PopST	TOS
	rjmp NEXT
; }}}



