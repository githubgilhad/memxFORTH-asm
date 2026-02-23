; .. vim: ft=asm showbreak=--»\  noexpandtab fileencoding=utf-8 nomodified   wrap textwidth=0 foldmethod=marker foldmarker={{{,}}} foldcolumn=4 ruler showcmd lcs=tab\:|- list tabstop=8 noexpandtab nosmarttab softtabstop=0 shiftwidth=0 linebreak  

; Chci si naimplementovat vlastni FORTH a potrebuju si vymyslet, jak to udelat, aby mi nerozbilo (nebo zbytecne nezkomplikovalo) něco dalšího. Byl by nějaký problém, kdybych to udělal takhle:
; \ wid is pointer to CELL, which points to last word in wordlist
; : WORDLIST ( -- wid ) HERE 0 , ; \ reserve CELL, store zeroes there, return its address
DEFWORD w_WORDLIST,		0,		"WORDLIST",		f_docol, yes		; ( -- wid ) create wordlist : WORDLIST ( -- wid ) HERE 0 , ; \ reserve CELL, store zeroes there, return its address
	P24 var_TCB_HERE_cw
	P24 w_zero_cw
	P24 w_comma_cw
	P24 w_exit_cw
; : SET-CURRENT ( wid -- ) TCB_WL_CURRENT ! ;
DEFWORD w_SET_CURRENT,		0,		"SET-CURRENT",		f_docol, yes		; ( wid -- ) set current wordlist : SET-CURRENT ( wid -- ) TCB_WL_CURRENT ! ;
	P24 var_TCB_WL_CURRENT_cw
	P24 w_store_cw
	P24 w_exit_cw
; : GET-CURRENT ( -- wid ) TCB_WL_CURRENT @ ;
DEFWORD w_GET_CURRENT,		0,		"GET-CURRENT",		f_docol, yes		; ( -- wid ) get current wordlist : GET-CURRENT ( -- wid ) TCB_WL_CURRENT @ ;
	P24 var_TCB_WL_CURRENT_cw
	P24 w_at_cw
	P24 w_exit_cw

; : GET-ORDER ( -- wid_n .. wid_1 n ) TCB_WL_ORDER_len C@ 0 DO TCB_WL_ORDER I CELLS+ @ LOOP TCB_WL_ORDER_len C@ ;
DEFWORD w_GET_ORDER,		0,		"GET-ORDER",		f_docol, yes		; ( -- wid_n .. wid_1 n ) get current search order : GET-ORDER ( -- wid_n .. wid_1 n ) TCB_WL_ORDER_len C@ 0 DO TCB_WL_ORDER I CELLS+ @ LOOP TCB_WL_ORDER_len C@ ;

	P24 var_TCB_WL_ORDER_len_cw
	P24 w_char_at_cw
	P24 w_zero_cw
;	P24 w_DO_cw
	P24 w_2toR_cw
2:
	P24 var_TCB_WL_ORDER_cw
	P24 w_I_cw
	P24 w_CELLS_plus_cw
	P24 w_at_cw
	P24 ww_do_loop_cw
	P24 2b - .
	P24 var_TCB_WL_ORDER_len_cw
	P24 w_char_at_cw
	P24 w_exit_cw

; myWL (wordlist) WLxx
; Problém s wid není, problém s linkováním/ORDER přez druhý ukazatel ve wid je, že ALSO WLxx by znamenalo výrazně složitější WLxx, udělám prostě dost velké pole, min 8, stejně tolik asi hned tak nepoužiju
; A taky pak půjde PREVIOUS, který order zkracuje, mít snadno očekávatelný. (když si někde pro jistotu přidám nějaký WL na začátek a pak se ho zbavím, tak může být ještě někde pod překrytím)

; FORTH2012: https://forth-standard.org/standard/search/FORTH
; 
; 16.6.2.1590 FORTH SEARCH EXT
; ( -- )
; 
; Transform the search order consisting of widn, ... wid2, wid1 (where wid1 is searched first) into widn, ... wid2, widFORTH-WORDLIST.
; 
; Implementation:
; : (wordlist) ( wid "<name>" -- ; ) TODO
;    CREATE ,
;    DOES>
;      @ >R
;      GET-ORDER NIP
;      R> SWAP SET-ORDER
; ;
; 
; FORTH-WORDLIST (wordlist) FORTH TODO



