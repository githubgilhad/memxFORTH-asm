;	LIBS: Serial/usart0
; LIBS:  isr_stub  vectors_table
#include <avr/io.h>
#include <avr/interrupt.h>

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
	sei ; povolit přerušení
	ret

loop:
	rcall RX0_Read
	tst r25
	breq 1f ; pokud nic nepřišlo, nedelej nic
	push r24
	rcall TX0_Write ; blokuje dokud není volno
	pop r24
	cpi r24, 13
	brne 1f ; neni enter
	ldi r24, 10
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

