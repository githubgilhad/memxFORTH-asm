; .. vim: ft=asm showbreak=--»\  noexpandtab fileencoding=utf-8 nomodified   wrap textwidth=0 foldmethod=marker foldmarker={{{,}}} foldcolumn=4 ruler showcmd lcs=tab\:|- list tabstop=8 noexpandtab nosmarttab softtabstop=0 shiftwidth=0 linebreak  


DEFWORD w_EXECUTE,		0,		"EXECUTE",		f_EXECUTE		; ( xt -- ) execute xt  [1370]

.section CURRENT_TEXT_SECTION,"ax",@progbits
gfunc f_EXECUTE	; {{{ # 
	Set3	Parsx, TOS
	PopST	TOS
	Set3	Zx, Parsx
	call	B3at
	Set3	DT,Zx
	Set3	Zx, Parsx
	Div2	Zx
	out	_SFR_IO_ADDR(EIND), Z_hlo
	eijmp
; }}}

; https://forth-standard.org/standard/core/EXECUTE
; 
; 6.1.1370 EXECUTE CORE
; ( i * x xt -- j * x )
; 
; Remove xt from the stack and perform the semantics identified by it. Other stack effects are due to the word EXECUTEd.
; 
