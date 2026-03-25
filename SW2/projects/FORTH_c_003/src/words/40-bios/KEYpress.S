; .. vim: ft=asm showbreak=--»\  noexpandtab fileencoding=utf-8 nomodified   wrap textwidth=0 foldmethod=marker foldmarker={{{,}}} foldcolumn=4 ruler showcmd lcs=tab\:|- list tabstop=8 noexpandtab nosmarttab softtabstop=0 shiftwidth=0 linebreak  tags=./tags;,tags; 


DEFWORD w_KEYpress,		0,		"KEYpress",		f_KEYpress		; (  --  ) return pressed key or zero [----]
DEFWORD w_MAX_LINES,		0,		"MAX_LINES",		f_MAX_LINES		; (  --  ) return number of lines [----]
DEFWORD w_MAX_COLUMNS,		0,		"MAX_COLUMNS",		f_MAX_COLUMNS		; (  --  ) return number of columns [----]

.section CURRENT_TEXT_SECTION,"ax",@progbits
gfunc f_KEYpress	; {{{ 
	PushST	TOS
	Ldi2	Cpar2, scratch_byte	; Cpar1 ignored anyway
	call_VT_member_C	VT_read_char
	lds	Tx, scratch_byte
	cpse	Cpar1_lo,r1	; GETC_OK == 0 == r1
	mov	Tx, r1
	Set3	TOS, Tx, r1, r1
	rjmp NEXT
; }}}

gfunc f_MAX_LINES	; {{{ 
	PushST	TOS
	call_VT_member_C	VT_MAX_LINES
	Set3	TOS, Cpar1_lo, r1, r1
	rjmp NEXT
; }}}
gfunc f_MAX_COLUMNS	; {{{ 
	PushST	TOS
	call_VT_member_C	VT_MAX_COLUMNS
	Set3	TOS, Cpar1_lo, r1, r1
	rjmp NEXT
; }}}


