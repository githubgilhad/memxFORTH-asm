; .. vim: ft=asm showbreak=--»\  noexpandtab fileencoding=utf-8 nomodified   wrap textwidth=0 foldmethod=marker foldmarker={{{,}}} foldcolumn=4 ruler showcmd lcs=tab\:|- list tabstop=8 noexpandtab nosmarttab softtabstop=0 shiftwidth=0 linebreak  

DEFWORD w_QUIT,			0,		"QUIT",			f_docol, yes		; Main loop,  : QUIT INIT BEGIN BEGIN TIB TIB.max ACCEPT UNTIL INTERPRET REPEAT ;  
	P24 w_CLS_cw
	P24 w_INIT_cw
2:
	P24 var_TCB_TIB_cw
	P24 const_TCB_TIB_max_cw
	P24 w_ACCEPT_cw
	P24 w_DUP_cw
	P24 var_TCB_TIB_len_cw
	P24 w_word_store_cw
	P24 w_zero_cw
	P24 var_TCB_TIB_cur_cw
	P24 w_word_store_cw
	P24 w_0BRANCH_cw
	P24 2b - .
	P24 w_INTERPRET_cw
	P24 w_BRANCH_cw
	P24 2b - .
	P24 w_exit_cw


;;	: QUIT
;;	  INIT
;;	  BEGIN
;;	    REFILL 0= IF EXIT THEN
;;	    INTERPRET
;;	  AGAIN ;
;;	





;;	https://forth-standard.org/standard/core/QUIT

;;	6.1.2050 QUIT CORE
;;	( -- ) ( R: i * x -- )
;;	
;;	Empty the return stack, store zero in SOURCE-ID if it is present, make the user input device the input source, and enter interpretation state. Do not display a message. Repeat the following:
;;	
;;	    Accept a line from the input source into the input buffer, set >IN to zero, and interpret.
;;	    Display the implementation-defined system prompt if in interpretation state, all processing has been completed, and no ambiguous condition exists.
