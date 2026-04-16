; .. vim: ft=asm showbreak=--»\  noexpandtab fileencoding=utf-8 nomodified   wrap textwidth=0 foldmethod=marker foldmarker={{{,}}} foldcolumn=4 ruler showcmd lcs=tab\:|- list tabstop=8 noexpandtab nosmarttab softtabstop=0 shiftwidth=0 linebreak  

DEFWORD w_comma,		0,		",",			f_comma			; ( x --  ) compile x at HERE (3B)
DEFWORD w_Ccomma,		0,		"C,",			f_Ccomma		; ( c --  ) compile c at HERE (1B)

.section CURRENT_TEXT_SECTION,"ax",@progbits
gfunc f_comma	; {{{ #
	TCB_member	TCB_HERE
			RB3at
		Set3	Zx, Parsx
		Set3	Parsx, TOS
			RW3at
		Set3	Parsx, Zx
	TCB_member	TCB_HERE
			RW3at
		PopST	TOS
	jmp NEXT
	; }}}
gfunc f_Ccomma	; {{{ #
	TCB_member	TCB_HERE
			RB3at
		Set3	Zx, Parsx
		Set3	Parsx, TOS
			RW1at
		Set3	Parsx, Zx
	TCB_member	TCB_HERE
			RW3at
		PopST	TOS
	jmp NEXT
	; }}}

; https://forth-standard.org/standard/core/Comma
; 
; 6.1.0150 , comma CORE
; ( x -- )
; 
; Reserve one cell of data space and store x in the cell. If the data-space pointer is aligned when , begins execution, it will remain aligned when , finishes execution. An ambiguous condition exists if the data-space pointer is not aligned prior to execution of ,.
; 
; See:
; 3.3.3 Data space, 3.3.3.1 Address alignment, A.6.1.0150 ,.
; 
; R_ationale:
; The use of , (comma) for compiling execution tokens is not portable.
; 
; See: 6.2.0945 COMPILE,. 

