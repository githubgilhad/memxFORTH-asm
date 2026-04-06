; .. vim: ft=asm showbreak=--»\  noexpandtab fileencoding=utf-8 nomodified   wrap textwidth=0 foldmethod=marker foldmarker={{{,}}} foldcolumn=4 ruler showcmd lcs=tab\:|- list tabstop=8 noexpandtab nosmarttab softtabstop=0 shiftwidth=0 linebreak  tags=./tags;,tags; 


DEFWORD w_LITSTRING,		FLG_PSTRING,	"LITSTRING",		f_LITSTRING		; ( -- addr len ) push addr and len of string on the stack - similar to LIT

.section CURRENT_TEXT_SECTION,"ax",@progbits
gfunc f_LITSTRING	; {{{
	; IP points to the "len string" data
	PushST TOS		; Push old TOS
	Set3 Zx, IP
	call B1at
	Set3 IP, Zx		; IP += 1
	Set3 TOS, Parsx_lo, r1, r1		; Set TOS to len
	PushST	IP
	Add3	IP,	TOS
	jmp NEXT
; }}}

gfunc f_CONSTSTRING	; {{{  ( -- addr len ) use DT len string as value
	PushST TOS
	Set3 Zx,DT
	call B1at
	Set3 TOS, Parsx_lo, r1, r1	; Set TOS to literal value
	Set3 Temp, Zx
	PushST Temp
	jmp NEXT
	; }}}


