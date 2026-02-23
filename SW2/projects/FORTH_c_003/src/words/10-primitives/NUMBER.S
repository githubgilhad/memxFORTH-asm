; .. vim: ft=asm showbreak=--»\  noexpandtab fileencoding=utf-8 nomodified   wrap textwidth=0 foldmethod=marker foldmarker={{{,}}} foldcolumn=4 ruler showcmd lcs=tab\:|- list tabstop=8 noexpandtab nosmarttab softtabstop=0 shiftwidth=0 linebreak  


DEFWORD w_NUMBER,		0,		"NUMBER",		f_NUMBER		; ( c-addr u -- 0 | x -1 ) convert string to number (using TCB_AIB) [xxxx]

.section CURRENT_TEXT_SECTION,"ax",@progbits
gfunc f_NUMBER	; {{{ # 
	tcb_member	TCB_AIB
	movw		Temp_lo,ZL
	PopST	Zx
	movw	XL,Temp_lo
	or	TOS_hi,TOS_hlo
	brne	.f_NUMBER.fail
	ldi	Tx, 27	; %- +24 digit +1
	cp	TOS_lo, Tx
	brsh	.f_NUMBER.fail
.f_NUMBER.loop:
	tst	TOS_lo
	breq	.f_NUMBER.endl
	call	B1at
	st	X+,Parsx_lo
	dec	TOS_lo
	rjmp .f_NUMBER.loop
.f_NUMBER.endl:
	st		X+, r1
	tcb_member	TCB_BASE
	ld		Cpar2_lo, Z
	tcb_member	TCB_AIB
	movw		Cpar1_lo, ZL
	call		c_to_number
	Set3		TOS, Cpar1_hi,Cpar1_hi,Cpar1_hi
	tst		Cpar1_hi
	breq		.f_NUMBER.end
	PushST		Cpar2,Cpar1_lo
	jmp NEXT
.f_NUMBER.fail:
	Set3 TOS, r1,r1,r1
.f_NUMBER.end:
	jmp NEXT
; }}}


; https://forth-standard.org/standard/usage#usage:numbers
; 
; 
; 3.4.1.3 Text interpreter input number conversion
; 
; When converting input numbers, the text interpreter shall recognize integer numbers in the form <anynum>.
; 
; <anynum> 	:= 	{ <BASEnum> | <decnum> | <hexnum> | <binnum> | <cnum> }
; <BASEnum> 	:= 	[-]<bdigit><bdigit>*
; <decnum> 	:= 	#[-]<decdigit><decdigit>*
; <hexnum> 	:= 	$[-]<hexdigit><hexdigit>*
; <binnum> 	:= 	%[-]<bindigit><bindigit>*
; <cnum> 	:= 	'<char>'
; <bindigit> 	:= 	{ 0 | 1 }
; <decdigit> 	:= 	{ 0 | 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 | 9 }
; <hexdigit> 	:= 	{ <decdigit> | a | b | c | d | e | f | A | B | C | D | E | F }
; 
; <bdigit> represents a digit according to the value of BASE (see 3.2.1.2 Digit conversion). For <hexdigit>, the digits a...f have the values 10...15. <char> represents any printable character.
; 
; The radix used for number conversion is:
; <BASEnum> 	the value in BASE
; <decnum> 	10
; <hexnum> 	16
; <binnum> 	2
; <cnum> 	the number is the value of <char>
; 
; See 2.2.5 BNF notation. 
