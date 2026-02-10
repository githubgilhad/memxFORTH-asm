; .. vim: ft=asm showbreak=--»\  noexpandtab fileencoding=utf-8 nomodified   wrap textwidth=0 foldmethod=marker foldmarker={{{,}}} foldcolumn=4 ruler showcmd lcs=tab\:|- list tabstop=8 noexpandtab nosmarttab softtabstop=0 shiftwidth=0 linebreak  


DEFWORD w_BRK,			0,		"BRK",			f_BRK			; (  --  ) do nothing, breakpoint may be set here [xxxx]
DEFWORD w_BRK0,			0,		"BRK0",			f_BRK0			; (  --  ) do nothing, breakpoint may be set here [xxxx]
DEFWORD w_BRK1,			0,		"BRK1",			f_BRK1			; (  --  ) do nothing, breakpoint may be set here [xxxx]
DEFWORD w_BRK2,			0,		"BRK2",			f_BRK2			; (  --  ) do nothing, breakpoint may be set here [xxxx]
DEFWORD w_BRK3,			0,		"BRK3",			f_BRK3			; (  --  ) do nothing, breakpoint may be set here [xxxx]

.section CURRENT_TEXT_SECTION,"ax",@progbits
gfunc f_BRK	; {{{ 
	rjmp NEXT
; }}}
gfunc f_BRK0	; {{{ 
	rjmp NEXT
; }}}
gfunc f_BRK1	; {{{ 
	rjmp NEXT
; }}}
gfunc f_BRK2	; {{{ 
	rjmp NEXT
; }}}
gfunc f_BRK3	; {{{ 
	rjmp NEXT
; }}}



