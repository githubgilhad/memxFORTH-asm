; LIBS: Serial/usart0
; LIBS:  isr_stub  vectors_table
; .include "m2560def.inc"

#include "avr/io.h"

.extern usart0_setup
.extern TX0_Write


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
	call usart0_setup
	ldi r24, 0xFF
	out _SFR_IO_ADDR(DDRF), r24
	sts DDRK, r24

	sei ; povolit přerušení
	ret

loop:
	sei
	lds r24, Counter1
	lds r25, Counter2
	adiw r24, 1
	sts Counter1,r24
	sts Counter2,r25
	out _SFR_IO_ADDR(PORTF),r24
;	sts PORTK,r25
	andi r24, 0x7F
	cpi r24, '  +1
	brsh .L1
	subi r24, -( '  +1)
.L1:
	rcall TX0_Write ; blokuje dokud není volno
;rcall transmit
	clr r24
	clr r25
1:
	inc r24
	brne 1b
	inc r25
	brne 1b
	ret
;=========================
.global main
main: 
	call setup
main_loop:
	call loop
	rjmp main_loop

transmit:       
                lds   r17, UCSR0A        ; Store value at UCSR0A into r17
                sbrs  r17, UDRE0         ; Skip if bit in register is set
                rjmp  transmit           ; Return to transmit beginning
                ldi   r18, 65            ; Load 'A' into r18
                sts   UDR0, r24          ; Write value in r18 to serial port
		sts PORTK,r24
                ret                      ; Return from subroutine
