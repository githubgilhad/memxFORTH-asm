; .. vim: ft=asm showbreak=--»\  noexpandtab fileencoding=utf-8 nomodified   wrap textwidth=0 foldmethod=marker foldmarker={{{,}}} foldcolumn=4 ruler showcmd lcs=tab\:|- list tabstop=8 noexpandtab nosmarttab softtabstop=0 shiftwidth=0 linebreak  

DEFWORD w_INTERPRET,		0,		"INTERPRET",		f_docol, yes		; ( -- )  : INTERPRET ... ; 

;	P24 w_BEGIN_cw
2: ; BEGIN
	
	P24 w_PARSE_NAME_cw	;    ( -- c-addr u )
	
	P24 w_DUP_cw
	P24 w_zero_equals_cw
;	P24 w_IF_cw		; (3) nothing to do
	P24 w_0BRANCH_cw
	P24 3f - .
	
	P24 w_2DROP_cw
	P24 w_EXIT_cw		; nic ke zpracování
;	P24 w_THEN_cw
3: ; IF				; 3: nothing to do
	P24 w_FIND_NAME_cw
	P24 w_qDUP_cw		;  ( c-addr u --  c-addr u xt flag flag | c-addr u 0 )
	
;	P24 w_IF_cw		; (3) word found
	P24 w_0BRANCH_cw
	P24 3f - .
	
	P24 w_2toR_cw
	P24 w_2DROP_cw
	P24 w_2Rfrom_cw		; zahodit jméno a delku, zbyde  xt flag
	
	P24 var_TCB_STATE_cw
	P24 w_char_at_cw
	
;	P24 w_IF_cw		; (4) state 
	P24 w_0BRANCH_cw
	P24 4f - .
	
	P24 w_one_equals_cw
;	P24 w_IF_cw		; (5) IMMEDIATE
	P24 w_0BRANCH_cw
	P24 5f - .
	
	P24 w_EXECUTE_cw
	
;	P24 w_ELSE_cw		; 5:(6) IMMEDIATE
	P24 w_BRANCH_cw
	P24 6f - .
5:
	
	P24 w_COMPILEcomma_cw
	
;	P24 w_THEN_cw
6:				; 6:	; IMMEDIATE
	
;	P24 w_ELSE_cw		; 4:(5) state
	P24 w_BRANCH_cw
	P24 5f - .
4:
	
	P24 w_DROP_cw		; (xt flag -- xt)
	P24 w_EXECUTE_cw
	
;	P24 w_THEN_cw
5:				; 5: state

;	P24 w_ELSE_cw		; 3:(4) word found  
	P24 w_BRANCH_cw
	P24 4f - .
3:

	P24 w_2DUP_cw
	P24 w_NUMBER_cw
	
;	P24 w_IF_cw		; (5) number
	P24 w_0BRANCH_cw
	P24 5f - .
	
	P24 w_NIP_cw
	P24 w_NIP_cw
	
	P24 var_TCB_STATE_cw
	P24 w_char_at_cw
;	P24 w_IF_cw		; (6) state_num
	P24 w_0BRANCH_cw
	P24 6f - .

	P24 w_LITERAL_cw

				; ELSE -6- left number on stack
;	P24 w_THEN_cw
6: 				; 6: state_num

;	P24 w_ELSE_cw		; 5:(6) number
	P24 w_BRANCH_cw
	P24 6f - .
5: 

	P24 w_CERROR_cw		; ( c-addr u -- )
	P24 w_EXIT_cw

;	P24 w_THEN_cw
6:				; 6: number

;	P24 w_THEN_cw
4:				; 4: word found

;	P24 w_AGAIN_cw		; 2
	P24 w_BRANCH_cw
	P24 2b - .
;	P24 w_exit_cw		; no exit here

;;	: INTERPRET  ( -- )
;;		BEGIN					\ 2: 
;;			PARSE-NAME			\    ( -- c-addr u )
;;			DUP 0= IF			\ (3)
;;				2DROP EXIT		\ nic ke zpracování
;;			THEN				\ 3:
;;			
;;			FIND-NAME ?DUP			\ ( c-addr u --  c-addr u xt flag flag | c-addr u 0 )
;;			IF				\ (3) word found
;;				2>R 2DROP 2R>		\ zahodit jméno a delku, zbyde  xt flag
;;				STATE C@ 
;;				IF			\ (4) state (0=interpret, 1=compile)
;;					1= IF		\ (5) IMMEDIATE
;;						EXECUTE
;;					ELSE		\ 5:(6) IMMEDIATE
;;						COMPILE,
;;					THEN		\ 6: IMMEDIATE
;;				ELSE			\ 4:(5) state 
;;					DROP		\ (xt flag -- xt)
;;					EXECUTE
;;				THEN			\ 5: state
;;			ELSE				\ 3:(4) word found  // nenalezeno -> číslo?
;;				2DUP NUMBER
;;				IF			\ (5) number
;;					NIP NIP
;;					STATE C@ IF	\ (6) state_num (0=interpret, 1=compile)
;;						LITERAL
;;							\ ELSE -6- left number on stack
;;					THEN		\ 6: state_num
;;				ELSE			\ 5:(6) number
;;					CERROR		\ ( c-addr u -- )
;;					EXIT
;;				THEN			\ 6: number
;;			THEN				\ 4: word found
;;		AGAIN					\ 2
;;	;
