; .. vim: ft=asm showbreak=--»\  noexpandtab fileencoding=utf-8 nomodified   wrap textwidth=0 foldmethod=marker foldmarker={{{,}}} foldcolumn=4 ruler showcmd lcs=tab\:|- list tabstop=8 noexpandtab nosmarttab softtabstop=0 shiftwidth=0 linebreak  


DEFWORD w_INCLUDE,		FLG_IMMEDIATE,	"INCLUDE",		f_INCLUDE		; ( "filename" --  ) include text from filename; C:( "filename" --  ) compile reading file to actual word  [----]
DEFWORD w__include_,		FLG_PSTRING,	"(include)",		f__include_	line=2	; ( <filename> --  ) interpret text from filename [----]

.section CURRENT_TEXT_SECTION,"ax",@progbits
gfunc f_INCLUDE	; {{{ # 
	TCB_memberR1	TCB_STATE,	Tx
	cpi	Tx, F_COMPILING
	brne	f_INCLUDE.interpretting
	;					; compiling
	call	func_PARSE_NAME
	TCB_memberR3	TCB_HERE,	Parsx
	Set3	Zx, Parsx
	Ldi3	Parsx, w__include__cw
	call	W3at				; compile (include)
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
gfunc f__include_	; {{{ 
	PushST	TOS
	Set3	Zx, IP
	call	B1at
	Set3	TOS, Parsx_lo, r1, r1
	mov	r0, r1
	inc	r0
	Add31	IP, r0
	PushST	IP
	Add31	IP, Parsx_lo
	call	func_2RAMSTR
	PopST	Cpar1, Tx
	call	C_SD_LOAD
	PopST	TOS
	jmp	NEXT
	
; }}}
