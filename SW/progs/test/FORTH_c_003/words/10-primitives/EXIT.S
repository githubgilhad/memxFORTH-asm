DEFWORD w_exit,		0,	"exit",		f_exit	// exit from word

; EXIT - exit from word
.section CURRENT_TEXT_SECTION,"ax",@progbits
.global f_exit
f_exit:	; {{{ #
	rjmp EXIT
	; }}}

