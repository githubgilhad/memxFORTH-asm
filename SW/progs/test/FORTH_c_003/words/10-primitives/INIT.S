; .. vim: ft=asm showbreak=--»\  noexpandtab fileencoding=utf-8 nomodified   wrap textwidth=0 foldmethod=marker foldmarker={{{,}}} foldcolumn=4 ruler showcmd lcs=tab\:|- list tabstop=8 noexpandtab nosmarttab softtabstop=0 shiftwidth=0 linebreak  

DEFWORD w_INIT,			0,		"INIT",			f_INIT			; (  -- ) Set stacks and all other data to init values

.section CURRENT_TEXT_SECTION,"ax",@progbits
gfunc f_INIT	; {{{ # TODO
	Ldi2i	Zx2, PROMPT_X
	ldi Temp, 5
	st Z, Temp
	Ldi2i	Zx2, PROMPT_Y
	ldi Temp, 10
	st Z, Temp
	;
	Ldi2i	Zx2, RX0_Count
	ldi Temp, 12
	st Z, Temp
	Ldi2i	Zx2, RX0_Head
	ldi Temp, 12
	st Z, Temp
	Ldi2i	Zx2, RX0_Buffer
	ldi Temp, '$'
	st Z+, Temp
	ldi Temp, '1'
	st Z+, Temp
	ldi Temp, '2'
	st Z+, Temp
	ldi Temp, '3'
	st Z+, Temp
	ldi Temp, '4'
	st Z+, Temp
	ldi Temp, '5'
	st Z+, Temp
	ldi Temp, '6'
	st Z+, Temp
	ldi Temp, ' '
	st Z+, Temp
	ldi Temp, '.'
	st Z+, Temp
	ldi Temp, 'h'
	st Z+, Temp
	ldi Temp, 10
	st Z+, Temp
	ldi Temp, 13
	st Z+, Temp
	rjmp NEXT
	; }}}

