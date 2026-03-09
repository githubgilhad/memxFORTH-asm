; .. vim: ft=asm showbreak=--»\  noexpandtab fileencoding=utf-8 nomodified   wrap textwidth=0 foldmethod=marker foldmarker={{{,}}} foldcolumn=4 ruler showcmd lcs=tab\:|- list tabstop=8 noexpandtab nosmarttab softtabstop=0 shiftwidth=0 linebreak  


DEFWORD w_yield,			0,		"yield",			f_yield			; (  --  ) yields MCU [----]

.section CURRENT_TEXT_SECTION,"ax",@progbits
gfunc f_yield	; {{{ # FIXME
	call func_yield
	jmp NEXT
; }}}
gfunc func_yield	; {{{ # FIXME
	ret
; }}}



