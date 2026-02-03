; vim: filetype=asm noexpandtab fileencoding=utf-8 nomodified nowrap textwidth=270 foldmethod=marker foldmarker={{{,}}} foldcolumn=4 ruler showcmd lcs=tab\:|- list: 

#pragma once

; ////////////////////////////////////////////////////////////////////////////////

; === Stack manipulation macros ===
; These macros push/pop 24-bit values to/from the data stack
; Stack grows down (decrement before store, increment after load)

.macro PushST a_lo, a_hi, a_hlo	; {{{ # push "a"  to  DST, 3B (no TOS)
	movw ZL, DST_lo
	st -Z, \a_hlo
	st -Z, \a_hi
	st -Z, \a_lo
	movw DST_lo, ZL
.endm
	; }}}
.macro PopST a_lo, a_hi, a_hlo	; {{{ #  pop  "a" from DST, 3B (no TOS)
	movw ZL, DST_lo
	ld \a_lo, Z+
	ld \a_hi, Z+
	ld \a_hlo, Z+
	movw DST_lo, ZL
.endm
	; }}}
.macro PopST_Zx			; {{{ #  pop  Zx from DST, 3B (no TOS)
	movw XL, DST_lo
	ld Z_lo, X+
	ld Z_hi, X+
	ld Z_hlo, X+
	movw DST_lo, XL
.endm
	; }}}
.macro PopSTn a_lo, a_hi, a_hlo, n	; {{{ #  n * pop  "a" from DST, 3B (no TOS)
	movw ZL, DST_lo
	adiw ZL, 3*(n-1)
	ld \a_lo, Z+
	ld \a_hi, Z+
	ld \a_hlo, Z+
	movw DST_lo, ZL
.endm
	; }}}

.macro PushR a_lo, a_hi, a_hlo	; {{{ # push "a" to RST, 3B
	movw ZL, RST_lo
	st -Z, \a_hlo
	st -Z, \a_hi
	st -Z, \a_lo
	movw RST_lo,ZL
.endm	
	; }}}
.macro PopR a_lo, a_hi, a_hlo	; {{{ # pop "a" from RST, 3B
	movw ZL, RST_lo
	ld \a_lo,  Z+
	ld \a_hi,  Z+
	ld \a_hlo, Z+
	movw RST_lo,ZL
.endm			; }}}

.macro ReadST_N N, a_lo, a_hi, a_hlo	; {{{ # read N-th item from real Data Stack into registers (N=>0, no TOS) (a b -- a b ; N=0 => a fetched)
	movw ZL, DST_lo
	.if \N != 0
		addiw ZL, (\N-1)*3
	.endif
	ld \a_lo, Z+
	ld \a_hi, Z+
	ld \a_hlo, Z+
.endm
	; }}}
.macro WriteST_N N, a_lo, a_hi, a_hlo	; {{{ # write from registers into N-th item on real Data Stack (N=>0, no TOS) (a b -- c b ; c in registers, N=0 )
	movw ZL, DST_lo
	.if \N != 0
		addiw ZL, (\N-1)*3
	.endif
	st  Z+, \a_lo 
	st  Z+, \a_hi 
	st  Z+, \a_hlo
.endm
	; }}}

.macro ReadR_N N, a_lo, a_hi, a_hlo	; {{{ # read N-th item from Return Stack into registers (N=>0) (R: a b -- a b ; N=0 => b fetched)
	movw ZL, RST_lo
	.if \N != 0
		adiw ZL, (\N-1)*3
	.endif
	ld \a_lo, Z+
	ld \a_hi, Z+
	ld \a_hlo, Z+
.endm
	; }}}
.macro WriteR_N N, a_lo, a_hi, a_hlo	; {{{ # write from registers into N-th item on Return Stack (N=>0) (a b -- a c ; c in registers, N=0 )
	movw ZL, RST_lo
	.if \N != 0
		addiw ZL, (\N-1)*3
	.endif
	st  Z+, \a_lo 
	st  Z+, \a_hi 
	st  Z+, \a_hlo
.endm
	; }}}

.macro Set2 a_lo, a_hi,  b_lo, b_hi ; {{{ #  "a" = "b", 2B
	movw \a_lo, \b_lo
.endm			; }}}
.macro Set3 a_lo, a_hi, a_hlo,  b_lo, b_hi, b_hlo ; {{{ #  "a" = "b", 3B
	mov \a_lo, \b_lo
	mov \a_hi, \b_hi
	mov \a_hlo, \b_hlo
.endm			; }}}

