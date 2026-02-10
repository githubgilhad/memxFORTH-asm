; .. vim: ft=asm showbreak=--»\  noexpandtab fileencoding=utf-8 nomodified   wrap textwidth=0 foldmethod=marker foldmarker={{{,}}} foldcolumn=4 ruler showcmd lcs=tab\:|- list tabstop=8 noexpandtab nosmarttab softtabstop=0 shiftwidth=0 linebreak  


DEFWORD w_LEAVE, FLG_IMMEDIATE + FLG_ARG_3,	"LEAVE",		f_LEAVE			; ( -- ) ( R: loop-sys -- ) leave loop TODO compilation

.section CURRENT_TEXT_SECTION,"ax",@progbits
gfunc f_LEAVE	; {{{ # FIXME
	TCB_member TCB_STATE
		RB1at	; 0 Interpret, 1 Compiling
	tst	Parsx_lo
	brne	.f_LEAVE.Compiling
			; Interpret
			; end of loop
	PopR	Parsx
	PopR	Parsx
	Set3 Zx, IP
	call B3at
	Add3 IP, Parsx
	rjmp NEXT

.f_LEAVE.Compiling:	; FIXME
	rjmp NEXT
; }}}

; https://forth-standard.org/standard/core/LEAVE
; 
; 6.1.1760 LEAVE CORE
; Interpretation:
; Interpretation semantics for this word are undefined.
; 
; Execution:
; ( -- ) ( R: loop-sys -- )
; 
; Discard the current loop control parameters. An ambiguous condition exists if they are unavailable. Continue execution immediately following the innermost syntactically enclosing DO...LOOP or DO...+LOOP.
; 
; See:
; 3.2.3.3 Return stack, 6.1.0140 +LOOP, 6.1.1800 LOOP, A.6.1.1760 LEAVE.
; 
; Rationale:
; Note that LEAVE immediately exits the loop. No words following LEAVE within the loop will be executed. Typical use:
; 
;    : X ... DO ... IF ... LEAVE THEN ... LOOP ... ; 
