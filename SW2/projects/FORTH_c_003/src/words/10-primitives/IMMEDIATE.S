; .. vim: ft=asm showbreak=--»\  noexpandtab fileencoding=utf-8 nomodified   wrap textwidth=0 foldmethod=marker foldmarker={{{,}}} foldcolumn=4 ruler showcmd lcs=tab\:|- list tabstop=8 noexpandtab nosmarttab softtabstop=0 shiftwidth=0 linebreak  tags=./tags;,tags; 


DEFWORD w_IMMEDIATE,		FLG_IMMEDIATE,	"IMMEDIATE",		f_IMMEDIATE		; (  --  ) mark last defined word as IMMEDIATE [----]

.section CURRENT_TEXT_SECTION,"ax",@progbits
gfunc f_IMMEDIATE	; {{{ # FIXME
	TCB_memberR3	TCB_WL_CURRENT, Parsx
	Set3 Zx,Parsx
	call B3at			; Parsx = wid->, Last
	ldi Tx,3
	Add31 Parsx,Tx
	Set3 Zx,Parsx
	call B1at
	ori Parsx_lo,FLG_IMMEDIATE
	ldi Tx,1
	Sub31 Zx,Tx
	call W1at
	jmp NEXT
; }}}



