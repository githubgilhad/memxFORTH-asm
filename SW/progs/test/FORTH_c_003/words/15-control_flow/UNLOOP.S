; .. vim: ft=asm showbreak=--»\  noexpandtab fileencoding=utf-8 nomodified   wrap textwidth=0 foldmethod=marker foldmarker={{{,}}} foldcolumn=4 ruler showcmd lcs=tab\:|- list tabstop=8 noexpandtab nosmarttab softtabstop=0 shiftwidth=0 linebreak  
DEFWORD w_UNLOOP,		0,		"UNLOOP",		f_docol, yes		; ( -- ) remove one level of DO..LOOP to eventually enable EXIT
	P24 w_2RDROP_cw
	P24 w_exit_cw

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
