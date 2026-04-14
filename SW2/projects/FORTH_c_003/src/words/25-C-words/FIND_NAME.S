; .. vim: ft=asm showbreak=--»\  noexpandtab fileencoding=utf-8 nomodified   wrap textwidth=0 foldmethod=marker foldmarker={{{,}}} foldcolumn=4 ruler showcmd lcs=tab\:|- list tabstop=8 noexpandtab nosmarttab softtabstop=0 shiftwidth=0 linebreak  tags=./tags;,tags; 


DEFWORD w_FIND_NAME,		0,		"FIND-NAME",		f_FIND_NAME		; ( addr u  -- addr u 0 | xt 1 | xt -1 ) 1=immediate, -1=normal,  0=not found

.section CURRENT_TEXT_SECTION,"ax",@progbits
gfunc func_FIND_NAME	; {{{ 
	ReadST_N_x	 0,	Parsx
	Set2		Cpar1,	TCB
	Set2		Cpar3,	TOS2
	call	find_name_tcb
	tst	r25
	brne	2f
	PushST	TOS
	Set3	TOS,	r1,r1,r1
	jmp NEXT
2:	
	PopST	TOS
	PushST	Parsx	; r22:r24
	cpi	r25,	1
	brne	2f
	Set3	TOS, r25,r1,r1
	jmp NEXT
2:
	Set3	TOS, r25,r25,r25
	ret
; }}}
gfunc f_FIND_NAME	; {{{ 
	call func_FIND_NAME
	jmp NEXT
; }}}




// TCB = r24:25, addr = r22:r23, len = r20
; uint32_t find_name_tcb(Thread_Controll_Block *TCB, const char *addr, uint8_t len) {	 //  returns xt+(flag<<24) flag is byte
	// r22:r24 = xt, r25 = flag