DEFWORD w_head2flags,		0,		"H>FLAGS",		f_head2flags		;  ( h -- flags )  : H>FLAGS  ( h -- flags )     3 +  ;
.section CURRENT_TEXT_SECTION,"ax",@progbits
gfunc f_head2flags	; {{{ #
	ldi Tx, 3
	Add31 TOS, Tx
	jmp NEXT
	; }}}

DEFWORD w_head2len,		0,		"H>LEN",		f_head2len		;  ( h -- x )  : H>LEN  ( h -- x )     4 +  ;
.section CURRENT_TEXT_SECTION,"ax",@progbits
gfunc f_head2len	; {{{ #
	ldi Tx, 4
	Add31 TOS, Tx
	jmp NEXT
	; }}}

DEFWORD w_head2name,		0,		"H>NAME",		f_head2name		;  ( h -- c-addr )  : H>NAME  ( h -- c-addr )     4 +  ;
.section CURRENT_TEXT_SECTION,"ax",@progbits
gfunc f_head2name	; {{{ #
	ldi Tx, 4
	Add31 TOS, Tx
	jmp NEXT
	; }}}

DEFWORD w_head2xt,		0,		"H>XT",			f_head2xt		;  ( h -- xt )  : H>XT  ( h -- xt ) 4 + DUP C@  + 1+  ;
.section CURRENT_TEXT_SECTION,"ax",@progbits
gfunc f_head2xt	; {{{ #
	Set3 Zx, TOS
	ldi Tx, 4
	Add31 Zx, Tx
	call B1at
	Add31 Zx, Parsx_lo
	Set3 TOS, Zx
	jmp NEXT
	; }}}


DEFWORD w_SEARCH_WORDLIST,	0,		"SEARCH_WORDLIST",	f_docol, yes		; ( c-addr u wid -- 0 | xt 1 | xt -1 ) search name, return xt 
; {{{ definition:
	P24 w_at_cw
;	P24 w_at_cw
2: ; BEGIN
	P24 w_DUP_cw
	P24 w_zero_non_equals_cw
3: ; WHILE
	P24 w_0BRANCH_cw
	P24 3f - .
	P24 w_toR_cw
	P24 w_2DUP_cw
	P24 w_R_at_cw
	P24 w_head2name_cw
	P24 w_COUNT_cw
	P24 w_strnonequ_cw
	P24 w_0BRANCH_cw	; IF name
	P24 4f - .
	P24 w_R_at_cw
	P24 w_head2xt_cw
	P24 w_R_at_cw
	P24 w_head2flags_cw
	P24 w_char_at_cw
	P24 w_LIT1_cw
	.byte FLG_IMMEDIATE
	P24 w_AND_cw
	P24 w_0BRANCH_cw	; IF immediate
	P24 5f - .
	P24 w_RDROP_cw
	P24 w_one_cw
	P24 w_EXIT_cw
5: ; IF immediate
	P24 w_RDROP_cw
	P24 w_minus_one_cw
	P24 w_EXIT_cw
4: ; IF name
	P24 w_R_at_cw
	P24 w_head2flags_cw
	P24 w_char_at_cw
	P24 w_LIT1_cw
	.byte FLG_FOG
	P24 w_AND_cw
	P24 w_0BRANCH_cw	; IF fog
	P24 5f - .
	P24 w_RDROP_cw
	P24 w_zero_cw
	P24 w_EXIT_cw
5: ; IF fog
	P24 w_Rfrom_cw
	P24 w_at_cw
	P24 w_BRANCH_cw
	P24 2b - .
3: ; BEGIN .. WHILE .. REPEAT
	P24 w_DROP_cw
	P24 w_2DROP_cw
	P24 w_zero_cw
	P24 w_exit_cw

; : SEARCH-WORDLIST ( c-addr u wid -- 0 | xt 1 | xt -1 )
; 	@ @					\ wid -> last-header
; 	BEGIN
; 		DUP 0<>				\ while header != 0
; 	WHILE
; 		>R				\ save header
; 		2DUP R@ H>NAME COUNT STR<> IF
; 			R@ H>XT			\ xt
; 			R@ H>FLAGS C@		\ flags value
; 			FLG_IMMEDIATE AND IF
; 				RDROP 1 EXIT
; 			ELSE
; 				RDROP -1 EXIT
; 			THEN
; 		THEN
; 		R@ H>FLAGS C@ FLG_FOG AND IF
; 			RDROP 0 EXIT
; 		THEN
; 		R> @				\ move to previous
; 	REPEAT
;	DROP
; 	2DROP 0 ;
; }}}

