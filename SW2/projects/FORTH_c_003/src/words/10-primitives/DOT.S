; .. vim: ft=asm showbreak=--»\  noexpandtab fileencoding=utf-8 nomodified   wrap textwidth=0 foldmethod=marker foldmarker={{{,}}} foldcolumn=4 ruler showcmd lcs=tab\:|- list tabstop=8 noexpandtab nosmarttab softtabstop=0 shiftwidth=0 linebreak  


DEFWORD w_dot_hex,		0,		".h",			f_dot_hex		; ( x  --  ) print hexa value and space [xxxx]
DEFWORD w_dot,			0,		".",			f_dot			; ( x  --  ) print value

.section CURRENT_TEXT_SECTION,"ax",@progbits
gfunc f_dot_hex	; {{{ # 
	Set2 Cpar2,TOS2
	mov Cpar1_lo,TOS_hlo
	call TX0_WriteHex24
	ldi Cpar1_lo, ' '
	call TX0_Write
	PopST TOS
	jmp NEXT
; }}}

gfunc f_dot	; {{{ 
	Set2	Cpar3, TCB
	Set3	Cpar2, Cpar1_lo 	TOS
	mov	Cpar1_hi,		r1
	call	C_num2str
	Set3	DT, 		Cpar2, r1
	Set3	TOS, 		Cpar1, r1
	PushST	DT
	jmp f_TELL
; }}}