; === Aritmetic ===
.macro Add3 a_lo, a_hi, a_hlo, b_lo, b_hi, b_hlo	; {{{ #  "a" += "b", 3B
	add \a_lo,  \b_lo
	adc \a_hi,  \b_hi
	adc \a_hlo, \b_hlo
.endm			; }}}
.macro Add31 a_lo, a_hi, a_hlo, b_lo	; {{{ #  "a" += b_lo, 3+1B
	Add3 \a_lo, \a_hi, \a_hlo, \b_lo, r1, r1
.endm			; }}}
.macro Sub3 a_lo, a_hi, a_hlo, b_lo, b_hi, b_hlo	; {{{ #  "a" -= "b", 3+1B
	sub \a_lo,  \b_lo
	sbc \a_hi,  \b_hi
	sbc \a_hlo, \b_hlo
.endm			; }}}
.macro Sub31 a_lo, a_hi, a_hlo, b_lo	; {{{ #  "a" -= b_lo, 3+1B
	Sub3 \a_lo, \a_hi, \a_hlo, \b_lo, r1, r1
.endm			; }}}

.macro Add2 a_lo, a_hi, b_lo, b_hi	; {{{ #  "a" += "b", 2B
	add \a_lo,  \b_lo
	adc \a_hi,  \b_hi
.endm			; }}}
.macro Add21 a_lo, a_hi, b_lo	; {{{ #  "a" += b_lo, 2+1B
	Add2 \a_lo, \a_hi, \b_lo, r1
.endm			; }}}
.macro Sub2 a_lo, a_hi, b_lo, b_hi	; {{{ #  "a" -= b_lo, 2+1B
	sub \a_lo,  \b_lo
	sbc \a_hi,  \b_hi
.endm			; }}}
.macro Sub21 a_lo, a_hi, b_lo	; {{{ #  "a" -= b_lo, 2+1B
	Sub2 \a_lo, \a_hi, \b_lo, r1
.endm			; }}}

; === Logic ===
.macro breq3 a_lo, a_hi, a_hlo, label	; {{{ #  if "a" == 0, jump to label, 3B
	mov r0, \a_lo
        or  r0, \a_hi
        or  r0, \a_hlo
        breq \label
.endm			; }}}
.macro brne3 a_lo, a_hi, a_hlo, label	; {{{ #  if "a" != 0, jump to label, 3B
	mov r0, \a_lo
        or  r0, \a_hi
        or  r0, \a_hlo
        brne \label
.endm			; }}}

.macro breq2 a_lo, a_hi, label	; {{{ #  if "a" == 0, jump to label, 2B
	mov r0, \a_lo
        or  r0, \a_hi
        breq \label
.endm			; }}}
.macro brne2 a_lo, a_hi, label	; {{{ #  if "a" != 0, jump to label, 2B
	mov r0, \a_lo
        or  r0, \a_hi
        brne \label
.endm			; }}}

.macro TRUE a_lo, a_hi, a_hlo	; {{{ #  a = TRUE, 3B
	mov r0,r1
	inc r0
	mov \a_lo, r0
	mov \a_hi, r0
	mov \a_hlo, r0
.endm			; }}}
.macro FALSE a_lo, a_hi, a_hlo	; {{{ #  a = FALSE, 3B
	mov \a_lo, r1
	mov \a_hi, r1
	mov \a_hlo, r1
.endm			; }}}
.macro ZERO a_lo, a_hi, a_hlo	; {{{ #  a = 0, 3B
	mov \a_lo, r1
	mov \a_hi, r1
	mov \a_hlo, r1
.endm			; }}}

