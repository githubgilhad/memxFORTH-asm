; .. vim: ft=asm showbreak=--»\  noexpandtab fileencoding=utf-8 nomodified   wrap textwidth=0 foldmethod=marker foldmarker={{{,}}} foldcolumn=4 ruler showcmd lcs=tab\:|- list tabstop=8 noexpandtab nosmarttab softtabstop=0 shiftwidth=0 linebreak  

DEFWORD w_COMPARE,		0,		"COMPARE",		f_COMPARE		; ( c-addr1 u1 c-addr2 u2 -- n ) compare 2 strings  n=0 identical, n= -1 string1 is LESS than string2

#define caddr1 r12,r13,r14
#define u1 r15,r16,r17
#define c1 r11
#define caddr2 r8,r9,r10
#define u2 r4,r5,r6
#define c2 r7
.section CURRENT_TEXT_SECTION,"ax",@progbits
gfunc f_COMPARE	; {{{ # 
	
	PUSH_R2_R17		; save registers (TOS=u2 r4-6 is saved too)
	PopST caddr2 
	PopST u1 
	PopST caddr1
f_COMPARE.compare_loop:
	breq3 u1, f_COMPARE.u1_empty
	breq3 u2, f_COMPARE.u2_empty
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
	Sub31 u2,r23
	;-----------
	; -------- compare chars
	cp  c1,c2
	breq f_COMPARE.compare_loop

	brlo f_COMPARE.string1_less
	; string1 > string2
f_COMPARE.string1_greater:
	ldi r24,1
	clr r25
	rjmp f_COMPARE.compare_done

f_COMPARE.string1_less:
	ldi r24,0xFF	; -1 (24bit signed)
	ldi r25,0xFF
	rjmp f_COMPARE.compare_done

f_COMPARE.u1_empty:
	; u1 == 0
	breq3 u2, f_COMPARE.strings_equal     ; both 0
	; u1 < u2
	rjmp f_COMPARE.string1_less

f_COMPARE.u2_empty:
	; u2 == 0, u1 != 0
	rjmp f_COMPARE.string1_greater

f_COMPARE.strings_equal:
	clr r24
	clr r25
f_COMPARE.compare_done:		; r24:25 is result
	POP_R2_R17	; pop back
	Set3 TOS, r24,r25,r25
	rjmp NEXT
	; }}}
#undef caddr1
#undef u1
#undef c1
#undef caddr2
#undef u2
#undef c2
; https://forth-standard.org/standard/string/COMPARE
; 
; 17.6.1.0935 COMPARE STRING
; ( c-addr1 u1 c-addr2 u2 -- n )
; 
; Compare the string specified by c-addr1 u1 to the string specified by c-addr2 u2. The strings are compared, beginning at the given addresses, character by character, up to the length of the shorter string or until a difference is found. If the two strings are identical, n is zero. If the two strings are identical up to the length of the shorter string, n is minus-one (-1) if u1 is less than u2 and one (1) otherwise. If the two strings are not identical up to the length of the shorter string, n is minus-one (-1) if the first non-matching character in the string specified by c-addr1 u1 has a lesser numeric value than the corresponding character in the string specified by c-addr2 u2 and one (1) otherwise.
; 
; Testing:
; T{ s1        s1 COMPARE ->  0  }T
; T{ s1  PAD SWAP CMOVE   ->     }T    \ Copy s1 to PAD
; T{ s1  PAD OVER COMPARE ->  0  }T
; T{ s1     PAD 6 COMPARE ->  1  }T
; T{ PAD 10    s1 COMPARE -> -1  }T
; T{ s1     PAD 0 COMPARE ->  1  }T
; T{ PAD  0    s1 COMPARE -> -1  }T
; T{ s1        s6 COMPARE ->  1  }T
; T{ s6        s1 COMPARE -> -1  }T
; 
; : "abdde" S" abdde" ;
; : "abbde" S" abbde" ;
; : "abcdf" S" abcdf" ;
; : "abcdee" S" abcdee" ;
; 
; T{ s1 "abdde"  COMPARE -> -1 }T
; T{ s1 "abbde"  COMPARE ->  1 }T
; T{ s1 "abcdf"  COMPARE -> -1 }T
; T{ s1 "abcdee" COMPARE ->  1 }T
; 
; : s11 S" 0abc" ;
; : s12 S" 0aBc" ;
; 
; T{ s11 s12 COMPARE ->  1 }T
; T{ s12 s11 COMPARE -> -1 }T
