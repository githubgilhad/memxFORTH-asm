; .. vim: ft=asm showbreak=--»\  noexpandtab fileencoding=utf-8 nomodified   wrap textwidth=0 foldmethod=marker foldmarker={{{,}}} foldcolumn=4 ruler showcmd lcs=tab\:|- list tabstop=8 noexpandtab nosmarttab softtabstop=0 shiftwidth=0 linebreak  tags=./tags;,tags; 


DEFWORD w_VARIABLE,		0,		"VARIABLE",		f_VARIABLE		; ( "name" --  ) create variable [----] { VARIABLE test 	12 test ! test @ ( -- 12 ) }

.section CURRENT_TEXT_SECTION,"ax",@progbits
gfunc f_VARIABLE	; {{{ # FIXME
	call	func_CREATE					; CREATE
	TCB_member	TCB_HERE	; &HERE
		RB3at			; value of HERE
	Set3 Zx,Parsx
	Set3 Parsx, r1,r1,r1					; 0 ,
	call W3at			;
	Set3 Parsx,Zx
	TCB_member	TCB_HERE	; &HERE
		RW3at			; update value of HERE	; ;
	jmp NEXT
; }}}



