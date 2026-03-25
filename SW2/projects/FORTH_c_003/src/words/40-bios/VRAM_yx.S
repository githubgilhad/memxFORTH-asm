; .. vim: ft=asm showbreak=--»\  noexpandtab fileencoding=utf-8 nomodified   wrap textwidth=0 foldmethod=marker foldmarker={{{,}}} foldcolumn=4 ruler showcmd lcs=tab\:|- list tabstop=8 noexpandtab nosmarttab softtabstop=0 shiftwidth=0 linebreak  tags=./tags;,tags; 


DEFWORD w_VRAM_yx_set,		0,		"VRAM_yx!",		f_VRAM_yx_set		; ( y x c --  ) store c to X,Y [----]
DEFWORD w_VRAM_yx_get,		0,		"VRAM_yx@",		f_VRAM_yx_get		; ( y x  --  c ) get c at X,Y [----]

.section CURRENT_TEXT_SECTION,"ax",@progbits
gfunc f_VRAM_yx_set	; {{{
	PopST	Parsx	; Cpar2 + Cpar1_lo
	PopST	Temp	; Cpar4 + Cpar3_lo
	Set2	Cpar3,	Cpar4
	Set2	Cpar1,	TOS2
	call_VT_member_C	VT_put_char_XY
	PopST	TOS
	rjmp NEXT
; }}}
gfunc f_VRAM_yx_get	; {{{
	PopST	Parsx	; Cpar2 + Cpar1_lo
	Set2	Cpar1,	TOS2
	call_VT_member_C	VT_char_at_XY
	Set3	TOS,	Cpar1_lo,r1,r1
	rjmp NEXT
; }}}



