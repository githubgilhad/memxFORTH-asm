; .. vim: ft=asm showbreak=--»\  noexpandtab fileencoding=utf-8 nomodified   wrap textwidth=0 foldmethod=marker foldmarker={{{,}}} foldcolumn=4 ruler showcmd lcs=tab\:|- list tabstop=8 noexpandtab nosmarttab softtabstop=0 shiftwidth=0 linebreak  tags=./tags;,tags; 

DEFWORD w_BINSTR,		0,		"BINSTR",		f_BINSTR		;  ( "name" x1 x2 .. xn-1 xn n -- ) CREATE word for binary string:  save binary string (1B bytes) to memory, 10 20 30 3 BINSTR THREE create word THREE ( -- addr len ) returning string "\10\20\30"

.section CURRENT_TEXT_SECTION,"ax",@progbits
gfunc f_BINSTR	; {{{ 
	call	func_CREATE
	TCB_member	TCB_HERE	; &HERE
		RB3at			; value of HERE
	Set3 Zx,Parsx
	ldi	Tx,	3
	Sub31	Zx,	Tx
	Ldi3 Parsx, f_do_binstr
	call W3at			; CW
	Set3 Parsx, TOS
	call W1at			; len
	Add3	Zx,	TOS		; last byte +1
	Push3_x	Zx
	ldi	Tx,	1
	Sub31	Zx,	Tx
	ldi	Tx,2
2:
	tst	TOS_lo
	breq	3f
	PopST	Parsx
	call	W1at
	Sub31	Zx,	Tx
	dec	TOS_lo
	brne	2b
3:
	Pop3_x	Parsx
	TCB_member	TCB_HERE	; &HERE
		RW3at			; update value of HERE
	PopST	TOS
	jmp NEXT
; }}}

gfunc f_do_binstr	; {{{ ( -- addr len)
	PushST	TOS
	Set3	Zx,	DT
	adiw	DT_lo,	1
	PushST	DT
	call	B1at
	Set3	TOS, Parsx_lo,r1,r1
	jmp	NEXT
; }}}
