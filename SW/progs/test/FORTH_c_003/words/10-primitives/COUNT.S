; .. vim: ft=asm showbreak=--»\  noexpandtab fileencoding=utf-8 nomodified   wrap textwidth=0 foldmethod=marker foldmarker={{{,}}} foldcolumn=4 ruler showcmd lcs=tab\:|- list tabstop=8 noexpandtab nosmarttab softtabstop=0 shiftwidth=0 linebreak  


DEFWORD w_COUNT,		0,		"COUNT",		f_COUNT			; ( c-addr1  -- c-addr2 u2 ) counted string to string

.section CURRENT_TEXT_SECTION,"ax",@progbits
gfunc f_COUNT	; {{{ #
	Set3 Zx, TOS
	call B1at
	Set3 TOS, Zx
	PushST TOS
	Set3 TOS, Parsx_lo, r1, r1
	rjmp NEXT
; }}}

; https://forth-standard.org/standard/core/COUNT
; 
; 6.1.0980 COUNT CORE
; ( c-addr1 -- c-addr2 u )
; 
; Return the character string specification for the counted string stored at c-addr1. c-addr2 is the address of the first character after c-addr1. u is the contents of the character at c-addr1, which is the length in characters of the string at c-addr2. 
