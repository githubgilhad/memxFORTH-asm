; .. vim: ft=asm showbreak=--»\  noexpandtab fileencoding=utf-8 nomodified   wrap textwidth=0 foldmethod=marker foldmarker={{{,}}} foldcolumn=4 ruler showcmd lcs=tab\:|- list tabstop=8 noexpandtab nosmarttab softtabstop=0 shiftwidth=0 linebreak  tags=./tags;,tags; 

DEFWORD w_BSTR_,		0,		"B{",			f_BSTR_			; ( "name" -- addr ) create LITSTRING like word ( -- addr len ), use with closing }B  (addr is start of characters, just after len, same for both)
DEFWORD w__BSTR,		0,		"}B",			f__BSTR			; ( addr -- ) close B{ like this: B{ NewLine 10 C, 13 C, }B   NewLine TELL 

.section CURRENT_TEXT_SECTION,"ax",@progbits

gfunc f_BSTR_	; {{{ open part, create empty CONSTSTRING
	PushST	TOS
	call	func_HEADER
	TCB_memberR3	TCB_HERE,	Parsx	; HERE
	Set3 Zx,Parsx
	Ldi3 Parsx, f_CONSTSTRING
	call W3at			; CW
	mov	Parsx_lo,	r1
	call W1at			; len
	Set3	TOS,	Zx
	TCB_memberW3	TCB_HERE,	TOS	; HERE
	jmp NEXT
; }}}
gfunc f__BSTR	; {{{ close part, compute len
	TCB_memberR3	TCB_HERE,	Parsx	; HERE
	Sub3	Parsx,	TOS			; len
	ldi	Tx,	1
	Sub31	TOS,	Tx
	Set3	Zx,	TOS
	call W1at
	PopST	TOS
	jmp	NEXT
; }}}
