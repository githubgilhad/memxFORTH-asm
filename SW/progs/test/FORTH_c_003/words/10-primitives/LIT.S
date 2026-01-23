DEFWORD w_lit,		0,	"lit",		f_lit	// ( -- value ) push literal value 

; LIT - push literal value
; ( -- value )
.section CURRENT_TEXT_SECTION,"ax",@progbits
.global f_lit
f_lit:	; {{{ #
	; IP points to the literal value
	Set3 Zx, IP
	call B3at
	Set3 IP, Zx		; IP += 3
	PushST TOS		; Push old TOS
	Set3 TOS, Parsx		; Set TOS to literal value
	rjmp NEXT
	; }}}

