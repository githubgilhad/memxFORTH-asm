
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
	sts Counter1,r1
	sts Counter2,r1
	ldi r24, 0xFF
	out _SFR_IO_ADDR(DDRA), r24
	out _SFR_IO_ADDR(DDRB), r24
	out _SFR_IO_ADDR(DDRC), r24
	out _SFR_IO_ADDR(DDRD), r24
	out _SFR_IO_ADDR(DDRE), r24
	out _SFR_IO_ADDR(DDRF), r24
	sts DDRG, r24
	sts DDRH, r24
	sts DDRK, r24
	sts DDRJ, r24
	sts DDRK, r24
	sts DDRL, r24

	sei ; povolit přerušení
	ret

loop:
	ldi r24,0xFF
	out _SFR_IO_ADDR(PINA),r24
	out _SFR_IO_ADDR(PINB),r24
	out _SFR_IO_ADDR(PINC),r24
	out _SFR_IO_ADDR(PIND),r24
	out _SFR_IO_ADDR(PINE),r24
	out _SFR_IO_ADDR(PINF),r24
	sts PING,r24
	sts PINH,r24
	sts PINJ,r24
	sts PINK,r24
	sts PINL,r24
;rcall transmit
	clr r24
	clr r25
	ldi r26,32
1:
	inc r24
	brne 1b
	inc r25
	brne 1b
	dec r26
	brne 1b
	ret
;=========================
.global main
main: 
	call setup
main_loop:
	call loop
	rjmp main_loop

