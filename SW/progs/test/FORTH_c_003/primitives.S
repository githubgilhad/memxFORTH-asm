#include <avr/io.h>
#include "../../../libs/FORTH/FORTH-Defines/FORTH-Defines.h"
#include "../../../libs/FORTH/FORTH-Macros/FORTH-Macros.h"
#include "../../../libs/FORTH/FORTH-Memory/FORTH-Memory.h"
;	#include "../../../libs/FORTH/FORTH-Engine/FORTH-Engine.h"

#include "flags.h"
#include "user_offsets.inc"

; External memory functions
.extern W1at
.extern W3at

.section .text.FORTH.primitives

; grep global primitives.S |sed "s@.global f_\(.*\)@DEFWORD w_\1,\t\t0,\t\"\1\",\t\tf_\1\t// @">primitives.words.inc
; === Stack operations ===

; DUP - duplicate top of stack
; ( a -- a a )
.global f_dup
f_dup:	; {{{ #
	PushST TOS
	rjmp NEXT
	; }}}

; DROP - drop top of stack
; ( a -- )
.global f_drop
f_drop:	; {{{ #
	PopST TOS
	rjmp NEXT
	; }}}

; SWAP - swap top two stack items
; ( a b -- b a )
.global f_swap
f_swap:	; {{{ #
	Set3 Parsx, TOS ; TOS (b) -> Parsx
	ReadST_N 0, TOS ; a-> TOS
	WriteST_N 0, Parsx  ; b -> stack
	rjmp NEXT
	; }}}

; OVER - copy second stack item to top
; ( a b -- a b a )
.global f_over
f_over:	; {{{ #
	ReadST_N 0, Parsx   ; read (a)
	PushST TOS		; Push TOS (b) to stack
	Set3 TOS, Parsx		; Set TOS to (a)
	rjmp NEXT
	; }}}

; === Arithmetic operations ===

; + - add top two stack items
; ( a b -- a+b )
.global f_plus
f_plus:	; {{{ #
	PopST Parsx		; Pop second item to Parsx
	add TOS_lo, Parsx_lo
	adc TOS_hi, Parsx_hi
	adc TOS_hlo, Parsx_hlo
	rjmp NEXT
	; }}}

; - - subtract top from second
; ( a b -- a-b )
.global f_minus
f_minus:	; {{{ #
	PopST Parsx		; Pop second item to Parsx
	sub Parsx_lo, TOS_lo
	sbc Parsx_hi, TOS_hi
	sbc Parsx_hlo, TOS_hlo
	Set3 TOS, Parsx
	rjmp NEXT
	; }}}

; * - multiply top two stack items (24-bit result, may overflow)
; ( a b -- a*b )
; Full 24-bit multiplication: Parsx * TOS -> TOS
.global f_times
f_times:	; {{{ #
	PopST Parsx		; Pop second item (a) to Parsx
	; 24-bit × 24-bit multiplication
	; Result can be up to 48 bits, but we only keep 24 bits
	; Algorithm: (a2 a1 a0) × (b2 b1 b0) = sum of all partial products
	
	; Save registers we'll use
	push r16
	push r17
	push r18
	push r19
	push r20
	
	; Initialize result to 0
	clr r16		; result_lo
	clr r17		; result_hi
	clr r18		; result_hlo
	
	; Multiply Parsx_lo × TOS_lo (low × low)
	mul Parsx_lo, TOS_lo
	mov r16, r0
	mov r17, r1
	
	; Multiply Parsx_lo × TOS_hi (low × mid)
	mul Parsx_lo, TOS_hi
	add r17, r0
	adc r18, r1
	
	; Multiply Parsx_hi × TOS_lo (mid × low)
	mul Parsx_hi, TOS_lo
	add r17, r0
	adc r18, r1
	
	; Multiply Parsx_lo × TOS_hlo (low × high)
	mul Parsx_lo, TOS_hlo
	add r18, r0
	; r1 would go to next byte, ignore for 24-bit result
	
	; Multiply Parsx_hi × TOS_hi (mid × mid)
	mul Parsx_hi, TOS_hi
	add r18, r0
	; r1 would go to next byte, ignore for 24-bit result
	
	; Multiply Parsx_hlo × TOS_lo (high × low)
	mul Parsx_hlo, TOS_lo
	add r18, r0
	; r1 would go to next byte, ignore for 24-bit result
	
	; Move result to TOS (24-bit, truncate if needed)
	mov TOS_lo, r16
	mov TOS_hi, r17
	mov TOS_hlo, r18
	
	; Restore registers
	pop r20
	pop r19
	pop r18
	pop r17
	pop r16
	clr r1
	rjmp NEXT
	; }}}

