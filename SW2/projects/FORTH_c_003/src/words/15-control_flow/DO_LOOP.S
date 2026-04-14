; .. vim: ft=asm showbreak=--»\  noexpandtab fileencoding=utf-8 nomodified   wrap textwidth=0 foldmethod=marker foldmarker={{{,}}} foldcolumn=4 ruler showcmd lcs=tab\:|- list tabstop=8 noexpandtab nosmarttab softtabstop=0 shiftwidth=0 linebreak  tags=./tags;,tags; 

DEFWORD w_DO,			FLG_IMMEDIATE,	"DO",			f_DO			; Compilation ( C: -- 0 do-sys ) compile '(do)' to definition
DEFWORD w__do_,			FLG_HIDDEN,	"(do)",			f__do_,		line=2	; Runtime: ( limit first -- ) ( R:  -- limit first ) set loop params
DEFWORD w_LEAVE, 		FLG_IMMEDIATE,	"LEAVE",		f_LEAVE			; Compilation ( C: backn do-sys  -- backn backn+1 do-sys ) compile '(leave)' to definition
DEFWORD w__leave_, 	FLG_HIDDEN + FLG_ARG_3,	"(leave)",		f__leave_	line=2	; Runtime: ( -- ) ( R: limit first -- ) leave loop, jump after LOOP
DEFWORD w_LOOP,			FLG_IMMEDIATE,	"LOOP",			f_LOOP			; Compilation ( C: 0 back1 .. backn do-sys --  ) compile '(loop)' to definition
DEFWORD w__loop_,	FLG_HIDDEN + FLG_ARG_3,	"(loop)",		f__loop_,	line=2	; Runtime: ( -- ) ( R: limit first -- | limit first+1 ) inc 'first' and maybe loop
DEFWORD w_PLUS_LOOP,		FLG_IMMEDIATE,	"+LOOP",		f_PLUSLOOP		; Compilation ( C: 0 back1 .. backn do-sys --  ) compile '(+loop)' to definition
DEFWORD w__plus_loop_,	FLG_HIDDEN + FLG_ARG_3,	"(+loop)",		f__plus_loop_,	line=2	; Runtime: ( x -- ) ( R: limit first -- | limit first+x ) inc 'first' by 'x' and maybe loop
DEFWORD w_UNLOOP,		0,		"UNLOOP",		f_docol, yes		; ( -- ) ( R: limit first -- ) remove one level of DO..LOOP to eventually enable EXIT
	P24 w_Rfrom_cw
	P24 w_2RDROP_cw
	P24 w_toR_cw
	P24 w_exit_cw


.section CURRENT_TEXT_SECTION,"ax",@progbits
; # README				FIXME: IMMEDIATE slova se typicky chovaji stejne (nebo nefunguji v interpretu), ale zakoduji do nove definice sve pomocne do_*** verze, ktere jsou zcela jine a funguji jen zakodovane ve slove. !!! f_LOOP <> do_LOOP (vyhledove jiny slovnik mimo ORDER/HIDDEN)
gfunc f_DO	; {{{ # 
	PushST		TOS
	PushST		r1, r1, r1
	TCB_member	TCB_HERE	; &HERE
		RB3at			; Parsx = value of HERE
	Set3		Zx, Parsx
	Ldi3		Parsx, w__do__cw
	call W3at			; compile (do) (~ 2>R)
	Set3		TOS, Zx		; jump here
	Set3		Parsx,Zx
	TCB_member	TCB_HERE	; &HERE
		RW3at			; write new HERE
	rjmp NEXT
; }}}
gfunc f__do_	; {{{
	PopST Parsx
	PushR_x Parsx
	PushR_x TOS
	PopST TOS
	rjmp NEXT
; }}}

gfunc f_LEAVE	; {{{ # 
	TCB_member	TCB_HERE	; &HERE
		RB3at			; Parsx = value of HERE
	Set3		Zx, Parsx
	Ldi3		Parsx, w__leave__cw
	call	W3at			; compile (leave) (~ BRANCH)
	Set3		Parsx, Zx
	PushST		Parsx
	Set3		Zx, Parsx
	ZERO		Parsx
	call	W3at
	Set3		Parsx,Zx
	TCB_member	TCB_HERE	; &HERE
		RW3at			; write new HERE
	rjmp NEXT
; }}}
gfunc f__leave_	; {{{ # 
	PopR_x	Parsx
	PopR_x	Parsx
	Set3 Zx, IP
	call B3at
	Add3 IP, Parsx
	rjmp NEXT
; }}}

