; .. vim: ft=asm showbreak=--»\  noexpandtab fileencoding=utf-8 nomodified   wrap textwidth=0 foldmethod=marker foldmarker={{{,}}} foldcolumn=4 ruler showcmd lcs=tab\:|- list tabstop=8 noexpandtab nosmarttab softtabstop=0 shiftwidth=0 linebreak  


DEFWORD w_TYPE,			0,		"TYPE",			f_TYPE			; ( c-addr u --  ) EMITs string [2310]

.section CURRENT_TEXT_SECTION,"ax",@progbits
gfunc f_TYPE	; {{{ # 
	PopST_Zx
	breq3 TOS, .f_TYPE.end
.f_TYPE.loop:
	call	B1at
	mov	r24,Parsx_lo
	push r30
	push r31
	call	TX0_Write
	pop r31
	pop r30
	ldi	Temp,1
	Sub31	TOS, Temp
	brne	.f_TYPE.loop
.f_TYPE.end:
	PopST	TOS
	jmp NEXT
; }}}


; https://forth-standard.org/standard/core/TYPE
; 
; 6.1.2310 TYPE CORE
; ( c-addr u -- )
; 
; If u is greater than zero, display the character string specified by c-addr and u.
; 
; When passed a character in a character string whose character-defining bits have a value between hex 20 and 7E inclusive, the corresponding standard character, specified by 3.1.2.1 Graphic characters, is displayed. Because different output devices can respond differently to control characters, programs that use control characters to perform specific functions have an environmental dependency.
; 
