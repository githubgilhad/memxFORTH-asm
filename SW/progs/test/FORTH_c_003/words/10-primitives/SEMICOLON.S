; .. vim: ft=asm showbreak=--»\  noexpandtab fileencoding=utf-8 nomodified   wrap textwidth=0 foldmethod=marker foldmarker={{{,}}} foldcolumn=4 ruler showcmd lcs=tab\:|- list tabstop=8 noexpandtab nosmarttab softtabstop=0 shiftwidth=0 linebreak  


DEFWORD w_SEMICOLON,		FLG_IMMEDIATE,	";",			f_SEMICOLON		; (  --  ) ends colon definition, make word visible [----]

.section CURRENT_TEXT_SECTION,"ax",@progbits
gfunc f_SEMICOLON	; {{{ # 
	TCB_member TCB_WL_CURRENT	; &TCB_WL_CURRENT
		RB3at			; &wid
	Set3 Zx,Parsx
	call B3at			; Parsx = wid->, Last
	ldi Tx,3
	Add31 Parsx,Tx
	Set3 Zx,Parsx
	call B1at
	andi Parsx_lo,~FLG_HIDDEN
	ldi Tx,1
	Sub31 Zx,Tx
	call W1at
	TCB_member	TCB_HERE	; &HERE
		RB3at			; value of HERE
	Set3 Zx,Parsx
	Ldi3 Parsx, w_exit_cw
	call W3at			; save LAST at HERE+++
	
	ldi Parsx_lo, F_INTERPRETING	; ]
	TCB_member TCB_STATE
		RW1at
	jmp NEXT
; }}}



