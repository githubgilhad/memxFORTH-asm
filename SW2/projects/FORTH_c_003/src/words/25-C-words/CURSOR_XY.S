; .. vim: ft=asm showbreak=--»\  noexpandtab fileencoding=utf-8 nomodified   wrap textwidth=0 foldmethod=marker foldmarker={{{,}}} foldcolumn=4 ruler showcmd lcs=tab\:|- list tabstop=8 noexpandtab nosmarttab softtabstop=0 shiftwidth=0 linebreak  


DEFWORD w_CURSOR_XY,		0,		"CURSOR_XY",		f_CURSOR_XY		; ( x y --  ) move cursor to x,y [xxxx]

.section CURRENT_TEXT_SECTION,"ax",@progbits
gfunc f_CURSOR_XY		; {{{ # 
	PopST	Cpar1,Tx	; r24 = x
	movw	Cpar2_lo,TOS_lo	; R22 = y
	call c_cursor_xy
	PopST TOS
	rjmp NEXT
; }}}