gfunc f_LOOP	; {{{ # 
	TCB_member	TCB_HERE	; &HERE
		RB3at			; Parsx = value of HERE
	Set3		Zx, Parsx
	Ldi3		Parsx, w__loop__cw
f_LOOP.common:
	call	W3at			; compile (loop) (~ 0BRANCH)
	Set3		DT, Zx		; here we need overwrite jump distance
	Sub3		TOS, DT		; compute offset to HERE
	Set3		Parsx, TOS
	call	W3at			; compile back distance
	Set3		Parsx,Zx
	Set3		DT,Zx		; DT is HERE, need climb all nonzero, write there diference from HERE
	TCB_member	TCB_HERE	; &HERE
		RW3at			; write new HERE
2:
	PopST		TOS
	breq3		TOS, 3f		; fix all LEAVE pointers, stop on ZERO
	Set3		Zx,TOS		; write there
	Set3		Parsx,DT
	Sub3		Parsx,TOS
	call	W3at			; write offset to here
	rjmp 2b
3:
	PopST		TOS
	rjmp NEXT
; }}}
gfunc f__loop_	; {{{
	PopR_x	Parsx
	ldi 	Tx, 1
	Add31	Parsx, Tx
	PushR_x	Parsx
	ReadR_N_x	1, DT
	Sub3	DT,Parsx
	brne	2f
			; end of loop
	PopR_x	Parsx
	PopR_x	Parsx
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

gfunc f_PLUSLOOP	; {{{ # 
	TCB_member	TCB_HERE	; &HERE
		RB3at			; Parsx = value of HERE
	Set3		Zx, Parsx
	Ldi3		Parsx, w__plus_loop__cw
	rjmp	f_LOOP.common
; }}}
gfunc f__plus_loop_	; {{{
	PopR_x	Parsx
	Add3	TOS, Parsx
	PushR_x	TOS
	ReadR_N_x	1, DT		; old=Parsx, new=TOS, limit=DT
	Cmp3	DT,Parsx
	breq	f__plus_loop_.notCross	; same, departing from equal
	brsh	f__plus_loop_.oldHigher	; cannot be same, so higher
f__plus_loop_.oldLesser:
	Cmp3	DT,TOS
	brsh	f__plus_loop_.Cross	; same or higher is (arrival or) cross
	rjmp	f__plus_loop_.notCross	; both lower
f__plus_loop_.oldHigher:
	Cmp3	DT,TOS
	brlo	f__plus_loop_.Cross	; lower is cross (or departure)
;	rjmp	f__plus_loop_.notCross	; both higher (or departure) ; fall thrue
f__plus_loop_.notCross: ; next pass of loop = NOT crossed
	Set3 Zx, IP
	call B3at
	Add3 IP, Parsx
	rjmp NEXT
f__plus_loop_.Cross: ; end of loop = crossed
	PopR_x	Parsx
	PopR_x	Parsx
	ldi	Tx,3
	Add31	IP,Tx
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



; https://forth-standard.org/standard/core/UNLOOP
; 
; 6.1.2380 UNLOOP CORE
; Interpretation:
; Interpretation semantics for this word are undefined.
; 
; Execution:
; ( -- ) ( R: loop-sys -- )
; 
; Discard the loop-control parameters for the current nesting level. An UNLOOP is required for each nesting level before the definition may be EXITed. An ambiguous condition exists if the loop-control parameters are unavailable.
; 
; See:
; 3.2.3.3 Return stack, A.6.1.2380 UNLOOP.
; 
; Rationale:
; Typical use:
; : X ...
;    limit first DO
;    ... test IF ... UNLOOP EXIT THEN ...
;    LOOP ...
; ;
; 
; UNLOOP allows the use of EXIT within the context of DO ... LOOP and related do-loop constructs. UNLOOP as a function has been called UNDO. UNLOOP is more indicative of the action: nothing gets undone — we simply stop doing it. 
; 
