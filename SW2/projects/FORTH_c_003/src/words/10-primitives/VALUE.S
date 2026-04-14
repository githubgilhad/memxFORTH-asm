; .. vim: ft=asm showbreak=--»\  noexpandtab fileencoding=utf-8 nomodified   wrap textwidth=0 foldmethod=marker foldmarker={{{,}}} foldcolumn=4 ruler showcmd lcs=tab\:|- list tabstop=8 noexpandtab nosmarttab softtabstop=0 shiftwidth=0 linebreak  tags=./tags;,tags; 


DEFWORD w_VALUE,		0,		"VALUE",		f_VALUE			; ( "name" val  --  ) create value   { 12 VALUE test 	test ( -- 12 ) }
DEFWORD w_TO,			FLG_IMMEDIATE,	"TO",			f_TO			; ( "name" val  --  ) change value   { 24 TO test 	test ( -- 24 ) }
DEFWORD w_minus_TO,		FLG_IMMEDIATE,	"-TO",			f_minus_TO		; ( "name" val  --  ) sub from value { 2 -TO test 	test ( -- 22 ) }
DEFWORD w_plus_TO,		FLG_IMMEDIATE,	"+TO",			f_plus_TO		; ( "name" val  --  ) add to value   { 3 +TO test 	test ( -- 25 ) }

DEFWORD w__to_,			FLG_ARG_3,	"(to)",			f__to_,		line=2	; ( val -- ) Arg:VALUE, runtime TO   { 24 TO test 	test ( -- 24 ) }
DEFWORD w__minus_to_,		FLG_ARG_3,	"(-to)",		f__minus_to_	line=2	; ( val -- ) Arg:VALUE, runtime -TO  { 2 -TO test 	test ( -- 22 ) }
DEFWORD w__plus_to_,		FLG_ARG_3,	"(+to)",		f__plus_to_	line=2	; ( val -- ) Arg:VALUE, runtime -TO  { 3 +TO test 	test ( -- 25 ) }
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

