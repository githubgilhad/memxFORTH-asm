; .. vim: ft=asm showbreak=--»\  noexpandtab fileencoding=utf-8 nomodified   wrap textwidth=0 foldmethod=marker foldmarker={{{,}}} foldcolumn=4 ruler showcmd lcs=tab\:|- list tabstop=8 noexpandtab nosmarttab softtabstop=0 shiftwidth=0 linebreak  


DEFWORD w_IF,			FLG_IMMEDIATE,	"IF",			f_IF			; C:(  -- addr ) compile (if), 0, push addr of 0 to stack [----]
DEFWORD w__if_,			FLG_ARG_3,	"(if)",			f_0BRANCH,	line=2	; ( flag --  ) jump if ZERO [----]
DEFWORD w_IFNOT,		FLG_IMMEDIATE,	"IFNOT",		f_IFNOT			; C:(  -- addr ) compile (ifnot), 0, push addr of 0 to stack [----]
DEFWORD w__ifnot_,		FLG_ARG_3,	"(ifnot)",		f_1BRANCH,	line=2	; ( flag --  ) jump if NOT ZERO [----]

DEFWORD w_ELSE,			FLG_IMMEDIATE,	"ELSE",			f_ELSE			; C:( addr  -- addr ) compile (else), 0,get addr from stack and fill offset after 0, push addr of 0 to stack [----]
DEFWORD w__else_,		FLG_ARG_3,	"(else)",		f_BRANCH,	line=2	; (  --  ) jump  [----]

DEFWORD w_THEN,			FLG_IMMEDIATE,	"THEN",			f_THEN			; C:( addr  -- ) get addr from stack and fill offset here [----]

.section CURRENT_TEXT_SECTION,"ax",@progbits
gfunc f_IF	; {{{ # 
	TCB_member	TCB_HERE	; &HERE
		RB3at			; Parsx = value of HERE
	Set3		Zx, Parsx
	Ldi3		Parsx, w__if__cw
	call W3at			; compile (if) (=0BRANCH)
	Set3		Temp, Zx	; here we need overwrite jump distance
	PushL_x		Temp
	ZERO		Parsx
	Set3		Zx, Temp
	call W3at			; compile (if) (=0BRANCH) offset
	Set3		Parsx,Zx
	TCB_member	TCB_HERE	; &HERE
		RW3at			; write new HERE
	rjmp NEXT
; }}}
gfunc f_IFNOT	; {{{ # 
	TCB_member	TCB_HERE	; &HERE
		RB3at			; Parsx = value of HERE
	Set3		Zx, Parsx
	Ldi3		Parsx, w__ifnot__cw
	call	W3at			; compile (ifnot) (=1BRANCH)
	Set3		Temp, Zx	; here we need overwrite jump distance
	PushL_x		Temp
	ZERO		Parsx
	Set3		Zx, Temp
	call	W3at			; compile (ifnot) (=1BRANCH)
	Set3		Parsx,Zx
	TCB_member	TCB_HERE	; &HERE
		RW3at			; write new HERE
	rjmp NEXT
; }}}
gfunc f_ELSE	; {{{ # 
	TCB_member	TCB_HERE	; &HERE
		RB3at			; Parsx = value of HERE
	Set3		Zx, Parsx
	Ldi3		Parsx, w__else__cw
	call	 W3at			; compile (else) (=0BRANCH)
	Set3		Temp, Zx	; here we need overwrite jump distance
	PopL_x		DT		; need to owerwrite this addr with offset to next P24
	PushL_x		Temp
	ZERO		Parsx
	Set3		Zx,Temp
	call	 W3at			; compile (else) (=0BRANCH)
	Set3		Parsx,Zx
	TCB_member	TCB_HERE	; &HERE
		RW3at			; write new HERE
	; compute offset to HERE
	Sub3		Parsx, DT
	Set3		Zx,DT
	call		W3at		; fix value at IF
	rjmp NEXT
; }}}
gfunc f_THEN	; {{{ # 
	TCB_member	TCB_HERE	; &HERE
		RB3at			; Parsx = value of HERE
	; compute offset to HERE
	PopL_x		Temp
	Sub3		Parsx, Temp
	Set3		Zx,Temp
	call		W3at		; fix value at IF
	rjmp NEXT
; }}}



