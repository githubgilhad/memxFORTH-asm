; .. vim: ft=asm showbreak=--»\  noexpandtab fileencoding=utf-8 nomodified   wrap textwidth=0 foldmethod=marker foldmarker={{{,}}} foldcolumn=4 ruler showcmd lcs=tab\:|- list tabstop=8 noexpandtab nosmarttab softtabstop=0 shiftwidth=0 linebreak  tags=./tags;,tags; 


DEFWORD w_VALUE,		0,		"VALUE",		f_VALUE			; ( "name" val  --  ) create value [----] { 12 VALUE test 	test ( -- 12 ) }
DEFWORD w_TO,			0,		"TO",			f_docol, yes		; ( "name" val  --  ) change value [----] { 24 TO test 	test ( -- 24 ) }
	P24s w_tick_cw, w_one_cw, w_CELLS_plus_cw, w_store_cw, w_exit_cw	; ' 1 CELLS+ !

.section CURRENT_TEXT_SECTION,"ax",@progbits
gfunc f_VALUE	; {{{ 
	call	func_CREATE
	TCB_member	TCB_HERE	; &HERE
		RB3at			; value of HERE
	Set3 Zx,Parsx
	ldi	Tx,	3
	Sub31	Zx,	Tx
	Ldi3 Parsx, f_CONST3
	call W3at			;
	Set3 Parsx, TOS
	call W3at			;
	Set3 Parsx,Zx
	TCB_member	TCB_HERE	; &HERE
		RW3at			; update value of HERE
	PopST	TOS
	jmp NEXT
; }}}