; / - divide second by top
; ( a b -- a/b )
; Full 24-bit unsigned division: Parsx / TOS -> TOS
.global f_div
f_div:	; {{{ #
	PopST Parsx		; Pop dividend (a) to Parsx
	
	; Check for division by zero
	tst TOS_lo
	brne f_div.not_zero
	tst TOS_hi
	brne f_div.not_zero
	tst TOS_hlo
	brne f_div.not_zero
	; Division by zero - set result to maximum
	ser r21
	mov TOS_lo, r21
	mov TOS_hi, r21
	mov TOS_hlo, r21
	rjmp NEXT
	
f_div.not_zero:
	; Save registers
	push r16
	push r17
	push r18
	push r19
	push r20
	push r21
	push r22
	
	; Initialize quotient to 0
	clr r16		; quotient_lo
	clr r17		; quotient_hi
	clr r18		; quotient_hlo
	
	; Initialize remainder to dividend
	mov r19, Parsx_lo	; remainder_lo
	mov r20, Parsx_hi	; remainder_hi
	mov r21, Parsx_hlo	; remainder_hlo
	
	; 24-bit division using shift and subtract algorithm
	; We'll do 24 iterations (one per bit)
	ldi r22, 24		; counter
	
f_div.loop:
	; Shift quotient left
	lsl r16
	rol r17
	rol r18
	
	; Shift remainder left
	lsl r19
	rol r20
	rol r21
	
	; Compare remainder with divisor
	cp r19, TOS_lo
	cpc r20, TOS_hi
	cpc r21, TOS_hlo
	brlo f_div.skip	; remainder < divisor, skip
	
	; Subtract divisor from remainder
	sub r19, TOS_lo
	sbc r20, TOS_hi
	sbc r21, TOS_hlo
	
	; Set least significant bit of quotient
	ori r16, 1
	
f_div.skip:
	dec r22
	brne f_div.loop
	
	; Move quotient to TOS
	mov TOS_lo, r16
	mov TOS_hi, r17
	mov TOS_hlo, r18
	
	; Restore registers
	pop r22
	pop r21
	pop r20
	pop r19
	pop r18
	pop r17
	pop r16
	rjmp NEXT
	; }}}

; === Memory operations ===

; @ - fetch cell from address
; ( addr -- value )
.global f_at
f_at:	; {{{ #
	Set3 Zx, TOS
	call B3at
	Set3 TOS, Parsx
	rjmp NEXT
	; }}}

; ! - store cell to address
; ( value addr -- )
.global f_store
f_store:	; {{{ #
	PopST Parsx		; Pop value to Parsx
	Set3 Zx, TOS	; Set address to Zx
	; Store NTOS to address in TOS using W3at
	; W3at expects: Zx = address, Parsx = value to write
	call W3at		; Write 3 bytes: [Zx] = Parsx, Zx += 3
	PopST TOS		; Pop new TOS (was value, now get next item)
	rjmp NEXT
	; }}}

; C@ - fetch byte from address
; ( addr -- byte )
.global f_char_at
f_char_at:	; {{{ #
	Set3 Zx, TOS
	call B1at
	mov TOS_lo, Parsx_lo
	clr TOS_hi
	clr TOS_hlo
	rjmp NEXT
	; }}}

; C! - store byte to address
; ( byte addr -- )
.global f_char_store
f_char_store:	; {{{ #
	PopST Parsx		; Pop value to Parsx
	Set3 Zx, TOS
	; W1at expects: Zx = address, Parsx_lo = byte to write, ignores Parsx_hi,Parsx_hlo
	call W1at		; Write 1 byte: [Zx] = Parsx_lo, Zx += 1
	PopST TOS		; Pop new TOS (was byte, now get next item)
	rjmp NEXT
	; }}}

; === I/O operations ===

; KEY - read character from serial
; ( -- char )
.global f_key
f_key:	; {{{ #
	; Save TOS and call RX0_Read
	PushST TOS		; Push old TOS (if any)
	call RX0_Read
	mov TOS_lo, r24
	mov TOS_hi, r25
	clr TOS_hlo		; Clear high byte (24-bit value)
	rjmp NEXT
	; }}}

; EMIT - output character to serial
; ( char -- )
.global f_emit
f_emit:	; {{{ #
	mov r24, TOS_lo		; Move char to r24 for TX0_Write
	call TX0_Write
	PopST TOS		; Pop new TOS (was char, now get next item)
	rjmp NEXT
	; }}}

; === Control flow ===

; EXIT - exit from word
.global f_exit
f_exit:	; {{{ #
	rjmp EXIT
	; }}}

; DOCOL - enter colon word
.global f_docol
f_docol:	; {{{ #
	rjmp DOCOL
	; }}}

; === Literal operations ===

; LIT - push literal value
; ( -- value )
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

.section .FORTH_data.words, "a", @progbits

FORTH_WORDS_START:	; {{{ trick for STOP value for search: 0.header with none data
.global FORTH_WORDS_START
.type   FORTH_WORDS_START,@object
	P24 0		// prev header none
1:
FORTH_WORDS_START.attr:
.type   FORTH_WORDS_START.attr,@object
	.byte FLG_HIDDEN
	.byte 0 //len 0 + FLG_HIDDEN = impossible to find
	// zero bytes of name here
	P24 0		// emty codeword
	; }}}

	// ;;; word definitions
#include "primitives.words.inc"
DEFWORD w_test,		0,	"test",		f_docol		// just test
	P24 w_lit
	.byte 0x21,0,0
	P24 w_dup_cw
	P24 w_plus_cw
	P24 w_exit_cw
.align 2
