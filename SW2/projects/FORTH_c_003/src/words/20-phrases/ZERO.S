; .. vim: ft=asm showbreak=--»\  noexpandtab fileencoding=utf-8 nomodified   wrap textwidth=0 foldmethod=marker foldmarker={{{,}}} foldcolumn=4 ruler showcmd lcs=tab\:|- list tabstop=8 noexpandtab nosmarttab softtabstop=0 shiftwidth=0 linebreak  

DEFWORD w_zero,			0,		"0",			f_zero			; (  -- 0 ) push zero on stack : 0 0 ;

.section CURRENT_TEXT_SECTION,"ax",@progbits
gfunc f_zero	; {{{ #
	PushST TOS
	Set3 TOS, r1,r1,r1
	rjmp NEXT
	; }}}

DEFWORD w_one,			0,		"1",			f_one			; (  -- 0 ) push one on stack : 1 1 ;

.section CURRENT_TEXT_SECTION,"ax",@progbits
gfunc f_one	; {{{ #
	PushST TOS
	Set3 TOS, r1,r1,r1
	inc TOS_lo
	rjmp NEXT
	; }}}

DEFWORD w_minus_one,		0,		"-1",			f_minus_one		; (  -- 0 ) push minus one on stack : -1 -1 ;

.section CURRENT_TEXT_SECTION,"ax",@progbits
gfunc f_minus_one	; {{{ #
	PushST TOS
	ser Tx
	Set3 TOS, Tx,Tx,Tx
	rjmp NEXT
	; }}}

.macro	PUSHXxx start,stop	; {{{ save registers from start to stop iclusive
	.set __reg, \start
	.rept (\stop - \start + 1)
		push __reg
		.set __reg, __reg + 1
	.endr
.endm	; }}}
.macro	POPXxx	 start,stop ; {{{ load registers from start to stop iclusive
	.set __reg, \stop
	.rept (\stop - \start + 1)
		pop __reg
		.set __reg, __reg - 1
	.endr
.endm	; }}}

PUSHXxx 1,30
POPXxx 1,30
