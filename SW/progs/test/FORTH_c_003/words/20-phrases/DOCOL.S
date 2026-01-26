DEFWORD w_docol,	0,	"docol",	f_docol	// enter colon word

; DOCOL - enter colon word
.section CURRENT_TEXT_SECTION,"ax",@progbits
.global f_docol
f_docol:	; {{{ #
	rjmp DOCOL
	; }}}

