; .. vim: ft=asm showbreak=--»\  noexpandtab fileencoding=utf-8 nomodified   wrap textwidth=0 foldmethod=marker foldmarker={{{,}}} foldcolumn=4 ruler showcmd lcs=tab\:|- list tabstop=8 noexpandtab nosmarttab softtabstop=0 shiftwidth=0 linebreak  

DEFWORD w_RAM_MOVE,		0,		"RAM-MOVE",		f_RAM_MOVE		; ( addr1 addr2 u -- ) in RAM only, move u bytes to addr2 (in right direction)

.section CURRENT_TEXT_SECTION,"ax",@progbits
gfunc f_RAM_MOVE	; {{{ #
	PopST Parsx	; addr2 -> Pars -> Z dst
	PopST DT	; addr1 -> X src
	Set3 Zx, Parsx
	
	; len == 0 ?
	mov	Tx, TOS_lo
	or	Tx, TOS_hi
	breq	.f_RAM_MOVE.done
	ldi	Tx, 1

	; porovnat dst a src
	; pokud dst < src -> kopírovat dopředu
	cp	Z_lo, DT_lo
	cpc	Z_hi, DT_hi
	brlo	.f_RAM_MOVE.copy_forward
	breq	.f_RAM_MOVE.done	; dst == src -> done

;	.f_RAM_MOVE.copy_backward:
	; Y = src + len - 1
	; Z = dst + len - 1
	add	Z_lo, TOS_lo
	adc	Z_hi, TOS_hi
	add	DT_lo, TOS_lo
	adc	DT_hi, TOS_hi
	sbiw	Z_lo, 1
	sbiw	DT_lo, 1

.f_RAM_MOVE.bwd_loop:
	ld	Ty, -X
	st	-Z, Ty
	Sub31	TOS, Tx
	brne	.f_RAM_MOVE.bwd_loop
	rjmp	.f_RAM_MOVE.done

.f_RAM_MOVE.copy_forward:
.f_RAM_MOVE.fwd_loop:
	ld	Ty, X+
	st	Z+, Ty
	Sub31	TOS, Tx
	brne	.f_RAM_MOVE.fwd_loop

.f_RAM_MOVE.done:
	PopST TOS
	jmp NEXT
	; }}}
; 
; MOVE ( addr1 addr2 u -- ) TODO (mam RAM-MOVE)
; 
; https://forth-standard.org/standard/core/MOVE
; 
; 6.1.1900 MOVE CORE
; ( addr1 addr2 u -- )
; 
; If u is greater than zero, copy the contents of u consecutive address units at addr1 to the u consecutive address units at addr2. After MOVE completes, the u consecutive address units at addr2 contain exactly what the u consecutive address units at addr1 contained before the move.
; 
; See:
; 17.6.1.0910 CMOVE, 17.6.1.0920 CMOVE>, A.6.1.1900 MOVE.
; 
; R_ationale:
; CMOVE and CMOVE> are the primary move operators in Forth 83. They specify a behavior for moving that implies propagation if the move is suitably invoked. In some hardware, this specific behavior cannot be achieved using the best move instruction. Further, CMOVE and CMOVE> move characters; Forth needs a move instruction capable of dealing with address units. Thus MOVE has been defined and added to the Core word set, and CMOVE and CMOVE> have been moved to the String word set.
