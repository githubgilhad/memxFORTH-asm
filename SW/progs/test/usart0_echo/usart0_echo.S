;	LIBS: Serial/usart0
; LIBS:  isr_stub  vectors_table
.include "m2560def.inc"
.extern usart0_setup
.extern RX0_Read
.extern TX0_Write


.section .text
nop	; ctors end and trampolines will be here, lets have RESET named
; === RESET
.global RESET
RESET:
	ldi r16, hi8(RAMEND)
	out SPH, r16
	ldi r16, lo8(RAMEND)
	out SPL, r16
	clr r1
	out SREG,r1
	out EIND,r1
	out RAMPZ,r1
	rjmp main


; === setup()
setup:
	call usart0_setup
	sei ; povolit přerušení
	ret

MAIN_LOOP:
	rcall RX0_Read
	tst r25
	breq MAIN_LOOP_EXIT ; pokud nic nepřišlo, nedelej nic
	rcall TX0_Write ; blokuje dokud není volno
MAIN_LOOP_EXIT:
	ret
;=========================
.global main
main: 
	call setup
main_loop:
	call MAIN_LOOP
	rjmp main_loop

