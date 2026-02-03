; .. vim: ft=asm showbreak=--»\  noexpandtab fileencoding=utf-8 nomodified   wrap textwidth=0 foldmethod=marker foldmarker={{{,}}} foldcolumn=4 ruler showcmd lcs=tab\:|- list tabstop=8 noexpandtab nosmarttab softtabstop=0 shiftwidth=0 linebreak  

DEFWORD w_INTERPRET,		0,		"INTERPRET",		f_docol, yes		; ( -- )  : INTERPRET ... ; 

;	P24 w_BEGIN_cw
2: ; BEGIN
	P24 w_PARSE_NAME_cw
	P24 w_DUP_cw
	P24 w_zero_equals_cw
;	P24 w_IF_cw	; nothing to do
	P24 w_0BRANCH_cw
	P24 3f - .
	P24 w_2DROP_cw
	P24 w_EXIT_cw
;	P24 w_THEN_cw
3: ; IF			; nothing to do
	P24 w_2DUP_cw
	P24 w_FIND_NAME_cw
	P24 w_qDUP_cw
;	P24 w_IF_cw	; word found
	P24 w_0BRANCH_cw
	P24 3f - .
	P24 w_LIT3_cw
	P24 3
	P24 w_DROPat_cw
	P24 w_LIT3_cw
	P24 3
	P24 w_DROPat_cw
	P24 var_TCB_STATE_cw
	P24 w_char_at_cw
;	P24 w_IF_cw	; state 
	P24 w_0BRANCH_cw
	P24 4f - .
	P24 w_one_equals_cw
;	P24 w_IF_cw	; IMMEDIATE
	P24 w_0BRANCH_cw
	P24 5f - .
	P24 w_EXECUTE_cw
;	P24 w_ELSE_cw	; IMMEDIATE
	P24 w_BRANCH_cw
	P24 6f - .
5: ; IF-ELSE		; IMMEDIATE
	P24 w_COMPILEcomma_cw
;	P24 w_THEN_cw
6: ; IF-ELSE-THEN	; IMMEDIATE
;	P24 w_ELSE_cw
	P24 w_BRANCH_cw
	P24 5f - .
4: ; IF-ELSE		; state
	P24 w_DROP_cw
	P24 w_EXECUTE_cw
;	P24 w_THEN_cw
3: ; IF-ELSE-THEN	; state
;	P24 w_ELSE_cw
	P24 w_BRANCH_cw
	P24 3f - .
5: ; IF-ELSE		; word found
	P24 w_2DUP_cw
	P24 w_NUMBER_cw
;	P24 w_IF_cw	; number
	P24 w_0BRANCH_cw
	P24 4f - .
	P24 w_NIP_cw
	P24 w_NIP_cw
	P24 var_TCB_STATE_cw
	P24 w_char_at_cw
;	P24 w_IF_cw	; state
	P24 w_0BRANCH_cw
	P24 5f - .
	P24 w_LITERAL_cw
;	P24 w_THEN_cw
5: ; IF-THEN		; state
;	P24 w_ELSE_cw
	P24 w_BRANCH_cw
	P24 5f - .
4: ; IF-ELSE		; number
	P24 w_CERROR_cw
	P24 w_EXIT_cw
;	P24 w_THEN_cw
5: ; IF-ELSE-THEN	; number
;	P24 w_THEN_cw
3: ; IF-ELSE-THEN	; word found
;	P24 w_AGAIN_cw
	P24 w_BRANCH_cw
	P24 2b - .
;	P24 w_exit_cw

;;	: INTERPRET  ( -- )
;;	  BEGIN
;;	    PARSE-NAME        \ c-addr u
;;	    DUP 0= IF
;;	      2DROP EXIT      \ nic ke zpracování
;;	    THEN
;;	
;;	    2DUP FIND-NAME ?DUP    \ c-addr u xt flag flag | c-addr u 0
;;	    IF                \ nalezeno slovo
;;	      3 DROP@ 3 DROP@ \ zahodit jméno a delku, zbyde  xt flag
;;	      STATE C@ 
;;	      IF
;;	        1= IF         \ IMMEDIATE
;;	           EXECUTE
;;	        ELSE
;;	           COMPILE,      \ kompilace xt
;;	        THEN
;;	      ELSE
;;	        DROP           \ (xt flag -- xt)
;;	        EXECUTE
;;	      THEN
;;	    ELSE               \ nenalezeno -> číslo?  TODO
;;	      2DUP NUMBER
;;	      IF
;;	        NIP NIP
;;	        STATE C@ IF
;;	          LITERAL
;;	        \ ELSE
;;	        \ left number on stack
;;	        THEN
;;	      ELSE
;;	        CERROR ( c-addr u -- )
;;	        EXIT
;;	      THEN
;;	    THEN
;;	  AGAIN ;
