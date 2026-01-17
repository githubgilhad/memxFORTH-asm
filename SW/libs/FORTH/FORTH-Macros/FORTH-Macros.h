; vim: filetype=asm noexpandtab fileencoding=utf-8 nomodified nowrap textwidth=270 foldmethod=marker foldmarker={{{,}}} foldcolumn=4 ruler showcmd lcs=tab\:|- list: 

#pragma once

; ////////////////////////////////////////////////////////////////////////////////

; === Stack manipulation macros ===
; These macros push/pop 24-bit values to/from the data stack
; Stack grows down (decrement before store, increment after load)

.macro PushST a_lo, a_hi, a_hlo	; {{{ # push "a"  to  ST, 3B (no TOS)
	movw ZL, ST_lo
	st -Z, \a_hlo
	st -Z, \a_hi
	st -Z, \a_lo
	movw ST_lo, ZL
.endm
	; }}}
.macro PopST a_lo, a_hi, a_hlo	; {{{ #  pop  "a" from ST, 3B (no TOS)
	movw ZL, ST_lo
	ld \a_lo, Z+
	ld \a_hi, Z+
	ld \a_hlo, Z+
	movw ST_lo, ZL
.endm
	; }}}

.macro ReadST_N N,a_lo, a_hi, a_hlo	; {{{ # read N-th item from real Data Stack into registers (N=>0, no TOS) (a b -- a b ; N=0 => a fetched)
	movw ZL, ST_lo
    .if \N != 0
        addiw ZL, (\N-1)*3
    .endif
	ld \a_lo, Z+
	ld \a_hi, Z+
	ld \a_hlo, Z+
.endm
	; }}}
.macro WriteST_N N,a_lo, a_hi, a_hlo	; {{{ # write from registers into N-th item on real Data Stack (N=>0, no TOS) (a b -- c b ; c in registers, N=0 )
	movw ZL, ST_lo
    .if \N != 0
        addiw ZL, (\N-1)*3
    .endif
	st  Z+, \a_lo 
	st  Z+, \a_hi 
	st  Z+, \a_hlo
.endm
	; }}}

.macro PushR a_lo, a_hi, a_hlo	; {{{ # push "a" to RS, 3B
	movw ZL, RS_lo
	st -Z, \a_hlo
	st -Z, \a_hi
	st -Z, \a_lo
	movw RS_lo,ZL
.endm	
	; }}}
.macro PopR a_lo, a_hi, a_hlo	; {{{ # pop "a" from RS, 3B
	movw ZL, RS_lo
	ld \a_lo,  Z+
	ld \a_hi,  Z+
	ld \a_hlo, Z+
	movw RS_lo,ZL
.endm			; }}}

.macro Set2 a_lo, a_hi,  b_lo, b_hi ; {{{ #  "a" = "b", 2B
	movw \a_lo, \b_lo
.endm			; }}}
.macro Set3 a_lo, a_hi, a_hlo,  b_lo, b_hi, b_hlo ; {{{ #  "a" = "b", 3B
	movw \a_lo, \b_lo
	mov \a_hlo, \b_hlo
.endm			; }}}

.macro Lds2 a_lo, a_hi,  address ; {{{ #  LDS "a", address, 2B
	lds \a_lo, \address
	lds \a_hi, \address+1
.endm			; }}}
.macro Lds3 a_lo, a_hi, a_hlo,  address ; {{{ #  LDS "a", address, 3B
	lds \a_lo, \address
	lds \a_hi, \address+1
	lds \a_hlo, \address+2
.endm			; }}}


.macro P24 addr	; {{{ store 3B address
	.byte lo8(\addr)
	.byte hi8(\addr)
	.byte hlo8(\addr)
.endm		; }}}
.macro DEFWORD lbl, attr, name, codeword, final_data_label="none"	// {{{ final_data_label = optional data label
	.global \lbl
;	.global \lbl\()_head
\lbl\():
;\lbl\()_head:
	P24 1b-3
1:
\lbl\()_attr:
	.byte  \attr	// attributes
	.byte len\@ 	// name len
2:
	.ascii "\name"				// name without \0
	.equ len\@,(. - 2b)
	
	.global \lbl\()_cw
\lbl\()_cw:
	.extern \codeword
	P24 \codeword				// 3B address of function in FLASH
.ifnc "\final_data_label","none"
;		.global \lbl\()_data
;		.type   \lbl\()_data, @object
;	\lbl\()_data:
;	.ascii "==\final_data_label"
.endif
.type   \lbl\()_attr,@object
.type   \lbl\(), @object
;.type   \lbl\()_head, @object
.type   \lbl\()_cw, @object
	// more payload may be outside macro
.endm	// }}}
.macro DEFVAR name	// {{{
	DEFWORD var_\name,0,"\name",push_var_\name
.endm	// }}}
.macro DEFCONST name	// {{{
	DEFWORD const_\name,0,"\name",push_const_\name
.endm	// }}}
.macro DEFCONSTI name, value	// {{{
	DEFWORD const_\name,0,"\name",f_doconst, "data", true
	P24 \value
.endm	// }}}
