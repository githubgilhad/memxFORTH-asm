; .. vim: ft=asm showbreak=--»\  noexpandtab fileencoding=utf-8 nomodified   wrap textwidth=0 foldmethod=marker foldmarker={{{,}}} foldcolumn=4 ruler showcmd lcs=tab\:|- list tabstop=8 noexpandtab nosmarttab softtabstop=0 shiftwidth=0 linebreak  

; f_dovar returns address of variable value ( use @ or ! )
; ( -- addr )
.section CURRENT_TEXT_SECTION,"ax",@progbits
gfunc f_dovar	; {{{ #
	PushST TOS
	Set3 Zx, DT
	call B3at
	Set3 TOS, Parsx
	rjmp NEXT
	; }}}

; f_push_tcb_member returns address of actual TCB variable value ( use @ or ! )
; ( -- addr ) use DT 2B as TCB member offset 
gfunc f_push_tcb_member	; {{{ #
	PushST TOS
	Set3 Zx,DT
	call B2at
	Set2 TOS2,Parsx2
	add TOS_lo,TCB_lo
	adc TOS_hi,TCB_hi
	ldi Tx, 0x80
	mov TOS_hlo, Tx
	rjmp NEXT
	; }}}


