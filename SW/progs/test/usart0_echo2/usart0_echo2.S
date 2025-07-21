;	LIBS: Serial/usart0
; LIBS:  isr_stub  vectors_table
#include <avr/io.h>
#include <avr/interrupt.h>
.extern usart0_setup
.extern RX0_Read
.extern TX0_Write
.extern RX0_available
.extern TX0_free

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
	call usart0_setup
	ldi r24, 0xFF
	out _SFR_IO_ADDR(DDRF),r24
	sts DDRK,r24
	sei ; povolit přerušení
	ret

loop:
	
	rcall RX0_available
	sts PORTK,r24
	rcall TX0_used
	out _SFR_IO_ADDR(PORTF),r24
	
	rcall RX0_Read
	tst r25
	breq 1f ; pokud nic nepřišlo, nedelej nic
	rcall TX0_Write ; blokuje dokud není volno
1:
	ret
;=========================
.global main
main: 
	call setup
main_loop:
	call loop
	rjmp main_loop

