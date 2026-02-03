; .. vim: ft=asm showbreak=--»\  noexpandtab fileencoding=utf-8 nomodified   wrap textwidth=0 foldmethod=marker foldmarker={{{,}}} foldcolumn=4 ruler showcmd lcs=tab\:|- list tabstop=8 noexpandtab nosmarttab softtabstop=0 shiftwidth=0 linebreak  

DEFWORD w_tick,			0,		"'",			f_docol, yes		; ( -- addr ) addr is xt of next word in TIB TODO
;	P24 w_parse_name_cw
;	P24 w_find_name_cw
;	P24 w_head2cw_cw
	P24 w_exit_cw
; : ' PARSE-WORD SEARCH-WORD H>CW ;
; : ' PARSE-NAME FIND-NAME

;      '            -- addr                       M,83            "tick"
;           Used in the form:
;                   ' <name>
;           addr is the compilation address of <name>.  An error
;           condition exists if <name> is not found in the currently
;           active search order.

