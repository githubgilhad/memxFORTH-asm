; .. vim: ft=asm showbreak=--»\  noexpandtab fileencoding=utf-8 nomodified   wrap textwidth=0 foldmethod=marker foldmarker={{{,}}} foldcolumn=4 ruler showcmd lcs=tab\:|- list tabstop=8 noexpandtab nosmarttab softtabstop=0 shiftwidth=0 linebreak  


DEFWORD w_CELLS,		0,		"CELLS",		f_CELLS			; ( a -- b ) b = a * CELL_size
DEFWORD w_CELLS_plus,		0,		"CELLS+",		f_CELLS_plus		; ( a b -- c ) c = a + b * CELL_size (Usage: ARRAY_A index CELLS+ @ = value at  ARRAY_A[index] )

.section CURRENT_TEXT_SECTION,"ax",@progbits
gfunc f_CELLS	; {{{ #
	Set3 Parsx, TOS		; CELL_size = 3
	Add3 TOS,Parsx
	Add3 TOS,Parsx
	rjmp NEXT
; }}}
gfunc f_CELLS_plus	; {{{ #
	Set3 Parsx, TOS		; CELL_size = 3
	Add3 TOS,Parsx
	Add3 TOS,Parsx
	PopST Parsx
	Add3 TOS,Parsx
	rjmp NEXT
; }}}