.macro Cmp2 a_lo, a_hi, b_lo, b_hi	; {{{ #  "a" ?= "b", 2B
	cp  \a_lo,  \b_lo
	cpc \a_hi,  \b_hi
.endm			; }}}
.macro Cmp3 a_lo, a_hi, a_hlo, b_lo, b_hi, b_hlo	; {{{ #  "a" ?= "b", 3B
	cp  \a_lo,   \b_lo
	cpc \a_hi,   \b_hi
	cpc \a_hlo,  \b_hlo
.endm			; }}}
; === Load immediate + Load immediate indirect ===
.macro Ldi2 a_lo, a_hi,  address ; {{{ #  LDI "a", address, 2B
	ldi \a_lo, lo8(\address)
	ldi \a_hi, hi8(\address)
.endm			; }}}
.macro Ldi3 a_lo, a_hi, a_hlo,  address ; {{{ #  LDI "a", address, 3B
	ldi \a_lo, lo8(\address)
	ldi \a_hi, hi8(\address)
	ldi \a_hlo, hlo8(\address)
.endm			; }}}

.macro Ldi2i a_lo, a_hi,  address ; {{{ #  LDI "a", address, 2B (via r18:r19)
	ldi r18, lo8(\address)
	ldi r19, hi8(\address)
	movw \a_lo, r18
.endm			; }}}
.macro Ldi3i a_lo, a_hi, a_hlo,  address ; {{{ #  LDI "a", address, 3B (via r18:r19)
	ldi r18, lo8(\address)
	ldi r19, hi8(\address)
	movw \a_lo, r18
	ldi r18, hlo8(\address)
	mov \a_hlo, r18
.endm			; }}}

; === Load direct + Store direct ===
.macro Lds2 a_lo, a_hi,  address ; {{{ #  LDS "a", address, 2B
	lds \a_lo, \address
	lds \a_hi, \address+1
.endm			; }}}
.macro Lds3 a_lo, a_hi, a_hlo,  address ; {{{ #  LDS "a", address, 3B
	lds \a_lo, \address
	lds \a_hi, \address+1
	lds \a_hlo, \address+2
.endm			; }}}

.macro Sts2 address, a_lo, a_hi ; {{{ #  STS address, "a", 2B
	sts \address,   \a_lo
	sts \address+1, \a_hi
.endm			; }}}
.macro Sts3 address, a_lo, a_hi, a_hlo ; {{{ #  STS address, "a" 3B
	sts \address,   \a_lo
	sts \address+1, \a_hi
	sts \address+2, \a_hlo
.endm			; }}}

; === Load via Z+ + Store via Z+ ===
.macro Ld2Z a_lo, a_hi ; {{{ #  LD "a", Z++, 2B
	ld \a_lo, Z+
	ld \a_hi, Z+
.endm			; }}}
.macro Ld3Z a_lo, a_hi, a_hlo	 ; {{{ #  LD "a", Z+++, 3B
	ld \a_lo,  Z+
	ld \a_hi,  Z+
	ld \a_hlo, Z+
.endm			; }}}

.macro St2Z a_lo, a_hi ; {{{ #  ST Z++, "a", 2B
	st Z+, \a_lo
	st Z+, \a_hi
.endm			; }}}
.macro St3Z a_lo, a_hi, a_hlo ; {{{ #  ST Z+++, "a" 3B
	st Z+, \a_lo
	st Z+, \a_hi
	st Z+, \a_hlo
.endm			; }}}

; === convert byte address to word address ===
.macro Div2 a_lo, a_hi, a_hlo ; {{{ #  SHR "a" 3B
	asr \a_hlo
	ror \a_hi
	ror \a_lo
.endm			; }}}

; === Fast B3at&comp for RAM ===
.macro RB1at	; {{{ Z+, Parsx out 1B
	ld Parsx_lo,   Z+
	mov Parsx_hi,  r1
	mov Parsx_hlo, r1
.endm			; }}}
.macro RB2at	; {{{ Z++, Parsx out 2B
	ld Parsx_lo,  Z+
	ld Parsx_hi,  Z+
	mov Parsx_hlo, r1
.endm			; }}}
.macro RB3at	; {{{ Z+++, Parsx out 3B
	ld Parsx_lo,  Z+
	ld Parsx_hi,  Z+
	ld Parsx_hlo, Z+
.endm			; }}}

.macro RW1at	; {{{ Z+, Parsx in 1B
	st Z+, Parsx_lo
.endm			; }}}
.macro RW2at	; {{{ Z++, Parsx in 2B
	st Z+, Parsx_lo 
	st Z+ ,Parsx_hi
.endm			; }}}
.macro RW3at	; {{{ Z+++, Parsx in 3B
	st Z+, Parsx_lo
	st Z+, Parsx_hi
	st Z+, Parsx_hlo
.endm			; }}}

