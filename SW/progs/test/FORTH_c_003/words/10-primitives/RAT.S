; .. vim: ft=asm showbreak=--»\  noexpandtab fileencoding=utf-8 nomodified   wrap textwidth=0 foldmethod=marker foldmarker={{{,}}} foldcolumn=4 ruler showcmd lcs=tab\:|- list tabstop=8 noexpandtab nosmarttab softtabstop=0 shiftwidth=0 linebreak  

DEFWORD w_R_at,			0,		"R@",			f_R_at			; (  -- x ) ( R: x -- x ) copy CELL from return stack to data stack
DEFWORD w_2R_at,		0,		"2R@",			f_2R_at			; (  -- x y ) ( R: x y -- x y ) copy 2 CELLs from return stack to data stack (same order)

.section CURRENT_TEXT_SECTION,"ax",@progbits
gfunc f_R_at	; {{{ #
	PushST     TOS
	ReadR_N 0, TOS
	rjmp       NEXT
; }}}
gfunc f_2R_at	; {{{ #
	PushST     TOS
	ReadR_N 1, TOS
	PushST     TOS
	ReadR_N 0, TOS
	rjmp       NEXT
; }}}

; https://forth-standard.org/standard/core/RFetch
; 
; 6.1.2070 R@ r-fetch CORE
; Interpretation:
; Interpretation semantics for this word are undefined.
; 
; Execution:
; ( -- x ) ( R: x -- x )
; 
; Copy x from the return stack to the data stack. 


; 
; https://forth-standard.org/standard/core/TwoRFetch
; 
; 6.2.0415 2R@ two-r-fetch CORE EXT
; Interpretation:
; Interpretation semantics for this word are undefined.
; 
; Execution:
; ( -- x1 x2 ) ( R: x1 x2 -- x1 x2 )
; 
; Copy cell pair x1 x2 from the return stack. Semantically equivalent to R> R> 2DUP >R >R SWAP. 
