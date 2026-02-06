; .. vim: ft=asm showbreak=--»\  noexpandtab fileencoding=utf-8 nomodified   wrap textwidth=0 foldmethod=marker foldmarker={{{,}}} foldcolumn=4 ruler showcmd lcs=tab\:|- list tabstop=8 noexpandtab nosmarttab softtabstop=0 shiftwidth=0 linebreak  


DEFWORD w_dot_hex,		0,		".h",			f_dot_hex		; ( x  --  ) print hexa value and space [xxxx]

.section CURRENT_TEXT_SECTION,"ax",@progbits
gfunc f_dot_hex	; {{{ # 
	Set3 Parsx,TOS
	call TX0_WriteHex24
	ldi r24, ' '
	call TX0_Write
	PopST TOS
	rjmp NEXT
; }}}



