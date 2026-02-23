; .. vim: ft=asm showbreak=--»\  noexpandtab fileencoding=utf-8 nomodified   wrap textwidth=0 foldmethod=marker foldmarker={{{,}}} foldcolumn=4 ruler showcmd lcs=tab\:|- list tabstop=8 noexpandtab nosmarttab softtabstop=0 shiftwidth=0 linebreak  


DEFWORD w_COLON,		0,		":",			f_COLON			; ( C: "<spaces>name" -- colon-sys ) create new word [0450]

.section CURRENT_TEXT_SECTION,"ax",@progbits
gfunc f_COLON	; {{{ # 
	TCB_member TCB_HERE
		RB3at
	PushST	Parsx
	call	func_CREATE
	PopST	Zx
	ldi	Tx,3
	Add31	Zx,Tx			; attributes
	ldi	Parsx_lo, FLG_HIDDEN
	call	W1at
	TCB_member TCB_HERE
		RB3at
	Set3	Zx, Parsx
	ldi	Tx,3
	Sub31	Zx,Tx			; code word
	Ldi3	Parsx,f_docol
	call	W3at
	ldi Parsx_lo, F_COMPILING	; ]
	TCB_member TCB_STATE
		RW1at
	rjmp NEXT
; }}}

gfunc f_docol	; {{{ #
	rjmp DOCOL
; }}}


; https://forth-standard.org/standard/core/Colon
; 
; 6.1.0450 : colon CORE
; ( C: "<spaces>name" -- colon-sys )
; 
; Skip leading space delimiters. Parse name delimited by a space. Create a definition for name, called a "colon definition". Enter compilation state and start the current definition, producing colon-sys. Append the initiation semantics given below to the current definition.
; 
; The execution semantics of name will be determined by the words compiled into the body of the definition. The current definition shall not be findable in the dictionary until it is ended (or until the execution of DOES> in some systems).
; 
; Initiation:
; ( i * x -- i * x ) ( R: -- nest-sys )
; 
; Save implementation-dependent information nest-sys about the calling definition. The stack effects i * x represent arguments to name.
; 
; name Execution:
; ( i * x -- j * x )
; 
; Execute the definition name. The stack effects i * x and j * x represent arguments to and results from name, respectively.
; 
; See:
; 3.4.3.2 Interpretation semantics, 3.4.1 Parsing, 3.4.5 Compilation, 6.1.1250 DOES>, 6.1.2500 [, 6.1.2540 ], 15.6.2.0470 ;CODE, A.6.1.0450 :.
; 
; Rationale:
; Typical use: : name ... ;
; 
; In Forth 83, this word was specified to alter the search order. This specification is explicitly removed in this standard. We believe that in most cases this has no effect; however, systems that allow many search orders found the Forth-83 behavior of colon very undesirable.
; 
; Note that colon does not itself invoke the compiler. Colon sets compilation state so that later words in the parse area are compiled. 
; 
