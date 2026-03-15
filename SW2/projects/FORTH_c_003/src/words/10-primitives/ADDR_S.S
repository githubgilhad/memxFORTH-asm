; .. vim: ft=asm showbreak=--»\  noexpandtab fileencoding=utf-8 nomodified   wrap textwidth=0 foldmethod=marker foldmarker={{{,}}} foldcolumn=4 ruler showcmd lcs=tab\:|- list tabstop=8 noexpandtab nosmarttab softtabstop=0 shiftwidth=0 linebreak


DEFWORD w_ADDR_S,		0,		"&S",			f_ADDR_S		; (  -- &S ) data Stack address [xxxx]
DEFWORD w_ADDR_D,		0,		"&D",			f_ADDR_S		; (  -- &D ) data D stack address [xxxx]
DEFWORD w_ADDR_R,		0,		"&R",			f_ADDR_R		; (  -- &R ) return R stack address [xxxx]
DEFWORD w_ADDR_L,		0,		"&L",			f_ADDR_L		; (  -- &L ) secondary L stack address [xxxx]

#define dst_ptr XL,XH

.section CURRENT_TEXT_SECTION,"ax",@progbits
gfunc f_ADDR_S	; {{{ #
	PushST	TOS
	Ldi	Tx, 0x80
	Set3	TOS, DST, Tx
	jmp NEXT
; }}}
gfunc f_ADDR_R	; {{{ #
	PushST	TOS
	Ldi	Tx, 0x80
	Set3	TOS, RST, Tx
	jmp NEXT
; }}}
gfunc f_ADDR_L	; {{{ #
	PushST	TOS
	Ldi	Tx, 0x80
	Set3	TOS, LST, Tx
	jmp NEXT
; }}}

#undef dst_ptr

