; .. vim: ft=asm showbreak=--»\  noexpandtab fileencoding=utf-8 nomodified   wrap textwidth=0 foldmethod=marker foldmarker={{{,}}} foldcolumn=4 ruler showcmd lcs=tab\:|- list tabstop=8 noexpandtab nosmarttab softtabstop=0 shiftwidth=0 linebreak  

DEFWORD w_QUIT,			0,		"QUIT",			f_docol, yes		; Main loop,  : QUIT INIT BEGIN BEGIN TIB TIB.max ACCEPT UNTIL INTERPRET REPEAT ;  
;								;;	: QUIT
	P24 w_CLS_cw						;;	  CLS
	P24 w_INIT_cw                                           ;;	  INIT
2:                                                              ;;	  BEGIN
                                                                ;;	    BEGIN
	P24s var_TCB_TIB_cw, const_TCB_TIB_max_cw, w_ACCEPT_cw  ;;	      TCB_TIB TCB_TIB_max ACCEPT
	P24s w_DUP_cw, var_TCB_TIB_len_cw, w_word_store_cw      ;;	      DUP TCB_TIB_len W!
	P24s w_zero_cw, var_TCB_TIB_cur_cw, w_word_store_cw     ;;	      0 TCB_TIB_cur W!
	P24s w_0BRANCH_cw, (2b - .)                             ;;	    UNTIL
	P24s w_INTERPRET_cw                                     ;;	    INTERPRET
	P24s w_BRANCH_cw, (2b - .)                              ;;	  REPEAT 
	P24 w_exit_cw                                           ;;	;


;;	https://forth-standard.org/standard/core/QUIT

;;	6.1.2050 QUIT CORE
;;	( -- ) ( R: i * x -- )
;;	
;;	Empty the return stack, store zero in SOURCE-ID if it is present, make the user input device the input source, and enter interpretation state. Do not display a message. Repeat the following:
;;	
;;	    Accept a line from the input source into the input buffer, set >IN to zero, and interpret.
;;	    Display the implementation-defined system prompt if in interpretation state, all processing has been completed, and no ambiguous condition exists.
