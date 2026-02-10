; .. vim: ft=asm showbreak=--»\  noexpandtab fileencoding=utf-8 nomodified   wrap textwidth=0 foldmethod=marker foldmarker={{{,}}} foldcolumn=4 ruler showcmd lcs=tab\:|- list tabstop=8 noexpandtab nosmarttab softtabstop=0 shiftwidth=0 linebreak  


DEFWORD w_LOOP,		FLG_IMMEDIATE,		"LOOP",			f_LOOP			; Compilation ( C: do-sys --  ) compile 'do_loop' to definition ; Compilation: ( C: do-sys -- ) TODO compilation
DEFWORD ww_do_loop,	FLG_HIDDEN+FLG_ARG_3,	"do_loop",		do_loop		line=2	; Runtime: ( -- ) ( R: loop-sys1 -- | loop-sys2 ) inc 'first' and maybe loop 

.section CURRENT_TEXT_SECTION,"ax",@progbits
gfunc f_LOOP	; {{{ # FIXME				FIXME: IMMEDIATE slova se typicky chovaji stejne (nebo nefunguji v interpretu), ale zakoduji do nove definice sve pomocne do_*** verze, ktere jsou zcela jine a funguji jen zakodovane ve slove. !!! f_LOOP <> do_LOOP (vyhledove jiny slovnik mimo ORDER/HIDDEN)
	TCB_member TCB_STATE
		RB1at	; 0 Interpret, 1 Compiling
	tst	Parsx_lo
	brne	.f_LOOP.Compiling
			; Interpret

.f_LOOP.Compiling:	; FIXME
	rjmp NEXT
; }}}
gfunc do_loop	; {{{
	PopR	Parsx
	ldi 	Tx, 1
	Add31	Parsx, Tx
	PushR	Parsx
	ReadR_N	1, DT
	Sub3	DT,Parsx
	brne	2f
			; end of loop
	PopR	Parsx
	PopR	Parsx
	ldi	Tx,3
	Add31	IP,Tx
	rjmp NEXT
2:
			; next pass of loop
	Set3 Zx, IP
	call B3at
	Add3 IP, Parsx
	rjmp NEXT
; }}}

; https://forth-standard.org/standard/core/LOOP
; 
; 6.1.1800 LOOP CORE
; Interpretation:
; Interpretation semantics for this word are undefined.
; 
; Compilation:
; ( C: do-sys -- )
; 
; Append the run-time semantics given below to the current definition. Resolve the destination of all unresolved occurrences of LEAVE between the location given by do-sys and the next location for a transfer of control, to execute the words following the LOOP.
; 
; Run-time:
; ( -- ) ( R: loop-sys1 -- | loop-sys2 )
; 
; An ambiguous condition exists if the loop control parameters are unavailable. Add one to the loop index. If the loop index is then equal to the loop limit, discard the loop parameters and continue execution immediately following the loop. Otherwise continue execution at the beginning of the loop.
; 
; See:
; 6.1.1240 DO, 6.1.1680 I, 6.1.1760 LEAVEA.6.1.1800 LOOP.
; 
; Rationale:
; Typical use:
; 
;    : X ... limit first DO ... LOOP ... ;
; 
; or
; 
;    : X ... limit first ?DO ... LOOP ... ; 
