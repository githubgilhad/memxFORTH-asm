; .. vim: ft=asm showbreak=--»\  noexpandtab fileencoding=utf-8 nomodified   wrap textwidth=0 foldmethod=marker foldmarker={{{,}}} foldcolumn=4 ruler showcmd lcs=tab\:|- list tabstop=8 noexpandtab nosmarttab softtabstop=0 shiftwidth=0 linebreak  


DEFWORD w_CREATE,		0,		"CREATE",		f_CREATE		; ( "<spaces>name" -- ) Create a definition for name  [1000]
DEFWORD ww_do_create,		FLG_HIDDEN,	"do_create",		do_create,	line=2	; Runtime ( -- a-addr ) push address of datafield for name  [1000]

.section CURRENT_TEXT_SECTION,"ax",@progbits
gfunc f_CREATE	; {{{ # 
	call func_CREATE
	rjmp NEXT
; }}}
gfunc func_CREATE	; {{{ # 
	TCB_member TCB_WL_CURRENT	; &TCB_WL_CURRENT
		RB3at			; &wid
	Set3 DT,Parsx			; DT=&wid
	Set3 Zx,Parsx
	call B3at			; Parsx = wid->, Last
	Set3 Temp,Parsx			; Temp=value of Last
	TCB_member	TCB_HERE	; &HERE
		RB3at			; value of HERE
	Set3 Zx, DT
	call W3at			; HERE->LAST
	TCB_member	TCB_HERE	; &HERE
		RB3at			; value of HERE
	Set3 Zx,Parsx
	Set3 Parsx, Temp
	call W3at			; save LAST at HERE+++
	ldi Parsx_lo, FLG_NOFLAG		; attribs (default not hidden)
	call W1at			; to HERE+
	Set3 Parsx,Zx
	TCB_member	TCB_HERE	; &HERE
		RW3at			; save new value of HERE
	call func_PARSE_NAME		; ( -- c-addr u ) parse name from TIB [xxxx], TIB is RealRAM (TCB)
	TCB_member	TCB_HERE	; &HERE
		RB3at			; value of HERE
	Set3	Zx,Parsx
	Set3 Parsx,TOS
	call W1at			; write len of name
	Set3 Temp,Zx
	PopST DT
	breq3 TOS, 3f			; DT->Temp, TOS x bytes
	ldi Tx,1
2:
	Set3 Zx,DT
	call B1at
	Set3 DT,Zx
	Set3 Zx,Temp
	call W1at
	Set3 Temp,Zx
	Sub31 TOS,Tx
	brne 2b
3:
	Ldi3 Parsx,ww_do_create_cw
	Set3 Zx,Temp
	call W3at
	Set3 Parsx,Zx
	TCB_member	TCB_HERE	; &HERE
		RW3at
	PopST TOS
	ret
; }}}
gfunc do_create	; {{{ # ( -- addr ) return DT
	PushST TOS
	Set3 TOS, DT
	rjmp NEXT
; }}}


; https://forth-standard.org/standard/core/CREATE
; 
; 6.1.1000 CREATE CORE
; ( "<spaces>name" -- )
; 
; Skip leading space delimiters. Parse name delimited by a space. Create a definition for name with the execution semantics defined below. If the data-space pointer is not aligned, reserve enough data space to align it. The new data-space pointer defines name's data field. CREATE does not allocate data space in name's data field.
; 
; name Execution:
; ( -- a-addr )
; 
; a-addr is the address of name's data field. The execution semantics of name may be extended by using DOES>.
; 
; See:
; 3.3.3 Data space, 6.1.1250 DOES>, A.6.1.1000 CREATE.
; 
; Rationale:
; The data-field address of a word defined by CREATE is given by the data-space pointer immediately following the execution of CREATE.
; 
; Reservation of data field space is typically done with ALLOT.
; 
; Typical use: ... CREATE SOMETHING ... 
