; .. vim: ft=asm showbreak=--»\  noexpandtab fileencoding=utf-8 nomodified   wrap textwidth=0 foldmethod=marker foldmarker={{{,}}} foldcolumn=4 ruler showcmd lcs=tab\:|- list tabstop=8 noexpandtab nosmarttab softtabstop=0 shiftwidth=0 linebreak  

// : new_word ... ... [ executed_while_compiling ] ... ... ;
DEFWORD w_left_bracket,		FLG_IMMEDIATE,	"[",			f_left_bracket		; (  --  ) leave compilation, enter interpretation [2500]
DEFWORD w_right_bracket,	0,		"]",			f_right_bracket		; (  --  ) leave interpretation, (re)enter compilation [2540]

.section CURRENT_TEXT_SECTION,"ax",@progbits
gfunc f_left_bracket	; {{{ #
	ldi Parsx_lo, F_INTERPRETING
	TCB_member TCB_STATE
		RW1at
	rjmp NEXT
; }}}
gfunc f_right_bracket	; {{{ #
	ldi Parsx_lo, F_COMPILING
	TCB_member TCB_STATE
		RW1at
	rjmp NEXT
; }}}

; https://forth-standard.org/standard/core/Bracket
; 
; 6.1.2500 [ left-bracket CORE
; Interpretation:
; Interpretation semantics for this word are undefined.
; 
; Compilation:
; Perform the execution semantics given below.
; 
; Execution:
; ( -- )
; 
; Enter interpretation state. [ is an immediate word.
; 
; See:
; 3.4 The Forth text interpreter, 3.4.5 Compilation, 6.1.2540 ], A.6.1.2500 [.
; 
; Rationale:
; Typical use: : X ... [ 4321 ] LITERAL ... ; 


 
; https://forth-standard.org/standard/right-bracket
; 
; 6.1.2540
; ]
; right-bracket
; CORE
;  
; ( -- )
; 
; Enter compilation state.
; 
; See:
; 3.4 The Forth text interpreter, 3.4.5 Compilation, 6.1.2500 [, A.6.1.2540 ].
; 
; Rationale:
; Typical use: : X ... [ 4321 ] LITERAL ... ;
; Testing:
; See F.6.1.2500 [.
