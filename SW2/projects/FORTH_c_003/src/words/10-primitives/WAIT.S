; .. vim: ft=asm showbreak=--»\  noexpandtab fileencoding=utf-8 nomodified   wrap textwidth=0 foldmethod=marker foldmarker={{{,}}} foldcolumn=4 ruler showcmd lcs=tab\:|- list tabstop=8 noexpandtab nosmarttab softtabstop=0 shiftwidth=0 linebreak  tags=./tags;,tags; 


DEFWORD w_WAIT,			0,		"WAIT",			f_WAIT			; ( x  --  ) wait x ticks (0 - no wait)

DEFWORD w_frames,		0,		"frames",		f_frames		; (  --  ) do something TODO [----]

.section CURRENT_TEXT_SECTION,"ax",@progbits
gfunc f_frames	; {{{ 
	PushST TOS
	Ldi2	Zx2, frames
	ld TOS_lo, Z+
	ld TOS_hi, Z+
	ld TOS_hlo, Z
	jmp NEXT
; }}}



gfunc f_WAIT	; {{{ 
	Set3	Cpar2, Cpar1_lo 	TOS
	mov	Cpar1_hi,		r1
	call_VT_member_C	VT_wait
	popST	TOS
	jmp NEXT
; }}}



