; .. vim: ft=asm showbreak=--»\  noexpandtab fileencoding=utf-8 nomodified   wrap textwidth=0 foldmethod=marker foldmarker={{{,}}} foldcolumn=4 ruler showcmd lcs=tab\:|- list tabstop=8 noexpandtab nosmarttab softtabstop=0 shiftwidth=0 linebreak  

DEFWORD w_BRANCH,		FLG_ARG_3,	"BRANCH",		f_BRANCH		; ( -- ) add following P24 to IP and NEXT there; -3 is endless loop

.section CURRENT_TEXT_SECTION,"ax",@progbits
gfunc f_BRANCH	; {{{ #
	; IP points to the offset to jump
	Set3 Zx, IP
	call B3at
	Add3 IP, Parsx
	rjmp NEXT
	; }}}

DEFWORD w_0BRANCH,		FLG_ARG_3,	"0BRANCH",		f_0BRANCH		; ( -- ) branch if zero - add following P24 to IP and NEXT there; -3 is endless loop

.section CURRENT_TEXT_SECTION,"ax",@progbits
gfunc f_0BRANCH	; {{{ #
	; IP points to the offset to jump
	Set3 Zx, IP
	call B3at
	breq3 TOS, 2f
	Set3 IP,Zx
	PopST TOS
	rjmp NEXT
2:
	Add3 IP, Parsx
	PopST TOS
	rjmp NEXT
	; }}}

