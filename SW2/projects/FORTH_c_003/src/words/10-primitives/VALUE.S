; .. vim: ft=asm showbreak=--»\  noexpandtab fileencoding=utf-8 nomodified   wrap textwidth=0 foldmethod=marker foldmarker={{{,}}} foldcolumn=4 ruler showcmd lcs=tab\:|- list tabstop=8 noexpandtab nosmarttab softtabstop=0 shiftwidth=0 linebreak  tags=./tags;,tags; 


DEFWORD w_VALUE,		0,		"VALUE",		f_VALUE			; ( "name" val  --  ) create value  { 12 VALUE test 	test ( -- 12 ) }
DEFWORD w_TO,			FLG_IMMEDIATE,	"TO",			f_docol, yes		; ( "name" val  --  ) change value  { 24 TO test 	test ( -- 24 ) }
									;	: TO  IMMEDIATE			; {{{
	P24s var_TCB_STATE_cw, w_char_at_cw				;		TCB.STATE C@ 
	P24s ww_do_IF_cw, 2f - .					;		IF 
	P24s w_LIT3_cw, w_LIT3_cw, w_comma_cw				;			LIT3 LIT3 ,	; LIT3
	P24s w_tick_cw, w_comma_cw					;			' ,  		; hdd
	P24s w_LIT3_cw, w_one_cw, w_comma_cw				;			LIT3 1 ,	; 1
	P24s w_LIT3_cw, w_CELLS_plus_cw, w_comma_cw			;			LIT3 CELLS+ ,	; CELLS+
	P24s w_LIT3_cw, w_store_cw, w_comma_cw				;			LIT3 ! ,	; !
	P24s ww_do_ELSE_cw, 3f - .					;		ELSE
2:
	P24s  w_tick_cw, w_one_cw, w_CELLS_plus_cw, w_store_cw		;			' 1 CELLS+ !
									;		THEN
3:
	P24 w_exit_cw							;	;				; }}}

DEFWORD w_minus_TO,		FLG_IMMEDIATE,	"-TO",			f_docol, yes		; ( "name" val  --  ) substract from value { 2 -TO test 	test ( -- 22 ) }
									;	: -TO  IMMEDIATE		; {{{
	P24s var_TCB_STATE_cw, w_char_at_cw				;		TCB.STATE C@ 
	P24s ww_do_IF_cw, 2f - .					;		IF 
	P24s w_LIT3_cw, w_LIT3_cw, w_comma_cw				;			LIT3 LIT3 ,	; LIT3
	P24s w_tick_cw, w_comma_cw					;			' ,  		; hdd
	P24s w_LIT3_cw, w_one_cw, w_comma_cw				;			LIT3 1 ,	; 1
	P24s w_LIT3_cw, w_CELLS_plus_cw, w_comma_cw			;			LIT3 CELLS+ ,	; CELLS+
	P24s w_LIT3_cw, w_minus_store_cw, w_comma_cw			;			LIT3 -! ,	; -!
	P24s ww_do_ELSE_cw, 3f - .					;		ELSE
2:
	P24s  w_tick_cw, w_one_cw, w_CELLS_plus_cw, w_minus_store_cw	;			' 1 CELLS+ -!
									;		THEN
3:
	P24 w_exit_cw							;	;				; }}}

DEFWORD w_plus_TO,		FLG_IMMEDIATE,	"+TO",			f_docol, yes		; ( "name" val  --  ) change value  { 3 TO +test 	test ( -- 25 ) }
									;	: +TO  IMMEDIATE		; {{{
	P24s var_TCB_STATE_cw, w_char_at_cw				;		TCB.STATE C@ 
	P24s ww_do_IF_cw, 2f - .					;		IF 
	P24s w_LIT3_cw, w_LIT3_cw, w_comma_cw				;			LIT3 LIT3 ,	; LIT3
	P24s w_tick_cw, w_comma_cw					;			' ,  		; hdd
	P24s w_LIT3_cw, w_one_cw, w_comma_cw				;			LIT3 1 ,	; 1
	P24s w_LIT3_cw, w_CELLS_plus_cw, w_comma_cw			;			LIT3 CELLS+ ,	; CELLS+
	P24s w_LIT3_cw, w_plus_store_cw, w_comma_cw			;			LIT3 +! ,	; +!
	P24s ww_do_ELSE_cw, 3f - .					;		ELSE
2:
	P24s  w_tick_cw, w_one_cw, w_CELLS_plus_cw, w_plus_store_cw	;			' 1 CELLS+ +!
									;		THEN
3:
	P24 w_exit_cw							;	;				; }}}

.section CURRENT_TEXT_SECTION,"ax",@progbits
gfunc f_VALUE	; {{{ 
	call	func_CREATE
	TCB_member	TCB_HERE	; &HERE
		RB3at			; value of HERE
	Set3 Zx,Parsx
	ldi	Tx,	3
	Sub31	Zx,	Tx
	Ldi3 Parsx, f_CONST3
	call W3at			;
	Set3 Parsx, TOS
	call W3at			;
	Set3 Parsx,Zx
	TCB_member	TCB_HERE	; &HERE
		RW3at			; update value of HERE
	PopST	TOS
	jmp NEXT
; }}}