; === TCB members
.macro TCB_member ofset	; {{{ # In: Zx=member, Out: Zx=address #
	ldi Z_lo, lo8(\ofset)
	ldi Z_hi, hi8(\ofset)
	add Z_lo,TCB_lo
	adc Z_hi,TCB_hi
	ldi Z_hlo, 0x80
.endm	; }}}
.macro P16 addr	; {{{ store 2B address
	.byte lo8(\addr)
	.byte hi8(\addr)
.endm		; }}}
.macro P24 addr	; {{{ store 3B address
	.byte lo8(\addr)
	.byte hi8(\addr)
	.byte hlo8(\addr)
.endm		; }}}
.macro P24f addr	; {{{ store 3B address - cannot do for data - THIS MACRO FAILS
	.byte lo8(\addr / 2 )
	.byte hi8(\addr / 2 )
	.byte hlo8(\addr / 2)
.endm		; }}}
.macro func lbl 	; {{{ label for function
\lbl:
	.type \lbl, @function
.endm		; }}}
.macro gfunc lbl 	; {{{ label for global function
\lbl:
	.global \lbl
	.type \lbl, @function
.endm		; }}}
.macro obj lbl		; {{{ label for object
\lbl:
	.type \lbl, @object
.endm		; }}}
.macro gobj lbl		; {{{ label for global object
\lbl:
	.global \lbl
	.type \lbl, @object
.endm		; }}}

.macro PUSH_R2_R17	; {{{
	push r2 
	push r3 
	push r4 
	push r5 
	push r6 
	push r7 
	push r8 
	push r9 
	push r10
	push r11
	push r12
	push r13
	push r14
	push r15
	push r16
	push r17
.endm	; }}}
.macro POP_R2_R17	; {{{
	pop r17
	pop r16
	pop r15
	pop r14
	pop r13
	pop r12
	pop r11
	pop r10
	pop r9 
	pop r8 
	pop r7 
	pop r6 
	pop r5 
	pop r4 
	pop r3 
	pop r2
.endm	; }}}
#define CELL_SIZE 3
#define CELL_PLUS_TWO_BYTES 5
#define CURRENT_TEXT_SECTION .text.FORTH.words
#define CURRENT_DATA_SECTION .FORTH_data.headers
.macro DEFWORD lbl, attr, name, codeword, final_data_label="none"	// {{{ final_data_label = optional data label
.section CURRENT_DATA_SECTION,"a"
gobj \lbl
	P24 1b-3	; link to previous head
1:
obj \lbl\()_attr
	.byte  \attr	// attributes
	.byte ( (\lbl\()_cw - \lbl) - CELL_PLUS_TWO_BYTES )	; name len
;	.byte len\@ 	// name len
;2:
	.ascii "\name"				// name without \0
;	.equ len\@,(. - 2b)
	
;	.global \lbl\()_cw
gobj \lbl\()_cw
	.extern \codeword
	P24 \codeword				// 3B address of function in FLASH
.ifnc "\final_data_label","none"
;		.global \lbl\()_data
;		.type   \lbl\()_data, @object
gobj \lbl\()_data
;	.ascii "==\final_data_label"
.endif
	// more payload may be outside macro
.endm	// }}}
.macro DEFVAR name, Cname	// {{{
.section .bss.FORTH.variables
gobj \Cname
	P24 0

DEFWORD var_\Cname,FLG_ARG_3,"\name",f_dovar
	P24 \Cname
.endm	// }}}
.macro DEFCONST name	// {{{
	DEFWORD const_\name,0,"\name",push_const_\name
.endm	// }}}
.macro DEFCONSTI name, value	// {{{
	DEFWORD const_\name,FLG_ARG_3,"\name",f_doconst, true
	P24 \value
.endm	// }}}

.macro DEFTCBVAR name, member	; {{{
	DEFWORD var_\member,FLG_ARG_2,"\name",f_push_tcb_member
	P16 \member
.endm	; }}}

.macro LINE_16 reg
#ifdef USE_LINE_16
;	LINE_16 - if used, set LINE_16 (XAA16) to bit 0 of given register to bank extended RAM
	cbi _SFR_IO_ADDR(PORTG),3
	sbrc \reg,0
	sbi _SFR_IO_ADDR(PORTG),3
#endif
.endm
