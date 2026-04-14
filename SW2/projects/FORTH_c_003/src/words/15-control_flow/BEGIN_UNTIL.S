; .. vim: ft=asm showbreak=--»\  noexpandtab fileencoding=utf-8 nomodified   wrap textwidth=0 foldmethod=marker foldmarker={{{,}}} foldcolumn=4 ruler showcmd lcs=tab\:|- list tabstop=8 noexpandtab nosmarttab softtabstop=0 shiftwidth=0 linebreak  tags=./tags;,tags; 
DEFWORD w_BEGIN,		FLG_IMMEDIATE,	"BEGIN",		f_BEGIN			; Compilation ( C: -- 0 do-sys ) compile '(begin)' to definition
DEFWORD w__begin_,		FLG_HIDDEN,	"(begin)",		f__begin_,	line=2	; Runtime: ( -- ) just label

DEFWORD w_UNTIL,		FLG_IMMEDIATE,	"UNTIL",		f_UNTIL			; Compilation ( C: 0 [a .. a] do-sys --  ) compile '(until)' to definition
DEFWORD w__until_,	FLG_HIDDEN + FLG_ARG_3,	"(until)",		f_0BRANCH,	line=2	; Runtime: ( flag -- ) loop if not zero


DEFWORD w_WHILE,		FLG_IMMEDIATE,	"WHILE",		f_WHILE			; ( do-sys -- addr do-sys ) BEGIN condition WHILE action REPEAT
DEFWORD w__while_,		FLG_ARG_3,	"(while)",		f_0BRANCH,	line=2	; ( flag --  ) jump if ZERO [----]
DEFWORD w_REPEAT,		FLG_IMMEDIATE,	"REPEAT",		f_REPEAT		; ( C: 0 [a .. a] do-sys   --  ) BEGIN condition WHILE action REPEAT [----]
DEFWORD w__repeat_,		FLG_ARG_3,	"(repeat)",		f_BRANCH,	line=2	; (  --  ) jump to BEGIN [----]

.section CURRENT_TEXT_SECTION,"ax",@progbits
gfunc f_BEGIN	; {{{ # 
	PushST		TOS
	PushST		r1,r1,r1
	TCB_member	TCB_HERE	; &HERE
		RB3at			; Parsx = value of HERE
	Set3		Zx, Parsx
	Ldi3		Parsx, w__begin__cw
	call W3at			; compile (begin) (~ nop)
	Set3		TOS, Zx		; jump here
	Set3		Parsx,Zx
	TCB_member	TCB_HERE	; &HERE
		RW3at			; write new HERE
	rjmp NEXT
; }}}
gfunc f__begin_	; {{{
	rjmp NEXT
; }}}


gfunc f_UNTIL	; {{{ # 
	TCB_member	TCB_HERE	; &HERE
		RB3at			; Parsx = value of HERE
	Set3		Zx, Parsx
	Ldi3		Parsx, w__until__cw
	call	W3at			; compile (until) (~ 0BRANCH)
	Set3		DT, Zx		; here we need overwrite jump distance
	Sub3		TOS, DT		; compute offset to HERE
	Set3		Parsx, TOS
	call	W3at			; compile back distance
	Set3		Parsx,Zx
	Set3		DT,Zx		; DT is HERE, need climb all nonzero, write there diference from HERE
	TCB_member	TCB_HERE	; &HERE
		RW3at			; write new HERE
2:
	PopST		TOS
	mov		Tx,	TOS_lo
	or		Tx,	TOS_hi
	or		Tx,	TOS_hlo
	breq		3f
	Set3		Parsx,	DT
	Sub3		Parsx,	TOS
	Set3		Zx,	TOS
	call	W3at
	rjmp	2b
3:
	PopST		TOS
	rjmp NEXT
; }}}

gfunc f_WHILE	; {{{ # 
	TCB_member	TCB_HERE	; &HERE
		RB3at			; Parsx = value of HERE
	Set3		Zx, Parsx
	Ldi3		Parsx, w__while__cw
	call W3at			; compile ()IF (=0BRANCH)
	PushST		Zx		; here we need overwrite jump distance
;	ZERO		Parsx							; will be owerwriten anyway
;	call W3at			; compile ()IF (=0BRANCH) offset
	adiw		Z_lo, 3
	Set3		Parsx,Zx
	TCB_member	TCB_HERE	; &HERE
		RW3at			; write new HERE
	rjmp NEXT
; }}}
gfunc f_REPEAT	; {{{ # 
	TCB_member	TCB_HERE	; &HERE
		RB3at			; Parsx = value of HERE
	Set3		Zx, Parsx
	Ldi3		Parsx, w__repeat__cw
	call	W3at			; compile (until) (~ 0BRANCH)
	Set3		DT, Zx		; here we need overwrite jump distance
	Sub3		TOS, DT		; compute offset to HERE
	Set3		Parsx, TOS
	call	W3at			; compile back distance
	Set3		Parsx,Zx
	Set3		DT,Zx		; DT is HERE, need climb all nonzero, write there diference from HERE
	TCB_member	TCB_HERE	; &HERE
		RW3at			; write new HERE
2:
	PopST		TOS
	mov		Tx,	TOS_lo
	or		Tx,	TOS_hi
	or		Tx,	TOS_hlo
	breq		3f
	Set3		Parsx,	DT
	Sub3		Parsx,	TOS
	Set3		Zx,	TOS
	call	W3at
	rjmp	2b
3:
	PopST		TOS
	rjmp NEXT
; }}}
