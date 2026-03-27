; .. vim: ft=asm showbreak=--»\  noexpandtab fileencoding=utf-8 nomodified   wrap textwidth=0 foldmethod=marker foldmarker={{{,}}} foldcolumn=4 ruler showcmd lcs=tab\:|- list tabstop=8 noexpandtab nosmarttab softtabstop=0 shiftwidth=0 linebreak  tags=./tags;,tags; 


DEFWORD w_ISINSTR,		0,		"ISINSTR",		f_ISINSTR		; ( char addr len  -- flag ) if char is in string
DEFWORD w_POS,			0,		"POS",			f_POS			; ( char addr len  -- (pos) flag ) return flag and if found also zero based position

.section CURRENT_TEXT_SECTION,"ax",@progbits
gfunc f_ISINSTR	; {{{
	PopST	Zx
	PopST	Temp
2:
	tst	TOS_lo
	breq	3f
	dec	TOS_lo
	call	B1at
	cpse	Parsx_lo, Temp_lo
	rjmp	2b
	ldi	Tx,	0xFF
	Set3	TOS, Tx,Tx,Tx
	rjmp	4f
3:
	Set3	TOS, r1,r1,r1
4:
	jmp NEXT
; }}}
gfunc f_POS	; {{{
	PopST	Zx
	PopST	Temp
	mov	TOS_hi,	r1
2:
	inc	TOS_hi
	tst	TOS_lo
	breq	3f
	dec	TOS_lo
	call	B1at
	cpse	Parsx_lo, Temp_lo
	rjmp	2b
	dec	TOS_hi
	PushST	TOS_hi,r1,r1
	ldi	Tx,	0xFF
	Set3	TOS, Tx,Tx,Tx
	rjmp	4f
3:
	Set3	TOS, r1,r1,r1
4:
	jmp NEXT
; }}}



