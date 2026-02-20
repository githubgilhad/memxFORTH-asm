; .. vim: ft=asm showbreak=--»\  noexpandtab fileencoding=utf-8 nomodified   wrap textwidth=0 foldmethod=marker foldmarker={{{,}}} foldcolumn=4 ruler showcmd lcs=tab\:|- list tabstop=8 noexpandtab nosmarttab softtabstop=0 shiftwidth=0 linebreak  


DEFWORD w_DOES,			FLG_IMMEDIATE,	"DOES>",		f_DOES			; (  --  ) DOES> runtime part of new word [----]
DEFWORD ww_does,		FLG_ARG_3,	"(does>)",		f_does,		line=2	; (  -- addr ) fix new word's CW with DoubleIndirect address of runtime part [----]
; do_does receive DoubleIndirect call, push addr to stack and does ~ f_docol 

.section CURRENT_TEXT_SECTION,"ax",@progbits
gfunc f_DOES	; {{{ # zakompiluje adresy f_does a do_does do noveho slova
	TCB_member	TCB_HERE
			RB3at
		Set3	Zx, Parsx
		Ldi3i	Parsx, ww_does_cw
			RW3at
		Ldi3i	Parsx, do_does
			RW3at
		Set3	Parsx, Zx
	TCB_member	TCB_HERE
			RW3at
	rjmp NEXT
; }}}

gfunc f_does	; {{{ #  do CW noveho slova da DoubleIndirect odkaz na do_does
	Set3 Parsx,IP
;	Set3 Zx, IP
;	call B3at
;	Set3 IP, Zx		; IP += 3, Parsx=addr of do_does
	ori  Parsx_hlo,FLAG_DoubleIndirect
	Set3 DT, Parsx		; DT=addr of do_does DoubleIndirect
	TCB_member TCB_WL_CURRENT	; &TCB_WL_CURRENT
		RB3at			; &wid
	Set3 Zx,Parsx
	call B3at			; Parsx = wid->, Last
	ldi Tx,4			; ->Len
	Add31 Parsx,Tx
	Set3 Zx,Parsx
	call B1at
	Add31 Zx, Parsx_lo		; Zx -> CW
	Set3 Parsx, DT
	call	W3at
	rjmp EXIT
; }}}
gfunc do_does	; {{{ # po DoubleIndirect zavolani ulozi parametry a provede runtime slova ve stylu f_docol
	PushST		TOS
	Set3		TOS,DT
	Set3 		DT,Temp
	jmp DOCOL
; }}}
