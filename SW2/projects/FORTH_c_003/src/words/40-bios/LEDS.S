; .. vim: ft=asm showbreak=--»\  noexpandtab fileencoding=utf-8 nomodified   wrap textwidth=0 foldmethod=marker foldmarker={{{,}}} foldcolumn=4 ruler showcmd lcs=tab\:|- list tabstop=8 noexpandtab nosmarttab softtabstop=0 shiftwidth=0 linebreak  


DEFWORD w_LEDS_set,		0,		"LEDS!",		f_LEDS_set		; ( RGB num  --  ) set LED # num to RGB and shine it [xxxx]
DEFWORD w_LEDS_get,		0,		"LEDS@",		f_LEDS_get		; ( num  -- RGB  ) get LED # num  RGB value [xxxx]

.section CURRENT_TEXT_SECTION,"ax",@progbits
gfunc f_LEDS_set	; {{{ #
	PopST	Parsx
	Ldi3	Zx, DebugLEDs_values
	Add3	Zx, TOS
	Add3	Zx, TOS
	Add3	Zx, TOS
	call	W3at
	call	DebugLEDs_show
	PopST	TOS
	rjmp NEXT
; }}}
gfunc f_LEDS_get	; {{{ #
	Ldi3	Zx, DebugLEDs_values
	Add3	Zx, TOS
	Add3	Zx, TOS
	Add3	Zx, TOS
	call	B3at
	Set3	TOS, Parsx
	rjmp NEXT
; }}}



