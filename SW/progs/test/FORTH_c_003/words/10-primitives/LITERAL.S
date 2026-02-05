; .. vim: ft=asm showbreak=--»\  noexpandtab fileencoding=utf-8 nomodified   wrap textwidth=0 foldmethod=marker foldmarker={{{,}}} foldcolumn=4 ruler showcmd lcs=tab\:|- list tabstop=8 noexpandtab nosmarttab softtabstop=0 shiftwidth=0 linebreak  

; Compile part
DEFWORD w_LITERAL,		FLG_IMMEDIATE,	"LITERAL",		f_LITERAL		; ( x -- ) compile x to current word 3B (as LIT3 x)

; LITERAL - compile literal value
; ( -- value )
.section CURRENT_TEXT_SECTION,"ax",@progbits
gfunc f_LITERAL	; {{{ #
	TCB_member	TCB_HERE
			RB3at
		Set3	Zx, Parsx
		Ldi3i	Parsx, w_LIT3_cw
			RW3at
		Set3	Parsx, TOS
			RW3at
		Set3	Parsx, Zx
	TCB_member	TCB_HERE
			RW3at
		PopST	TOS
	rjmp NEXT
	; }}}

; https://forth-standard.org/standard/core/LITERALERAL
; 
; 6.1.1780 LITERALERAL CORE
; Interpretation:
; Interpretation semantics for this word are undefined.
; 
; Compilation:
; ( x -- )
; 
; Append the run-time semantics given below to the current definition.
; 
; Run-time:
; ( -- x )
; 
; Place x on the stack. 

; Runtime part
DEFWORD w_LIT1,			FLG_ARG_1,	"LIT1",			f_LIT1			; ( -- value ) push literal value 1B
DEFWORD w_LIT2,			FLG_ARG_2,	"LIT2",			f_LIT2			; ( -- value ) push literal value 2B
DEFWORD w_LIT3,			FLG_ARG_3,	"LIT3",			f_LIT3			; ( -- value ) push literal value 3B

.section CURRENT_TEXT_SECTION,"ax",@progbits
gfunc f_LIT1	; {{{ #
	; IP points to the literal value
	Set3 Zx, IP
	call B1at
	Set3 IP, Zx		; IP += 2
	PushST TOS		; Push old TOS
	Set3 TOS, Parsx_lo, r1, r1	; Set TOS to literal value
	rjmp NEXT
	; }}}
gfunc f_LIT2	; {{{ #
	; IP points to the literal value
	Set3 Zx, IP
	call B2at
	Set3 IP, Zx		; IP += 2
	PushST TOS		; Push old TOS
	Set3 TOS, Parsx_lo, Parsx_hi, r1	; Set TOS to literal value
	rjmp NEXT
	; }}}
gfunc f_LIT3	; {{{ #
	; IP points to the literal value
	Set3 Zx, IP
	call B3at
	Set3 IP, Zx		; IP += 3
	PushST TOS		; Push old TOS
	Set3 TOS, Parsx		; Set TOS to literal value
	rjmp NEXT
	; }}}


gfunc f_CONST1	; {{{  ( -- x ) use DT 1B as value
	PushST TOS
	Set3 Zx,DT
	call B1at
	Set3 TOS, Parsx_lo, r1, r1	; Set TOS to literal value
	rjmp NEXT
	; }}}
gfunc f_CONST2	; {{{  ( -- x ) use DT 2B as value
	PushST TOS
	Set3 Zx,DT
	call B2at
	Set3 TOS, Parsx_lo, Parsx_hi, r1	; Set TOS to literal value
	rjmp NEXT
	; }}}
gfunc f_CONST3	; {{{  ( -- x ) use DT 3B as value
	PushST TOS
	Set3 Zx,DT
	call B3at
	Set3 TOS, Parsx		; Set TOS to literal value
	rjmp NEXT
	; }}}



