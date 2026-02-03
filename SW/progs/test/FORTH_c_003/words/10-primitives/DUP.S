; .. vim: ft=asm showbreak=--»\  noexpandtab fileencoding=utf-8 nomodified   wrap textwidth=0 foldmethod=marker foldmarker={{{,}}} foldcolumn=4 ruler showcmd lcs=tab\:|- list tabstop=8 noexpandtab nosmarttab softtabstop=0 shiftwidth=0 linebreak  

DEFWORD w_DUP,			0,		"DUP",			f_DUP			; ( a -- a a ) duplicate top of stack
DEFWORD w_2DUP,			0,		"2DUP",			f_2DUP			; ( a b -- a b a b ) duplicate 2 CELLs on top of stack [0380]
DEFWORD w_qDUP,			0,		"?DUP",			f_qDUP			; ( a -- 0 | a a ) duplicate non zero CELL [0630]

.section CURRENT_TEXT_SECTION,"ax",@progbits
gfunc f_DUP	; {{{ #
	PushST TOS
	rjmp NEXT
	; }}}
gfunc f_2DUP	; {{{ #
	ReadST_N 0, DT
	PushST TOS
	PushST DT
	rjmp NEXT
	; }}}
gfunc f_qDUP	; {{{ #
	breq3	TOS, 1f
	PushST	TOS
1:
	rjmp NEXT
	; }}}


; 
; 
; https://forth-standard.org/standard/core/TwoDUP
; 
; 6.1.0380 2DUP two-dupe CORE
; ( x1 x2 -- x1 x2 x1 x2 )
; 
; Duplicate cell pair x1 x2. 


; https://forth-standard.org/standard/core/qDUP
; 
; 6.1.0630 ?DUP question-dupe CORE
; ( x -- 0 | x x )
; 
; Duplicate x if it is non-zero.
; 
