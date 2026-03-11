; .. vim: ft=asm showbreak=--»\  noexpandtab fileencoding=utf-8 nomodified   wrap textwidth=0 foldmethod=marker foldmarker={{{,}}} foldcolumn=4 ruler showcmd lcs=tab\:|- list tabstop=8 noexpandtab nosmarttab softtabstop=0 shiftwidth=0 linebreak  


DEFWORD w_2RAMSTR,		0,		">RAMSTR",		f_2RAMSTR		; ( addr u  -- addr u  ) copy string to temporary RAM in TIB as multistring [xxxx]

#define t_min r2, r3		//; start of TIB
#define t_count r4, r5		//; count to fill = TOS _lo,_hi
#define t_in r6, r7		//; actual position of filling
#define t_max r8, r9		//; address after  end of TIB, do not fill here
#define t_start r10, r11	//; start to fill from here
#define range 2,11

.section CURRENT_TEXT_SECTION,"ax",@progbits
gfunc func_2RAMSTR	; {{{ # FIXME
	PUSHX(2,11)
	
	mov	r0,r1
	inc	r0		; r0 = 1 for incrementing pairs of lower registers
	
						; read input values {{{
	TCB_memberR2	TCB_TIB_cur, t_start	; TIB - where start to fill
	TCB_memberR2	TCB_TIB_len, t_max	; TIB - top
		Sub2	t_max, r1, r0		; have one byte free for P-string
		Sub2	t_max, r1, r0		; have one byte free for C-zero
		Sub2	t_max,t_count
		Sub2	t_max,t_start
		brsh	2f			; ? is enought place for new string?
			Set2	t_start, r1,r1	; No - start from begin
		2:
	TCB_member	TCB_TIB
		Set2		t_min, Zx2	; start of TIB
		Add2	t_start, t_min
	;					; t_start is offset, where to start filling }}}
	Set2	t_in, t_start
	Set2	DT2, t_in
	st	X+, TOS_lo			; len for p string
	Set2	t_in, DT2
	PopST	Parsx
	Set3	Zx, Parsx
	mov	Tx,TOS_lo			; # bytes to copy
	2:
		tst	Tx
		breq	3f
		call	B1at
		st	X+, Parsx_lo
		rjmp	2b
	3:
		st	X+, r1
	Set2	Parsx2, t_in
	ldi	Parsx_hlo, 0x80
	PushST	Parsx
;	POPX	range
	POPX(11,2)
	
	ret
; }}}
gfunc f_2RAMSTR	; {{{ 
	call func_2RAMSTR
	rjmp NEXT
; }}}



#undef t_min
#undef t_start
#undef t_in
#undef t_max
#undef range

