#define __SFR_OFFSET 0x00		// set the Special Function Register Offset from 0x20 to 0x00 in order to use AVR PORT definitions
#include <avr/io.h>

#include "FORTH-Defines.h"
#include "FORTH-Macros.h"

; === VGA0_WriteA: vstup r24 = znak, blokuje při plném bufferu, vystup r24 - aktualni delka bufferu; uses r18, r19, r20, Z {{{ pise pouze ASCII
.global VGA0_WriteA
VGA0_WriteA:
	sbrc r24,7
	ldi r24, '.'
	cpi r24, ' '
	brsh VGA0_Write
	ldi r24, '.'
; }}} fall thru
; === VGA0_Write: vstup r24 = znak, blokuje při plném bufferu, vystup r24 - aktualni delka bufferu; uses r18, r19, r20, Z {{{
.global VGA0_Write
VGA0_Write:
	PUSHX(18,31)
	push r24
	call TX0_Write
	pop r24
	cpi r24, 10
	breq 2f
	cpi r24, 13
	breq 2f
	call VGA_write_char
3:
	POPX(18,31)
	clr r24
	ret
2:
	call VGA_cr
	rjmp 3b
; === }}}
; === VGA0_Used: output: r24 used space in TX buffer {{{
.global VGA0_Used
VGA0_Used:
	clr r24
	ret
; === }}}
; === VGA0_Free: output: r24 available space in TX buffer {{{
.global VGA0_Free
VGA0_Free:
	ldi r24, 0x20
	ret
; === }}}
; === uint8_t VGA0_WriteStr(char *c);	// Cstring, r24,r25 in, out r24=buf_used. BLOCKS if buffer full uses r24, r25, r22,r23 + TX0_Write (r18,r19,r20,Z) {{{ 
.global VGA0_WriteStr
VGA0_WriteStr:
	movw r22, r24
1:
	movw r30, r22
	ld r24,Z+
	movw r22,r30
	tst r24
	breq 2f
	rcall VGA0_Write
	rjmp 1b
2:
	rcall VGA0_Used
	ret
; === }}}
; === uint8_t VGA0_WriteBin8(uint8_t h);	//  101010101010, r24=buf_used. BLOCKS if buffer full {{{
.global VGA0_WriteBin8
VGA0_WriteBin8:
	mov r23, r24
	ldi r21, 8
1:
	ldi r24, '0
	lsl r23
	adc r24, r1
	rcall VGA0_Write
	dec r21
	brne 1b
	ret
; === }}}
; === uint8_t VGA0_WriteHex8(uint8_t h);	//       0A, r24=buf_used. BLOCKS if buffer full {{{
.global VGA0_WriteHex8
VGA0_WriteHex8:
	mov r23, r24
	swap r24
	call Hex4
	rcall VGA0_Write
	mov r24,r23
	call Hex4
	rcall VGA0_Write
	ret
; === }}}
; === uint8_t VGA0_WriteHex16(uint16_t h);	//     0A0D , r24=buf_used. BLOCKS if buffer full {{{
.global VGA0_WriteHex16
VGA0_WriteHex16:
	mov r21,r24
	mov r24, r25
	rcall VGA0_WriteHex8
	mov r24,r21
	rjmp VGA0_WriteHex8
; === }}}
; === uint8_t VGA0_WriteHex24(uint32_t h);	//   0A0D0C , r24=buf_used. BLOCKS if buffer full {{{
.global VGA0_WriteHex24
VGA0_WriteHex24:
	mov r21,r23
	rcall VGA0_WriteHex8
	mov r24, r21
	rcall VGA0_WriteHex8
	mov r24,r22
	rjmp VGA0_WriteHex8
; === }}}
; === uint8_t VGA0_WriteHex32(uint32_t h);	// 0A0D0C0D , r24=buf_used. BLOCKS if buffer full {{{
.global VGA0_WriteHex32
VGA0_WriteHex32:
	push r22
	push r23
	rcall VGA0_WriteHex16
	pop r25
	pop r24
	rjmp VGA0_WriteHex16
; === }}}
