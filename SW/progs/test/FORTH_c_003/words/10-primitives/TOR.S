; .. vim: ft=asm showbreak=--»\  noexpandtab fileencoding=utf-8 nomodified   wrap textwidth=0 foldmethod=marker foldmarker={{{,}}} foldcolumn=4 ruler showcmd lcs=tab\:|- list tabstop=8 noexpandtab nosmarttab softtabstop=0 shiftwidth=0 linebreak  


DEFWORD w_toR,			0,		">R",			f_toR			; ( x  --  )( R: -- x ) move CELL from data stack to return stack
DEFWORD w_2toR,			0,		"2>R",			f_2toR			; ( x y  --  )( R: -- x y ) move 2 CELLs from data stack to return stack (in order)

.section CURRENT_TEXT_SECTION,"ax",@progbits
gfunc f_toR	; {{{ #
	PushR TOS
	PopST TOS
	rjmp NEXT
; }}}
gfunc f_2toR	; {{{ #
	PopST Parsx
	PushR Parsx
	PushR TOS
	PopST TOS
	rjmp NEXT
; }}}

; https://forth-standard.org/standard/core/toR
; 
; 6.1.0580 >R to-r CORE
; Interpretation:
; Interpretation semantics for this word are undefined.
; 
; Execution:
; ( x -- ) ( R: -- x )
; 
; Move x to the return stack. 
