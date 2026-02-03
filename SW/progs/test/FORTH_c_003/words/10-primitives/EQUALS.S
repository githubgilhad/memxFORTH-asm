; .. vim: ft=asm showbreak=--»\  noexpandtab fileencoding=utf-8 nomodified   wrap textwidth=0 foldmethod=marker foldmarker={{{,}}} foldcolumn=4 ruler showcmd lcs=tab\:|- list tabstop=8 noexpandtab nosmarttab softtabstop=0 shiftwidth=0 linebreak  


DEFWORD w_non_equals,		0,		"<>",			f_non_equals		; ( x y -- flag ) x <> y
DEFWORD w_equals,		0,		"=",			f_equals		; ( x y -- flag ) x == y
DEFWORD w_zero_non_equals,	0,		"0<>",			f_zero_non_equals	; ( x -- flag ) x <> 0
DEFWORD w_zero_equals,		0,		"0=",			f_zero_equals		; ( x -- flag ) x == 0
DEFWORD w_one_non_equals,	0,		"1<>",			f_one_non_equals	; ( x -- flag ) x <> 0
DEFWORD w_one_equals,		0,		"1=",			f_one_equals		; ( x -- flag ) x == 0

.section CURRENT_TEXT_SECTION,"ax",@progbits
gfunc f_non_equals	; {{{ #
	PopST Parsx
	Cmp3  Parsx, TOS
	breq 1f
	TRUE TOS
	rjmp NEXT
1:
	FALSE TOS
	rjmp NEXT
; }}}
gfunc f_equals	; {{{ #
	PopST Parsx
	Cmp3  Parsx, TOS
	breq 1f
	FALSE TOS
	rjmp NEXT
1:
	TRUE TOS
	rjmp NEXT
; }}}
gfunc f_zero_non_equals	; {{{ #
	breq3 TOS, 1f
	TRUE TOS
	rjmp NEXT
1:
	FALSE TOS
	rjmp NEXT
; }}}
gfunc f_zero_equals	; {{{ #
	breq3 TOS, 1f
	FALSE TOS
	rjmp NEXT
1:
	TRUE TOS
	rjmp NEXT
; }}}
gfunc f_one_non_equals	; {{{ #
	dec TOS_lo
	breq3 TOS, 1f
	TRUE TOS
	rjmp NEXT
1:
	FALSE TOS
	rjmp NEXT
; }}}
gfunc f_one_equals	; {{{ #
	dec TOS_lo
	breq3 TOS, 1f
	FALSE TOS
	rjmp NEXT
1:
	TRUE TOS
	rjmp NEXT
; }}}


