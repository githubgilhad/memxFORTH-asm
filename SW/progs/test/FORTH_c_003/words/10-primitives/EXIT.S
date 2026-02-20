DEFWORD w_exit,			0,		"exit",			f_exit			; ( XX ) exit from word
DEFWORD w_EXIT,			0,		"EXIT",			f_exit			; ( XX ) synonymum exit, not catched by show (for exit in middle od WORD)

; EXIT - exit from word
.section CURRENT_TEXT_SECTION,"ax",@progbits
gfunc f_exit	; {{{ #
	jmp EXIT
	; }}}

