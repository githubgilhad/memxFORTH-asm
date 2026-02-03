; .. vim: ft=asm showbreak=--»\  noexpandtab fileencoding=utf-8 nomodified   wrap textwidth=0 foldmethod=marker foldmarker={{{,}}} foldcolumn=4 ruler showcmd lcs=tab\:|- list tabstop=8 noexpandtab nosmarttab softtabstop=0 shiftwidth=0 linebreak  


DEFWORD w_strequ,		0,		"STR=",			f_strequ		; ( c-addr1 u1 c-addr2 u2 -- flag ) compare 2 strings  flag=-1 identical, flag=0 different
DEFWORD w_strnonequ,		0,		"STR<>",		f_strnonequ		; ( c-addr1 u1 c-addr2 u2 -- flag ) compare 2 strings  flag=0 identical, flag=-1 different

#define caddr1 r12,r13,r14
#define u1 r15,r16,r17
#define c1 r11
#define caddr2 r8,r9,r10
#define u2 r4,r5,r6
#define c2 r7
.section CURRENT_TEXT_SECTION,"ax",@progbits
gfunc f_strequ	; {{{ # 
	
	PUSH_R2_R17		; save registers (TOS=u2 r4-6 is saved too)
	PopST caddr2 
	PopST u1 
	PopST caddr1
	Set3 Parsx, u1
	Sub3 Parsx, u2
	brne3 Parsx, f_strequ.diffs
f_strequ.compare_loop:
	breq3 u1, f_strequ.equal
	;-----------		; read char from string 1
	Set3 Zx,caddr1
	call B1at		; destroys user registers (18 and up), returns Zx incremented by 1, r22 is byte there
	Set3 caddr1,Zx
	mov c1,r22		; save character at 
	inc r23			; r23 was zero from B1at, so now is 1
	Sub31 u1,r23
	;-----------
	;-----------		; read char from string 2
	Set3 Zx,caddr2
	call B1at		; destroys user registers (18 and up), returns Zx incremented by 1, r22 is byte there
	Set3 caddr2,Zx
	mov c2,r22		; save character at 
	inc r23			; r23 was zero from B1at, so now is 1
				; Sub31 u2,r23 u2==u1, so no needed
	;-----------
	; -------- compare chars
	cp  c1,c2
	breq f_strequ.compare_loop

f_strequ.diffs:
	ldi r24,0xFF	; -1 (24bit signed)
	rjmp f_strequ.compare_done
f_strequ.equal:
	clr r24
f_strequ.compare_done:		; r24:25 is result
	POP_R2_R17	; pop back
	Set3 TOS, r24,r24,r24
	rjmp NEXT
	; }}}
gfunc f_strnonequ	; {{{ # 
	
	PUSH_R2_R17		; save registers (TOS=u2 r4-6 is saved too)
	PopST caddr2 
	PopST u1 
	PopST caddr1
	Set3 Parsx, u1
	Sub3 Parsx, u2
	brne3 Parsx, f_strnonequ.diffs
f_strnonequ.compare_loop:
	breq3 u1, f_strnonequ.equal
	;-----------		; read char from string 1
	Set3 Zx,caddr1
	call B1at		; destroys user registers (18 and up), returns Zx incremented by 1, r22 is byte there
	Set3 caddr1,Zx
	mov c1,r22		; save character at 
	inc r23			; r23 was zero from B1at, so now is 1
	Sub31 u1,r23
	;-----------
	;-----------		; read char from string 2
	Set3 Zx,caddr2
	call B1at		; destroys user registers (18 and up), returns Zx incremented by 1, r22 is byte there
	Set3 caddr2,Zx
	mov c2,r22		; save character at 
	inc r23			; r23 was zero from B1at, so now is 1
				; Sub31 u2,r23 u2==u1, so no needed
	;-----------
	; -------- compare chars
	cp  c1,c2
	breq f_strnonequ.compare_loop

f_strnonequ.diffs:
	clr r24
	rjmp f_strnonequ.compare_done
f_strnonequ.equal:
	ldi r24,0xFF	; -1 (24bit signed)
f_strnonequ.compare_done:		; r24:25 is result
	POP_R2_R17	; pop back
	Set3 TOS, r24,r24,r24
	rjmp NEXT
	; }}}
#undef caddr1
#undef u1
#undef c1
#undef caddr2
#undef u2
#undef c2



