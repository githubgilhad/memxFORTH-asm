; .. vim: ft=asm showbreak=--»\  noexpandtab fileencoding=utf-8 nomodified   wrap textwidth=0 foldmethod=marker foldmarker={{{,}}} foldcolumn=4 ruler showcmd lcs=tab\:|- list tabstop=8 noexpandtab nosmarttab softtabstop=0 shiftwidth=0 linebreak  


DEFWORD w_NEXTcounter,		0,		"NEXTcounter",		f_NEXTcounter		; (  -- x1 x2  ) returns NEXTcounter as Double (# of jumps to NEXT)  [xxxx]

.section CURRENT_TEXT_SECTION,"ax",@progbits
gfunc f_NEXTcounter	; {{{ # 
	PushST TOS
	Lds3 TOS,NEXTcounter
	PushST TOS
	Lds3 TOS,NEXTcounter+3
	jmp NEXT
; }}}



