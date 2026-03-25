; .. vim: ft=asm showbreak=--»\  noexpandtab fileencoding=utf-8 nomodified   wrap textwidth=0 foldmethod=marker foldmarker={{{,}}} foldcolumn=4 ruler showcmd lcs=tab\:|- list tabstop=8 noexpandtab nosmarttab softtabstop=0 shiftwidth=0 linebreak  tags=./tags;,tags; 


DEFWORD w_CLS,			0,		"CLS",			f_CLS			; (  --  ) clear screen, mocve cursor to 0,0 [----]

.section CURRENT_TEXT_SECTION,"ax",@progbits
gfunc f_CLS	; {{{ 
	ldi	Cpar1_lo, ' '
	ldi	Cpar2_lo, VGA_none
	call_VT_member_C	VT_cls
	rjmp NEXT
; }}}



