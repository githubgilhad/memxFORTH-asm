; .. vim: ft=asm showbreak=--»\  noexpandtab fileencoding=utf-8 nomodified   wrap textwidth=0 foldmethod=marker foldmarker={{{,}}} foldcolumn=4 ruler showcmd lcs=tab\:|- list tabstop=8 noexpandtab nosmarttab softtabstop=0 shiftwidth=0 linebreak  tags=./tags;,tags; 


DEFWORD w_ROW_COLOR,		0,		"ROW_COLOR",		f_ROW_COLOR		; ( c --  ) set color c for actual row
DEFWORD w_ROW_COLOR_Y,		0,		"ROW_COLOR_Y",		f_ROW_COLOR_Y		; ( c y --  ) set color c for given row
DEFWORD w_DEF_COLOR,		0,		"DEF_COLOR",		f_DEF_COLOR		; ( c --  ) set default color c

.section CURRENT_TEXT_SECTION,"ax",@progbits
gfunc f_ROW_COLOR	; {{{ 
	Set2	Cpar1,	TOS2
	call_VT_member_C	VT_set_row_color
	PopST	TOS
	jmp NEXT
; }}}
gfunc f_ROW_COLOR_Y	; {{{ 
	PopST	Parsx	; Cpar2 + Cpar1_lo
	Set2	Cpar1,	TOS2
	call_VT_member_C	VT_set_row_color_Y
	PopST	TOS
	jmp NEXT
; }}}
gfunc f_DEF_COLOR	; {{{ 
	Set2	Cpar1,	TOS2
	call_VT_member_C	VT_set_def_color
	PopST	TOS
	jmp NEXT
; }}}



