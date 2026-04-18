; .. vim: ft=asm showbreak=--»\  noexpandtab fileencoding=utf-8 nomodified   wrap textwidth=0 foldmethod=marker foldmarker={{{,}}} foldcolumn=4 ruler showcmd lcs=tab\:|- list tabstop=8 noexpandtab nosmarttab softtabstop=0 shiftwidth=0 linebreak  


DEFWORD w_CELLS,		0,		"CELLS",		f_CELLS			; ( a -- b ) b = a * CELL_size
DEFWORD w_CELLS_plus,		0,		"CELLS+",		f_CELLS_plus		; ( a b -- c ) c = a + b * CELL_size (Usage: ARRAY_A index CELLS+ @ = value at  ARRAY_A[index] )
DEFWORD w_Cto3B,		0,		"C>3B",			f_Cto3B			; ( a -- lo hi hlo ) expand Cell to 3 BYTES
DEFWORD w_3BtoC,		0,		"3B>C",			f_3BtoC			; ( lo hi hlo -- a ) implode 3 BYTES to Cell

.section CURRENT_TEXT_SECTION,"ax",@progbits
gfunc f_CELLS	; {{{ #
	Set3 Parsx, TOS		; CELL_size = 3
	Add3 TOS,Parsx
	Add3 TOS,Parsx
	jmp NEXT
; }}}
gfunc f_CELLS_plus	; {{{ #
	Set3 Parsx, TOS		; CELL_size = 3
	Add3 TOS,Parsx
	Add3 TOS,Parsx
	PopST Parsx
	Add3 TOS,Parsx
	jmp NEXT
; }}}
gfunc f_Cto3B	; {{{
	Set3	Parsx,	TOS_lo,r1,r1
	PushST	Parsx
	mov	Parsx_lo,	TOS_hi
	PushST	Parsx
	mov	Parsx_lo,	TOS_hlo
	Set3	TOS,	Parsx
	jmp	NEXT
; }}}

gfunc f_3BtoC	; {{{
	mov	TOS_hlo,	TOS_lo
	PopST	Parsx
	mov	TOS_hi,	Parsx_lo
	PopST	Parsx
	mov	TOS_lo,	Parsx_lo
	jmp	NEXT
; }}}
