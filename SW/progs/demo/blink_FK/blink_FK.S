
#include "avr/io.h"



.section .bss
Counter1:	.byte 0
Counter2:	.byte 0
.section .text
nop	; ctors end and trampolines will be here, lets have RESET named
; === RESET
.global RESET
RESET:
	ldi r16, hi8(RAMEND)
	out _SFR_IO_ADDR(SPH), r16
	ldi r16, lo8(RAMEND)
	out _SFR_IO_ADDR(SPL), r16
	clr r1
	out _SFR_IO_ADDR(SREG),r1
	out _SFR_IO_ADDR(EIND),r1
	out _SFR_IO_ADDR(RAMPZ),r1
	rjmp main


; === setup()
setup:
	ldi r24,0x55
	sts Counter1,r24
	sts Counter2,r24
	ldi r24, 0xFF
	out _SFR_IO_ADDR(DDRF), r24
	sts DDRK, r24

	sei ; povolit přerušení
	ret

loop:
	lds r24,Counter1
	lds r25,Counter2
	adiw r24,1
	sts Counter1,r24
	sts Counter2,25
	out _SFR_IO_ADDR(PORTF),r24
	sts PORTK,r25
;rcall transmit
	clr r24
	clr r25
	ldi r26,32
1:
	inc r24
	brne 1b
	inc r25
	brne 1b
;	dec r26
;	brne 1b
	ret
;=========================
.global main
main: 
	call setup
main_loop:
	call loop
	rjmp main_loop