gfunc f_TO	; {{{
	;					; compiling
	call	func_PARSE_NAME
	call	func_FIND_NAME
	or	TOS_lo,	TOS_hi
	or	TOS_lo,	TOS_hlo			; was the word found? 
	brne	2f
	PopST	TOS				; if not, discard 0, call CERROR (with addr len)
	Ldi3	Zx,	w_CERROR_cw
	call	call_FORTH_cw
	jmp	NEXT
2:
	PopST	TOS				; if yes, discard +/-1, compile/interpret the xt

	TCB_memberR1	TCB_STATE,	Tx	; ?compiling?
	cpi	Tx, F_COMPILING
	brne	f_TO.interpretting
	
	TCB_memberR3	TCB_HERE,	Parsx	; === COMPILE ===
	Set3	Zx, Parsx
	Ldi3	Parsx,	w__to__cw
	call	W3at				; compile (to)
	Set3	Parsx,	TOS
	call	W3at				; compile target VARIABLE
	PopST	TOS				; discard xt
	Set3	Parsx, Zx
	TCB_memberW3	TCB_HERE, Parsx
	jmp	NEXT
f_TO.interpretting:
						; === INTERPTRET ===
	ldi	Tx,	3
	Add31	TOS,	Tx			; first cell after cw
	Set3	Zx,	TOS
	PopST	Parsx				; value to set
	call	W3at
	PopST	TOS
	jmp NEXT
; }}}
gfunc f_minus_TO	; {{{
	;					; compiling
	call	func_PARSE_NAME
	call	func_FIND_NAME
	or	TOS_lo,	TOS_hi
	or	TOS_lo,	TOS_hlo			; was the word found? 
	brne	2f
	PopST	TOS				; if not, discard 0, call CERROR (with addr len)
	Ldi3	Zx,	w_CERROR_cw
	call	call_FORTH_cw
	jmp	NEXT
2:
	PopST	TOS				; if yes, discard +/-1, compile/interpret the xt

	TCB_memberR1	TCB_STATE,	Tx	; ?compiling?
	cpi	Tx, F_COMPILING
	brne	f_minus_TO.interpretting
	
	TCB_memberR3	TCB_HERE,	Parsx	; === COMPILE === ( xt -- )
	Set3	Zx, Parsx
	Ldi3	Parsx,	w__minus_to__cw
	call	W3at				; compile (-to)
	Set3	Parsx,	TOS
	call	W3at				; compile target VARIABLE
	PopST	TOS				; discard xt
	Set3	Parsx, Zx
	TCB_memberW3	TCB_HERE, Parsx
	jmp	NEXT
f_minus_TO.interpretting:
						; === INTERPTRET === ( val xt -- )
	ldi	Tx,	3
	Add31	TOS,	Tx			; first cell after cw
	Set3	Zx,	TOS
	Set3	Temp,	TOS
	call	B3at
	PopST	TOS				; value to sub
	Sub3	Parsx,	TOS
	Set3	Zx,	Temp
	call	W3at
	PopST	TOS
	jmp NEXT
; }}}
gfunc f_plus_TO	; {{{
	;					; compiling
	call	func_PARSE_NAME
	call	func_FIND_NAME
	or	TOS_lo,	TOS_hi
	or	TOS_lo,	TOS_hlo			; was the word found? 
	brne	2f
	PopST	TOS				; if not, discard 0, call CERROR (with addr len)
	Ldi3	Zx,	w_CERROR_cw
	call	call_FORTH_cw
	jmp	NEXT
2:
	PopST	TOS				; if yes, discard +/-1, compile/interpret the xt

	TCB_memberR1	TCB_STATE,	Tx	; ?compiling?
	cpi	Tx, F_COMPILING
	brne	f_plus_TO.interpretting
	
	TCB_memberR3	TCB_HERE,	Parsx	; === COMPILE === ( xt -- )
	Set3	Zx, Parsx
	Ldi3	Parsx,	w__plus_to__cw
	call	W3at				; compile (+to)
	Set3	Parsx,	TOS
	call	W3at				; compile target VARIABLE
	PopST	TOS				; discard xt
	Set3	Parsx, Zx
	TCB_memberW3	TCB_HERE, Parsx
	jmp	NEXT
f_plus_TO.interpretting:
						; === INTERPTRET === ( val xt -- )
	ldi	Tx,	3
	Add31	TOS,	Tx			; first cell after cw
	Set3	Zx,	TOS
	Set3	Temp,	TOS
	call	B3at
	PopST	TOS				; value to add
	Add3	Parsx,	TOS
	Set3	Zx,	Temp
	call	W3at
	PopST	TOS
	jmp NEXT
; }}}

gfunc f__to_	; {{{
	Set3	Zx,	IP
	call	B3at
	Set3	IP,	Zx
	
	ldi	Tx,	3
	Add31	Parsx,	Tx			; first cell after cw
	Set3	Zx,	Parsx
	Set3	Parsx,	TOS			; value to set
	call	W3at
	PopST	TOS
	jmp NEXT
; }}}
gfunc f__minus_to_	; {{{
	Set3	Zx,	IP
	call	B3at
	Set3	IP,	Zx
	
	ldi	Tx,	3
	Add31	Parsx,	Tx			; first cell after cw
	Set3	Zx,	Parsx
	Set3	Temp,	Parsx
	call	B3at
	Sub3	Parsx,	TOS			; value to sub
	Set3	Zx,	Temp
	call	W3at
	PopST	TOS
	jmp NEXT
; }}}
gfunc f__plus_to_	; {{{
	Set3	Zx,	IP
	call	B3at
	Set3	IP,	Zx
	
	ldi	Tx,	3
	Add31	Parsx,	Tx			; first cell after cw
	Set3	Zx,	Parsx
	Set3	Temp,	Parsx
	call	B3at
	Add3	Parsx,	TOS			; value to add
	Set3	Zx,	Temp
	call	W3at
	PopST	TOS
	jmp NEXT
; }}}
