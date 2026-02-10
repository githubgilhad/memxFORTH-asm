; .. vim: ft=asm showbreak=--»\  noexpandtab fileencoding=utf-8 nomodified   wrap textwidth=0 foldmethod=marker foldmarker={{{,}}} foldcolumn=4 ruler showcmd lcs=tab\:|- list tabstop=8 noexpandtab nosmarttab softtabstop=0 shiftwidth=0 linebreak  

DEFWORD w_INIT,			0,		"INIT",			f_INIT			; (  -- ) Set stacks and all other data to init values

.section CURRENT_TEXT_SECTION,"ax",@progbits
gfunc f_INIT	; {{{ #         DT2 = X, Z needed for elpm
	Ldi2	DT2, PROMPT_X
	ldi	Tx, 5
	st	X, Tx
	Ldi2	DT2, PROMPT_Y
	ldi	Tx, 10
	st	X, Tx
	;
	Ldi2	DT2, RX0_Count
	Ldi3	Zx, f_INIT.len
	out	_SFR_IO_ADDR(EIND), Z_hlo
	elpm	Tx, Z+
	st	X, Tx
	Ldi2i	DT2, RX0_Head
	st	X, Tx
	Ldi2i	DT2, RX0_Buffer
;				Ldi3	Zx, f_INIT.data	; DT2 = X
2:
	elpm	Temp_lo, Z+
	st	X+, Temp_lo
	subi	Tx, 1
	brne	2b
	rjmp	NEXT
; }}}
f_INIT.len:
	.byte 2f - . - 1
f_INIT.data:
;	.ascii "CLS : foo $123456 .h ; foo \r"	; "CLS $123456 .h 10 EMIT TEST \r"
	.ascii " : foo 1 2 3  ; WORDS \r "	; "CLS $123456 .h 10 EMIT TEST \r"
2:
.balign 2

