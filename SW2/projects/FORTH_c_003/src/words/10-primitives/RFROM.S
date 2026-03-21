; .. vim: ft=asm showbreak=--»\  noexpandtab fileencoding=utf-8 nomodified   wrap textwidth=0 foldmethod=marker foldmarker={{{,}}} foldcolumn=4 ruler showcmd lcs=tab\:|- list tabstop=8 noexpandtab nosmarttab softtabstop=0 shiftwidth=0 linebreak  

DEFWORD w_Rfrom,		0,		"R>",			f_Rfrom			; (  -- x ) ( R: x -- ) move CELL from return stack to data stack
DEFWORD w_2Rfrom,		0,		"2R>",			f_2Rfrom		; (  -- x y ) ( R: x y -- ) move 2 CELLs from return stack to data stack (in order)

DEFWORD w_Lfrom,		0,		"L>",			f_Lfrom			; (  -- x ) ( L: x -- ) move CELL from L stack to data stack
DEFWORD w_2Lfrom,		0,		"2L>",			f_2Lfrom		; (  -- x y ) ( L: x y -- ) move 2 CELLs from L stack to data stack (in order)

.section CURRENT_TEXT_SECTION,"ax",@progbits
gfunc f_Rfrom	; {{{ #
	PushST TOS
	PopR_x   TOS
	jmp   NEXT
; }}}
gfunc f_2Rfrom	; {{{ #
	PushST     TOS
	PopR_x       TOS
	PopR_x       Parsx
	PushST     Parsx
	jmp       NEXT
; }}}

gfunc f_Lfrom	; {{{ #
	PushST TOS
	PopL_x   TOS
	jmp   NEXT
; }}}
gfunc f_2Lfrom	; {{{ #
	PushST     TOS
	PopL_x       TOS
	PopL_x       Parsx
	PushST     Parsx
	jmp       NEXT
; }}}



; https://forth-standard.org/standard/core/Rfrom
; 
; 6.1.2060 R> r-from CORE
; Interpretation:
; Interpretation semantics for this word are undefined.
; 
; Execution:
; ( -- x ) ( R: x -- )
; 
; Move x from the return stack to the data stack. 
