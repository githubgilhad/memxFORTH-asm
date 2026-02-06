; .. vim: ft=asm showbreak=--»\  noexpandtab fileencoding=utf-8 nomodified   wrap textwidth=0 foldmethod=marker foldmarker={{{,}}} foldcolumn=4 ruler showcmd lcs=tab\:|- list tabstop=8 noexpandtab nosmarttab softtabstop=0 shiftwidth=0 linebreak  


DEFWORD w_zzz_last_word,	0,		"zzz_last_word",	f_zzz_last_word		; (  -- h ) return its head [----]

.section CURRENT_TEXT_SECTION,"ax",@progbits
gfunc f_zzz_last_word	; {{{ 
	PushST TOS
	Ldi3i  TOS, w_zzz_last_word
	rjmp NEXT
; }}}



