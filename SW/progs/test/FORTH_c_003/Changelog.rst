.. vim: ft=rst showbreak=--»\  noexpandtab fileencoding=utf-8 nomodified   wrap textwidth=0 foldmethod=marker foldmarker={{{,}}} foldcolumn=4 ruler showcmd lcs=tab\:|- list tabstop=8 noexpandtab nosmarttab softtabstop=0 shiftwidth=0 linebreak  


:date: 2026.02.01 01:13:24
:_modified: 1970.01.01 00:00:00
:tags: FORTH
:authors: Gilhad
:summary: Changelog
:title: Changelog
:nice_title: |logo| %title% |logo|

%HEADER%

Changelog
--------------------------------------------------------------------------------

%START%
* 2026.02.06 01:05:27 - TUI somehow works (fragile, ESC crash it)
* 2026.02.06 01:05:08 - DEFWORD w_NEXTcounter,			0,		"NEXTcounter",			f_NEXTcounter			; (  -- x ) returns NEXTcounter (# of jumps to NEXT)  [xxxx]
* 2026.02.03 08:15:40 - NEXTcounter incereased on each NEXT

[FORTH_c_003 0f77598] FORTH 2012 as a base ====

* 2026.02.03 01:49:11 - DEFWORD w_PARSE_NAME,		0,		"PARSE-NAME",		f_PARSE_NAME		; ( -- c-address u ) parse name from TIB [xxxx]
* 2026.02.03 00:09:01 - DEFWORD w_one_equals,		0,		"1=",			f_one_equals		; ( x -- flag ) x == 0
* 2026.02.03 00:08:54 - DEFWORD w_one_non_equals,	0,		"1<>",			f_one_non_equals	; ( x -- flag ) x <> 0
* 2026.02.03 00:05:52 - DEFWORD w_CERROR,		0,		"CERROR",		f_docol, yes	; ( c-address u  -- ) reports error with string [xxxx]
* 2026.02.02 23:34:24 - DEFWORD w_COMPILEcomma,		0,		"COMPILE,",		f_comma			; ( x --  ) compile x at HERE
* 2026.02.02 22:54:48 - DEFWORD w_LIT3,			FLG_ARG_3,	"LIT3",			f_LIT3			; ( -- value ) push literal value 3B
* 2026.02.02 22:54:43 - DEFWORD w_LIT2,			FLG_ARG_2,	"LIT2",			f_LIT2			; ( -- value ) push literal value 2B
* 2026.02.02 22:54:38 - DEFWORD w_LIT1,			FLG_ARG_1,	"LIT1",			f_LIT1			; ( -- value ) push literal value 1B
* 2026.02.02 22:54:26 - DEFWORD w_LITERAL,		FLG_IMMEDIATE,	"LITERAL",		f_LITERAL		; ( x -- ) compile x to current word 3B
* 2026.02.02 21:19:46 - DEFWORD w_NIP,			0,		"NIP",			f_NIP			; ( a b -- b ) DROP second item in stack
* 2026.02.02 19:19:08 - DEFWORD w_NUMBER,		0,		"NUMBER",		f_NUMBER		; ( c-addr u -- 0 | x -1 ) convert string to number (using TCB_AIB) [xxxx]
* 2026.02.02 07:42:36 - DEFWORD w_DROPat,		0,		"DROP@",		f_DROPat		; ( xn .. x1 n -- xn-1 .. x1) DROP item at place n (n>2) (1=DROP, 2=NIP)
* 2026.02.02 04:18:12 - DEFWORD w_FIND_NAME,		0,		"FIND-NAME",		f_docol, yes		; FIND-NAME ( c-addr u -- c-addr u 0 | xt 1 | xt -1 ) if word not found, leave args on stack and return 0, else eat args and return xt with flag - see FIND https://forth-standard.org/standard/core/FIND [xxx] 
* 2026.02.02 04:16:00 - DEFWORD w_oneplus,		0,		"1+",			f_oneplus		; ( a -- b ) b = a + 1 [0290]
* 2026.02.02 04:02:32 - DEFWORD w_qDUP,			0,		"?DUP",			f_qDUP			; ( a -- 0 | a a ) duplicate non zero CELL [0630]
* 2026.02.02 03:39:02 - DEFWORD w_wid_item,		0,		"wid[]",		f_wid_item		; ( i -- wid_i ) get i.th order wordlist (1 most actual) [xxx]
* 2026.02.01 23:45:35 - DEFWORD w_LEAVE, FLG_IMMEDIATE + FLG_ARG_3,	"LEAVE",		f_LEAVE			; ( -- ) ( R: loop-sys -- ) leave loop todo compilation
* 2026.02.01 23:35:37 - DEFWORD w_UNLOOP,		0,		"UNLOOP",		f_docol, yes		; ( -- ) remove one level of DO..LOOP to eventually enable EXIT
* 2026.02.01 23:23:49 - DEFWORD w_NDROP,		0,		"NDROP",		f_NDROP			; ( x1 .. xn n -- ) DROP N items from top of stack
* 2026.02.01 23:13:26 - DEFWORD w_GET_ORDER,		0,		"GET-ORDER",		f_docol, yes		; ( -- wid_n .. wid_1 n ) get current search order : GET-ORDER ( -- wid_n .. wid_1 n ) TCB_WL_ORDER_count C@ 0 DO TCB_WL_ORDER I CELLS+ @ LOOP TCB_WL_ORDER_count C@ ;
* 2026.02.01 20:33:44 - DEFWORD w_2toR,			0,		"2>R",			f_2toR			; ( x y  --  )( R: -- x y ) move 2 CELLs from data stack to return stack (in order)
* 2026.02.01 20:30:46 - DEFWORD w_2Rfrom,		0,		"2R>",			f_2Rfrom		; (  -- x y ) ( R: x y -- ) move 2 CELLs from return stack to data stack (in order)
* 2026.02.01 20:28:40 - DEFWORD w_2RDROP,		0,		"2RDROP",		f_2RDROP		; ( -- ) ( R: x y -- ) 2DROP for return stack
* 2026.02.01 20:27:32 - DEFWORD w_2R_at,		0,		"2R@",			f_2R_at			; (  -- x y ) ( R: x y -- x y ) copy 2 CELLs from return stack to data stack (same order)
* 2026.02.01 20:14:13 - DEFWORD w_I,			0,		"I",			f_I			; (  -- x ) return value of inner loop control variable
* 2026.02.01 20:00:33 - DEFWORD w_CELLS_plus,		0,		"CELLS+",		f_CELLS_plus		; ( a b -- c ) c = a + b * CELL_size (Usage: ARRAY_A index CELLS+ @ = value at  ARRAY_A[index] )
* 2026.02.01 19:59:30 - DEFWORD w_CELLS,		0,		"CELLS",		f_CELLS			; ( a -- b ) b = a * CELL_size
* 2026.02.01 19:03:43 - DEFWORD w_strnonequ,		0,		"STR<>",		f_strnonequ		; ( c-addr1 u1 c-addr2 u2 -- flag ) compare 2 strings  flag=0 identical, flag=-1 different
* 2026.02.01 19:03:37 - DEFWORD w_strequ,		0,		"STR=",			f_strequ		; ( c-addr1 u1 c-addr2 u2 -- flag ) compare 2 strings  flag=-1 identical, flag=0 different
* 2026.02.01 10:17:15 - DEFWORD w_AND,			0,		"AND",			f_AND			; ( a b -- a&b ) bitwise AND of two stack items
* 2026.02.01 10:14:13 - DEFWORD w_2DROP,		0,		"2DROP",		f_2DROP			; ( a a -- ) 2DROP top of stack
* 2026.02.01 10:10:06 - DEFWORD w_LIT1,			FLG_ARG_1,	"LIT1",			f_LIT1			; ( -- value ) push literal value 1B
* 2026.02.01 10:09:59 - DEFWORD w_LIT2,			FLG_ARG_2,	"LIT2",			f_LIT2			; ( -- value ) push literal value 2B
* 2026.02.01 09:56:18 - DEFWORD w_EXIT,			0,		"EXIT",			f_exit			; ( XX ) synonymum exit, not catched by show (for exit in middle od WORD)
* 2026.02.01 09:51:52 - DEFWORD w_SEARCH_WORDLIST,	0,		"SEARCH_WORDLIST",	f_docol, yes		; ( c-addr u wid -- 0 | xt 1 | xt -1 ) search name, return xt
* 2026.02.01 09:45:03 - DEFWORD w_RDROP,		0,		"RDROP",		f_RDROP			; ( -- ) ( R: x -- ) DROP for return stack
* 2026.02.01 09:36:35 - DEFWORD w_head2xt,		0,		"H>XT",			f_head2xt		;  ( h -- xt )  : H>XT  ( h -- xt )    DUP H>LEN 5 + + @ ;
* 2026.02.01 09:36:29 - DEFWORD w_head2name,		0,		"H>NAME",		f_head2name		;  ( h -- c-addr )  : H>NAME  ( h -- c-addr )     5 +  ;
* 2026.02.01 09:36:22 - DEFWORD w_head2len,		0,		"H>LEN",		f_head2len		;  ( h -- x )  : H>LEN  ( h -- x )     4 + C@ ;
* 2026.02.01 09:36:06 - DEFWORD w_head2flags,		0,		"H>FLAGS",		f_head2flags		;  ( h -- flags )  : H>FLAGS  ( h -- flags )     3 + C@ ;
* 2026.02.01 09:35:36 - DEFWORD w_0BRANCH,		0,		"0BRANCH",		f_0BRANCH		; ( -- ) branch if zero - add following P24 to IP and NEXT there; -3 is endless loop
* 2026.02.01 08:46:22 - DEFWORD w_2DUP,			0,		"2DUP",			f_2DUP			; ( a b -- a b a b ) duplicate 2 CELLs on top of stack
* 2026.02.01 08:45:37 - DEFWORD w_Rat,			0,		"R@",			f_Rat			; (  -- x ) ( R: x -- x ) copy CELL from return stack to data stack
* 2026.02.01 03:21:16 - DEFWORD w_zero_equals,		0,		"0=",			f_zero_equals		; ( x -- flag ) x == 0
* 2026.02.01 03:21:02 - DEFWORD w_zero_non_equals,	0,		"0<>",			f_zero_non_equals	; ( x -- flag ) x <> 0
* 2026.02.01 02:00:07 - fixed all older words
* 2026.02.01 00:58:39 - DEFWORD w_RFROM,		0,		"R>",			f_RFROM			; (  -- x ) ( R: x -- ) move CELL from return stack to data stack
* 2026.02.01 00:58:03 - DEFWORD w_TOR,			0,		">R",			f_TOR			; ( x  --  )( R: -- x ) move CELL from data stack to return stack