; https://forth-standard.org/standard/search/SEARCH-WORDLIST
; 
; 16.6.1.2192 SEARCH-WORDLIST SEARCH
; ( c-addr u wid -- 0 | xt 1 | xt -1 )
; 
; Find the definition identified by the string c-addr u in the word list identified by wid. If the definition is not found, return zero. If the definition is found, return its execution token xt and one (1) if the definition is immediate, minus-one (-1) otherwise.
; 
; See:
; A.16.6.1.2192 SEARCH-WORDLIST.
; 
; R_ationale:
; When SEARCH-WORDLIST fails to find the word, it does not return the string, unlike FIND. This is in accordance with the general principle that Forth words consume their arguments. 






DEFWORD w_DEFINITIONS,		0,		"DEFINITIONS",		f_DEFINITIONS		; ( -- ) set CURRENT to first WL in ORDER
.section CURRENT_TEXT_SECTION,"ax",@progbits
gfunc f_DEFINITIONS	; {{{ #
	TCB_member TCB_WL_ORDER_len
	call B3at
	Set3 DT, Parsx
	Add3 Parsx,DT
	Add3 Parsx,DT
	TCB_member TCB_WL_ORDER
	Add3 Zx,Parsx
	call B3at
	TCB_member TCB_WL_CURRENT
	call W3at
	jmp NEXT
	; }}}

; https://forth-standard.org/standard/search/DEFINITIONS
; 
; 16.6.1.1180 DEFINITIONS SEARCH
; ( -- )
; 
; Make the compilation word list the same as the first word list in the search order. Specifies that the names of subsequent definitions will be placed in the compilation word list. Subsequent changes in the search order will not affect the compilation word list.
; 







DEFWORD w_wid_item,		0,		"wid[]",		f_wid_item		; ( i -- wid_i ) get i.th order wordlist (1 most actual) [xxx]

.section CURRENT_TEXT_SECTION,"ax",@progbits
gfunc f_wid_item	; {{{ # 
	
	TCB_member	TCB_WL_ORDER_len
	call		B1at
	sub		Parsx_lo, TOS_lo	; 1B - less than 85 orders
	mov		TOS_lo, Parsx_lo	; 3 *
	add		TOS_lo, Parsx_lo
	add		TOS_lo, Parsx_lo
	TCB_member	TCB_WL_ORDER
	Add31		Zx, TOS_lo
	call		B3at
	Set3		TOS, Parsx
	jmp NEXT
; }}}






; FIND-NAME ( c-addr u -- c-addr u 0 | xt 1 | xt -1 ) if word not found, leave args on stack and return 0, else eat args and return xt with flag - see FIND https://forth-standard.org/standard/core/FIND 

DEFWORD w_FIND_NAME,		0,		"FIND-NAME",		f_docol, yes		; FIND-NAME ( c-addr u -- c-addr u 0 | xt 1 | xt -1 ) if word not found, leave args on stack and return 0, else eat args and return xt with flag - see FIND https://forth-standard.org/standard/core/FIND [xxx] 
	P24 var_TCB_WL_ORDER_len_cw
	P24 w_char_at_cw
	P24 w_zero_cw
;	P24 w_DO_cw
	P24 w_2toR_cw
2:
	P24 w_2DUP_cw
	P24 w_I_cw
	P24 w_one_plus_cw
	P24 w_wid_item_cw
	P24 w_SEARCH_WORDLIST_cw
	P24 w_qDUP_cw
;	P24 w_IF_cw
	P24 w_0BRANCH_cw
	P24 3f - .
	P24 w_2toR_cw
	P24 w_2DROP_cw
	P24 w_2Rfrom_cw
	P24 w_UNLOOP_cw
	P24 w_EXIT_cw
;	P24 w_THEN_cw
3:
	P24 ww_do_loop_cw
	P24 2b - .
	P24 w_zero_cw
	P24 w_exit_cw


; : FIND-NAME ( c-addr u -- c-addr u 0 | xt 1 | xt -1 )
; 	TCB.ORDER.count C@ 0 DO
; 		2DUP I 1+ wid[] SEARCH_WORDLIST \ c-addr u ( 0 | xt 1 | xt -1 )
; 		?DUP IF 
; 			2>R 2DROP 2R> UNLOOP EXIT 
; 		THEN
; 	LOOP
; 	0
; 	;

