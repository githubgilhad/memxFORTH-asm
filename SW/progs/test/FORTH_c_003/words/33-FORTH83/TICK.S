; .. vim: ft=asm showbreak=--»\  noexpandtab fileencoding=utf-8 nomodified   wrap textwidth=0 foldmethod=marker foldmarker={{{,}}} foldcolumn=4 ruler showcmd lcs=tab\:|- list tabstop=8 noexpandtab nosmarttab softtabstop=0 shiftwidth=0 linebreak  

DEFWORD w_tick,			0,		"'",			f_docol, yes		; ( "name" -- addr ) addr is xt of next word in TIB TODO
	P24 w_PARSE_NAME_cw
	P24 w_FIND_NAME_cw
	P24 ww_do_IF_cw
	P24 2f - .
	P24 w_toR_cw
	P24 w_2DROP_cw
	P24 w_Rfrom_cw
	P24 ww_do_ELSE_cw
	P24 3f - .
2:
	P24 w_2DROP_cw
	P24 w_zero_cw
3:
	P24 w_exit_cw
; : ' PARSE-NAME FIND-NAME IF >R 2DROP R> ELSE 2DROP 0 THEN ;

;      '            -- addr                       M,83            "tick"
;           Used in the form:
;                   ' <name>
;           addr is the compilation address of <name>.  An error
;           condition exists if <name> is not found in the currently
;           active search order.

