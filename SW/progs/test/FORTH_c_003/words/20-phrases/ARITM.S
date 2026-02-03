; .. vim: ft=asm showbreak=--»\  noexpandtab fileencoding=utf-8 nomodified   wrap textwidth=0 foldmethod=marker foldmarker={{{,}}} foldcolumn=4 ruler showcmd lcs=tab\:|- list tabstop=8 noexpandtab nosmarttab softtabstop=0 shiftwidth=0 linebreak  


DEFWORD w_one_plus,		0,		"1+",			f_one_plus		; ( a -- b ) b = a + 1 [0290]
DEFWORD w_one_minus,		0,		"1-",			f_one_minus		; ( a -- b ) b = a - 1 [xxxx]

.section CURRENT_TEXT_SECTION,"ax",@progbits
gfunc f_one_plus	; {{{ #
	ldi	Temp, 1
	Add31	TOS, Temp
	rjmp NEXT
; }}}
gfunc f_one_minus	; {{{ #
	ldi	Temp, 1
	Sub31	TOS, Temp
	rjmp NEXT
; }}}

; https://forth-standard.org/standard/core/OnePlus
; 
; 6.1.0290 1+ one-plus CORE
; ( n1 | u1 -- n2 | u2 )
; 
; Add one (1) to n1 | u1 giving the sum n2 | u2. 

