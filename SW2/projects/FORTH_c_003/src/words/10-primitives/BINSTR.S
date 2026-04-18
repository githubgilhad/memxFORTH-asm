; .. vim: ft=asm showbreak=--»\  noexpandtab fileencoding=utf-8 nomodified   wrap textwidth=0 foldmethod=marker foldmarker={{{,}}} foldcolumn=4 ruler showcmd lcs=tab\:|- list tabstop=8 noexpandtab nosmarttab softtabstop=0 shiftwidth=0 linebreak  tags=./tags;,tags; 

DEFWORD w_BSTR_,		0,		"B{",			f_BSTR_			; ( "name" -- addr ) create BYTESTRING word ( -- addr len ), use with closing }B  (addr is start of characters, just after len(3B) , same for both)
DEFWORD w__BSTR,		0,		"}B",			f__BSTR			; ( addr -- ) close B{ like this: B{ NewLine 10 C, 13 C, }B   NewLine TELL 
DEFWORD w_CSTR_,		0,		"C{",			f_CSTR_			; ( "name" -- addr ) create CELLSTRING word ( -- addr len ), use with closing }C  (addr is start of CELLS, just after len(3B) , same for both)
DEFWORD w__CSTR,		0,		"}C",			f__CSTR			; ( addr -- ) close C{ like this: C{ 10 CELLS ALLOT }C .. l == 10  addr 9 CELLS+ is last item 

.section CURRENT_TEXT_SECTION,"ax",@progbits

gfunc f_BSTR_	; {{{ open part, create empty BYTESTRING
	PushST	TOS
	call	func_HEADER
	TCB_memberR3	TCB_HERE,	Parsx	; HERE
	Set3 Zx,Parsx
	Ldi3 Parsx, f_BYTESTRING
	call W3at			; CW
	Set3	Parsx,	r1, r1, r1
	call W3at			; len
	Set3	TOS,	Zx
	TCB_memberW3	TCB_HERE,	TOS	; HERE
	jmp NEXT
; }}}
gfunc f__BSTR	; {{{ close part, compute len
	TCB_memberR3	TCB_HERE,	Parsx	; HERE
	Sub3	Parsx,	TOS			; len
	ldi	Tx,	3
	Sub31	TOS,	Tx
	Set3	Zx,	TOS
	call W3at
	PopST	TOS
	jmp	NEXT
; }}}
gfunc f_BYTESTRING	; {{{  ( -- addr len ) use DT len string as value
	PushST TOS
	Set3 Zx,DT
	call B3at
	Set3 TOS, Parsx	; Set TOS to literal value
	Set3 Temp, Zx
	PushST Temp
	jmp NEXT
	; }}}
gfunc f_CSTR_	; {{{ open part, create empty CELLSTRING
	PushST	TOS
	call	func_HEADER
	TCB_memberR3	TCB_HERE,	Parsx	; HERE
	Set3 Zx,Parsx
	Ldi3 Parsx, f_CELLSTRING
	call W3at			; CW
	Set3	Parsx,	r1, r1, r1
	call W3at			; len
	Set3	TOS,	Zx
	TCB_memberW3	TCB_HERE,	TOS	; HERE
	jmp NEXT
; }}}
gfunc f__CSTR	; {{{ close part, compute len
	TCB_memberR3	TCB_HERE,	Parsx	; HERE
	Sub3	Parsx,	TOS			; len
	ldi	Tx,	3
	Sub31	TOS, 	Tx
	PushST	TOS				; addr of len
	PushST	Parsx				; diff
	Set3	TOS,	Tx, r1, r1		; 3
	call	func_DIVMOD			; diff / 3
	PopST	Parsx				; drop MOD
	Set3	Parsx,	TOS
	PopST	Zx
	call W3at
	PopST	TOS
	jmp	NEXT
; }}}
gfunc f_CELLSTRING	; {{{  ( -- addr len ) use DT len string as value
	PushST TOS
	Set3 Zx,DT
	call B3at
	Set3 TOS, Parsx	; Set TOS to literal value
	Set3 Temp, Zx
	PushST Temp
	jmp NEXT
	; }}}
