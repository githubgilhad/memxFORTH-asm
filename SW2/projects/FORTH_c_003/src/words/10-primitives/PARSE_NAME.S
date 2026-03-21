; .. vim: ft=asm showbreak=--»\  noexpandtab fileencoding=utf-8 nomodified   wrap textwidth=0 foldmethod=marker foldmarker={{{,}}} foldcolumn=4 ruler showcmd lcs=tab\:|- list tabstop=8 noexpandtab nosmarttab softtabstop=0 shiftwidth=0 linebreak  


DEFWORD w_PARSE_NAME,		0,		"PARSE-NAME",		f_PARSE_NAME		; ( -- c-address u ) parse name from getc, save it to TIB with len prefix and C-zero after end  [xxxx]

#define TIB_MIN_FREE	10
#define t_min r2, r3		//; start of TIB
#define t_start r4, r5		//; start to fill from here
#define t_in r6, r7		//; actual position of filling
#define t_max r8, r9		//; address after  end of TIB, do not fill here
#define ctx r10, r11		//; data for getC
#define range (2,11)

.section CURRENT_TEXT_SECTION,"ax",@progbits
gfunc func_PARSE_NAME	; {{{ #
	PushST	TOS
	PUSHXr(range)
	
	mov	r0,r1
	inc	r0		; r0 = 1 for incrementing pairs of lower registers
	
						; read input values {{{
	TCB_memberR2	TCB_GETC_CTX, ctx	; CTX for getC
	TCB_member	TCB_TIB
		Set2		t_min, Zx2	; start of TIB
	TCB_memberR2	TCB_TIB_cur, t_start	; TIB - where start to fill
		Add2	t_start, t_min
	TCB_memberR2	TCB_TIB_max, t_max	; TIB - top
		Add2	t_max, t_min
		Sub2	t_max, r0, r1		; have one byte free for C-zero
						; test, if there is at least TIB_MIN_FREE bytes
		Ldi2	Parsx2, TIB_MIN_FREE
		Set2	Temp2, t_max
		Sub2	Temp2, t_start
		Cmp2	Temp2, Parsx2
		brsh	2f
		Set2	t_start, t_min
		2:
	;					; t_start is offset, where to start filling }}}
	Set2	t_in, t_start
	Set2	Zx2, t_in
	st	Z+, r1				; zero len for p string
	Set2	t_in, Zx2
	;					; now we are ready to start read
		2:				; loop to skip spaces {{{
		Set2	Cpar1, ctx
		Set2	Cpar2, t_in
		call	C_getc
		tst	Cpar1_lo	; GETC_OK=0
		breq 3f
; nop
; nop
			call func_yield
			rjmp 2b
		3:
		Set2	Zx2,t_in
		ld	Tx, Z+
		cpi	Tx, ' ' + 1
		brlo 2b				; }}}
		
		Set2	t_in, Zx2
	;					; we are on first non-space
		2:				; loop over non-spaces {{{
		Set2	Cpar1, ctx
		Set2	Cpar2, t_in
		call	C_getc
		tst	Cpar1_lo		; GETC_OK=0
		breq 3f
			cp	Cpar1_lo, GETC_EOF_MET
			breq 7f			; not char, but end of word
			call func_yield
			rjmp 2b
		3:
		Set2	Zx2,t_in
		ld	Tx, Z+
		Set2	t_in, Zx2
		Cmp2	t_in, t_max
		brne 4f
			;			; too long, move it down
			Set2	DT2, t_min
			Set2	Zx2, t_start
			5:
				ld	Ty, Z+
				st	X+, Ty
				Cmp2	Zx2, t_max
				brne 5b
			Set2	t_in, DT2
			Set2	t_start, t_min
		4:
		cpi	Tx, ' ' + 1
		brsh 2b				; }}}
		6:				; end of word
	mov	r0,r1
	inc	r0		; r0 = 1 for incrementing pairs of lower registers
		Sub2	t_in, r0, r1		; last char was space
		7:				; land here, if last char was last in file
		Set2	Zx2, t_in
		st	Z+, r1			; C-zero
		Sub2	Zx2, t_min
		Set2	Cpar2, Zx2
		TCB_memberW2	TCB_TIB_cur, Cpar2
		;				; Calculate length
		Set2	DT2, t_in
		Sub2	DT2, t_start
		Sub2	DT2, r0, r1
		Set2	Zx2, t_start
		st	Z+, DT_lo
						; DT2=len, Zx2 = c-address
	POPXr(range)
	Set3	TOS, DT2, r1
	Set2	DT2, Zx2
	ldi	Tx, 0x80
	mov	DT_hlo, Tx
	PushST	DT
	ret
; }}}
gfunc f_PARSE_NAME	; {{{ #
	call func_PARSE_NAME
	jmp NEXT
; }}}


#undef TIB_MIN_FREE
#undef t_min
#undef t_start
#undef t_in
#undef t_max
#undef ctx
#undef range
