; .. vim: ft=asm showbreak=--»\  noexpandtab fileencoding=utf-8 nomodified   wrap textwidth=0 foldmethod=marker foldmarker={{{,}}} foldcolumn=4 ruler showcmd lcs=tab\:|- list tabstop=8 noexpandtab nosmarttab softtabstop=0 shiftwidth=0 linebreak  tags=./tags;,tags; 


DEFWORD w_REBOOT,		0,		"REBOOT",		f_REBOOT		; (  --  ) reboots computer [----]

.section CURRENT_TEXT_SECTION,"ax",@progbits
gfunc f_REBOOT	; {{{ 
	cli
	jmp 0
; }}}



