; .. vim: ft=asm showbreak=--»\  noexpandtab fileencoding=utf-8 nomodified   wrap textwidth=0 foldmethod=marker foldmarker={{{,}}} foldcolumn=4 ruler showcmd lcs=tab\:|- list tabstop=8 noexpandtab nosmarttab softtabstop=0 shiftwidth=0 linebreak  


DEFWORD w_IF,			FLG_IMMEDIATE,	"IF",			f_IF			; C:(  -- addr ) compile do_IF, 0, push addr of 0 to stack [----]
DEFWORD ww_do_IF,		FLG_ARG_3,	"do_IF",		f_0BRANCH,	line=2	; ( flag --  ) jump if ZERO [----]
DEFWORD w_IFNOT,		FLG_IMMEDIATE,	"IFNOT",		f_IFNOT			; C:(  -- addr ) compile do_IFNOT, 0, push addr of 0 to stack [----]
DEFWORD ww_do_IFNOT,		FLG_ARG_3,	"do_IFNOT",		f_1BRANCH,	line=2	; ( flag --  ) jump if NOT ZERO [----]

DEFWORD w_ELSE,			FLG_IMMEDIATE,	"ELSE",			f_ELSE			; C:( addr  -- addr ) compile do_ELSE, 0,get addr from stack and fill offset after 0, push addr of 0 to stack [----]
DEFWORD ww_do_ELSE,		FLG_ARG_3,	"do_ELSE",		f_BRANCH,	line=2	; (  --  ) jump  [----]

DEFWORD w_THEN,			FLG_IMMEDIATE,	"THEN",			f_THEN			; C:( addr  -- ) get addr from stack and fill offset here [----]

.section CURRENT_TEXT_SECTION,"ax",@progbits
gfunc f_IF	; {{{ # 
	TCB_member	TCB_HERE	; &HERE
		RB3at			; Parsx = value of HERE
	Set3		Zx, Parsx
	Ldi3		Parsx, ww_do_IF_cw
	call W3at			; compile do_IF (=0BRANCH)
	Set3		Temp, Zx	; here we need overwrite jump distance
	PushL		Temp
	ZERO		Parsx
	Set3		Zx, Temp
	call W3at			; compile do_IF (=0BRANCH) offset
	Set3		Parsx,Zx
	TCB_member	TCB_HERE	; &HERE
		RW3at			; write new HERE
	rjmp NEXT
; }}}
gfunc f_IFNOT	; {{{ # 
	TCB_member	TCB_HERE	; &HERE
		RB3at			; Parsx = value of HERE
	Set3		Zx, Parsx
	Ldi3		Parsx, ww_do_IFNOT_cw
	call W3at			; compile do_IF (=0BRANCH)
	Set3		Temp, Zx	; here we need overwrite jump distance
	PushL		Temp
	ZERO		Parsx
	Set3		Zx, Temp
	call W3at			; compile do_IF (=0BRANCH)
	Set3		Parsx,Zx
	TCB_member	TCB_HERE	; &HERE
		RW3at			; write new HERE
	rjmp NEXT
; }}}
gfunc f_ELSE	; {{{ # 
	TCB_member	TCB_HERE	; &HERE
		RB3at			; Parsx = value of HERE
	Set3		Zx, Parsx
	Ldi3		Parsx, ww_do_ELSE_cw
	call W3at			; compile do_ELSE (=0BRANCH)
	PopL		DT		; need to owerwrite this addr with offset to next P24
	Set3		Temp, Zx	; here we need overwrite jump distance
	PushL		Temp
	ZERO		Parsx
	call W3at			; compile do_ELSE (=0BRANCH)
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
	PopL		Temp
	Sub3		Parsx, Temp
	Set3		Zx,Temp
	call		W3at		; fix value at IF
	rjmp NEXT
; }}}



