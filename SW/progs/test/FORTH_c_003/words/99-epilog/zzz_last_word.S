; .. vim: ft=asm showbreak=--»\  noexpandtab fileencoding=utf-8 nomodified   wrap textwidth=0 foldmethod=marker foldmarker={{{,}}} foldcolumn=4 ruler showcmd lcs=tab\:|- list tabstop=8 noexpandtab nosmarttab softtabstop=0 shiftwidth=0 linebreak  


DEFWORD ww_zzz_eol_2,		0,		"zzz_eol_2",		f_zzz_eol_2,	line=2	; (  -- h ) return its head [----]
DEFWORD w_zzz_eol_1,		0,		"zzz_eol_1",		f_zzz_eol_1		; (  -- h ) return its head [----]

gobj FORTH_WORDS_END	; last address in WORDS
gobj val_of_f_docol
	.long f_docol
gobj val_of_w_exit_cw
	.long w_exit_cw
.section CURRENT_TEXT_SECTION,"ax",@progbits
gfunc f_zzz_eol_1	; {{{ 
	PushST TOS
	Ldi3i  TOS, w_zzz_eol_1
	rjmp NEXT
; }}}
gfunc f_zzz_eol_2	; {{{ 
	PushST TOS
	Ldi3i  TOS, ww_zzz_eol_2
	rjmp NEXT
; }}}


