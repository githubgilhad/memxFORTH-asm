; .. vim: ft=asm showbreak=--»\  noexpandtab fileencoding=utf-8 nomodified   wrap textwidth=0 foldmethod=marker foldmarker={{{,}}} foldcolumn=4 ruler showcmd lcs=tab\:|- list tabstop=8 noexpandtab nosmarttab softtabstop=0 shiftwidth=0 linebreak  

.section CURRENT_TEXT_SECTION,"ax",@progbits
gfunc Tracer	; {{{
	PUSH_R0_R31
	ldi Tx, ~0x40
	and DT_hlo, Tx
	movw Cpar2_lo,DT_lo
	mov  Cpar1_lo,DT_hlo
	mov  Cpar1_hi,r1
	
	movw r20,IP_lo
	movw r18,RST_lo
	movw r16,DST_lo
	mov  r15, r1
	mov  r14,TOS_hlo
	movw r12,TOS_lo
	call C_Tracer
	POP_R0_R31
	ret
; }}}
