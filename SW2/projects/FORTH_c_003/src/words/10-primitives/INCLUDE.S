; .. vim: ft=asm showbreak=--»\  noexpandtab fileencoding=utf-8 nomodified   wrap textwidth=0 foldmethod=marker foldmarker={{{,}}} foldcolumn=4 ruler showcmd lcs=tab\:|- list tabstop=8 noexpandtab nosmarttab softtabstop=0 shiftwidth=0 linebreak  


DEFWORD w_INCLUDE,	FLG_IMMEDIATE,		"INCLUDE",		f_INCLUDE		; ( "filename" --  ) include text from filename; C:( "filename" --  ) compile reading file to actual word  [----]
DEFWORD ww_do_INCLUDE,	FLG_PSTRING,		"do_INCLUDE",		f_do_INCLUDE	line=2	; ( <filename> --  ) interpret text from filename [----]

.section CURRENT_TEXT_SECTION,"ax",@progbits
gfunc f_INCLUDE	; {{{ # 
	TCB_memberR1	TCB_STATE,	Tx
	cpi	Tx, F_COMPILING
	brne	f_INCLUDE.interpretting
	;					; compiling
	call	func_PARSE_NAME
	TCB_memberR3	TCB_HERE,	Parsx
	Set3	Zx, Parsx
	Ldi3	Parsx, ww_do_INCLUDE_cw
	call	W3at				; compile do_INCLUDE
	Set1	Parsx_lo, TOS_lo
	call	W1at				; compile len
	PopST	DT
2:
	tst	TOS_lo				; compile filename
	breq	3f
	ld	Parsx_lo, X+
	call	W1at
	dec	TOS_lo
	rjmp	2b
3:
	Set3	Parsx, Zx
	TCB_memberW3	TCB_HERE, Parsx
	PopST	TOS
	jmp	NEXT
f_INCLUDE.interpretting:
	call	func_PARSE_NAME
	PopST	Cpar1, Tx
	call	C_SD_LOAD
	PopST	TOS
	jmp	NEXT
; }}}
gfunc f_do_INCLUDE	; {{{ # FIXME 
	
; }}}
