; .. vim: ft=asm showbreak=--»\  noexpandtab fileencoding=utf-8 nomodified   wrap textwidth=0 foldmethod=marker foldmarker={{{,}}} foldcolumn=4 ruler showcmd lcs=tab\:|- list tabstop=8 noexpandtab nosmarttab softtabstop=0 shiftwidth=0 linebreak  tags=./tags;,tags; 


DEFWORD w_SPACE,		0,		"SPACE",		f_SPACE		; (  -- ) push and EMIT SPACE

.section CURRENT_TEXT_SECTION,"ax",@progbits
gfunc f_SPACE	; {{{
	ldi	Cpar1_lo,	32
	call_VT_member_C	VT_write_char
	jmp NEXT
; }}}



