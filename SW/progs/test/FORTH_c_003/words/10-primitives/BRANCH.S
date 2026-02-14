; .. vim: ft=asm showbreak=--»\  noexpandtab fileencoding=utf-8 nomodified   wrap textwidth=0 foldmethod=marker foldmarker={{{,}}} foldcolumn=4 ruler showcmd lcs=tab\:|- list tabstop=8 noexpandtab nosmarttab softtabstop=0 shiftwidth=0 linebreak  

DEFWORD w_BRANCH,		FLG_ARG_3,	"BRANCH",		f_BRANCH		; ( -- ) add following P24 to IP and NEXT there; -3 is endless loop [----]
DEFWORD w_0BRANCH,		FLG_ARG_3,	"0BRANCH",		f_0BRANCH		; ( -- ) branch if zero - add following P24 to IP and NEXT there; -3 is endless loop, else skip, eat stack [----]
DEFWORD w_1BRANCH,		FLG_ARG_3,	"1BRANCH",		f_1BRANCH		; ( -- ) branch if NOT zero - add following P24 to IP and NEXT there; -3 is endless loop, else skip, eat stack [xxxx]

.section CURRENT_TEXT_SECTION,"ax",@progbits
gfunc f_BRANCH	; {{{ #
	; IP points to the offset to jump
	Set3 Zx, IP
	call B3at
	Add3 IP, Parsx
	rjmp NEXT
	; }}}
gfunc f_0BRANCH	; {{{ #
	; IP points to the offset to jump
	Set3 Zx, IP
	call B3at
	breq3 TOS, 2f
	Set3 IP,Zx
	rjmp 3f
2:
	Add3 IP, Parsx
3:
	PopST TOS
	rjmp NEXT
	; }}}
gfunc f_1BRANCH	; {{{ #
	; IP points to the offset to jump
	Set3 Zx, IP
	call B3at
	breq3 TOS, 2f
	Add3 IP, Parsx
	rjmp 3f
2:
	Set3 IP,Zx
3:
	PopST TOS
	rjmp NEXT
	; }}}

