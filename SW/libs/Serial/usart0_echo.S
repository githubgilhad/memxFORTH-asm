
.include "m2560def.inc"

; === Konstanta pro baud rate 115200 při 16 MHz: UBRR = 16
.equ BAUD_UBRR,16

; === RTS / CTS PINY
.equ RTS_PIN,PD2
.equ CTS_PIN,PD3

; === RX/TX buffer velikosti
.equ RX_BUFFER_SIZE,64
.equ RX_BUFFER_THRESHOLD,8
.equ TX_BUFFER_SIZE,32

; === Sekce dat
.section .data
RX_Count:		.byte 0	; if zero, head==tail means empty, if RX_BUFFER_SIZE,  head==tail means full
RX_Head:		.byte 0	; new character will came here
RX_Tail:		.byte 0	; outcoming character will came from here
RX_Buffer:		.byte RX_BUFFER_SIZE	; data

TX_Count:		.byte 0
TX_Head:		.byte 0
TX_Tail:		.byte 0
TX_Buffer:		.byte TX_BUFFER_SIZE
qwer: .byte 123
.section .vectors, "a", @progbits
.org 0x00
	rjmp RESET

.org URXC0addr ; USART0_RX_vect
	rjmp USART0_RX_ISR

.org UDRE0addr ; USART0_UDRE_vect
	rjmp USART0_UDRE_ISR

.section .text
nop	; ctors end and trampolines will be here, lets have RESET named
; === RESET
RESET:
	ldi r16, hi8(RAMEND)
	out SPH, r16
	ldi r16, lo8(RAMEND)
	out SPL, r16
	eor r1,r1

setup:
	sts RX_Count, r1
	sts RX_Head,  r1
	sts RX_Tail,  r1
	sts TX_Count, r1
	sts TX_Head,  r1
	sts TX_Tail,  r1
;
	; USART0 init: 8N1, RX+TX enable, RX interrupt, UDRE interrupt enable (TX)
	ldi r16, hi8(BAUD_UBRR)
	sts UBRR0H, r16
	ldi r16, lo8(BAUD_UBRR)
	sts UBRR0L, r16

	ldi r16, (1 << RXEN0) | (1 << TXEN0) | (1 << RXCIE0) | (1 << UDRIE0)
	sts UCSR0B, r16

	ldi r16, (1 << UCSZ01) | (1 << UCSZ00)
	sts UCSR0C, r16

	; RTS pin jako výstup
	sbi DDRD, RTS_PIN
	cbi PORTD, RTS_PIN	   ; výchozí: RTS = 0 (můžeme přijímat)

	; CTS pin jako vstup
	cbi DDRD, CTS_PIN
	sbi PORTD, CTS_PIN	   ; pull-up

	sei ; povolit přerušení

MAIN_LOOP:
	rcall RX_Read
	tst r24
	breq MAIN_LOOP ; pokud nic nepřišlo, zkus znovu

	rcall TX_Write ; blokuje dokud není volno
	rjmp MAIN_LOOP

; === USART0 RX ISR
USART0_RX_ISR:
	push r1
	push r0
	in r0,SREG
	push r0
	in r0,RAMPZ
	push r0
	eor r1,r1	; use for 0
	push r16
	lds r16, UDR0	; incomming data
	push r18
	push r19
	push r20
	push ZL
	push ZH

	; count ok?
	lds r18, RX_Count
	cpi r18, RX_BUFFER_SIZE	; is buffer full?
	breq RX_FULL ; if yes, exit and ignore this char

	lds r19, RX_Head	; not full, add char
	ldi ZL, lo8(RX_Buffer)
	ldi ZH, hi8(RX_Buffer)
	add ZL, r19
	adc ZH, r1
	st Z, r16
	inc r18		; RX_Count++
	sts RX_Count, r18
	inc r19		; HEAD++
	cpi r19, RX_BUFFER_SIZE
	brlt RX__skip_overflow	; modulo overflow?
	clr r19			; yes, max->0
RX__skip_overflow:
	sts RX_Head, r19	; normal way

	cpi r18, RX_BUFFER_SIZE - RX_BUFFER_THRESHOLD	; RTS: is nearly full?
	brlt RTS_CLEAR
	sbi PORTD, RTS_PIN	; if yes set RTS 
	rjmp RX_EXIT
RTS_CLEAR:
	cbi PORTD, RTS_PIN	;if not, clear RTS

RX_EXIT:
RX_FULL:
	pop ZH
	pop ZL
	pop r20
	pop r19
	pop r18
	pop r16
	pop r0
	out RAMPZ,r0
	pop r0
	out SREG,r0
	pop r0
	pop r1
	reti

; === USART0 UDRE ISR	 - is output register empty?
USART0_UDRE_ISR:
	; CTS check – if is high, we are blocked
	sbis PIND, CTS_PIN
	reti ; CTS aktivní, neodešleme

	lds r18, TX_Count
	cpi r18, 0
	breq TX_EMPTY

	lds r19, TX_Tail
	ldi r20, lo8(TX_Buffer)
	add r19, r20
	ld r16, Z
	sts UDR0, r16

	dec r18
	sts TX_Count, r18

	lds r19, TX_Tail
	inc r19
	cpi r19, TX_BUFFER_SIZE
	brlt TX_T_OK
	clr r19
TX_T_OK:
	sts TX_Tail, r19
	reti
TX_EMPTY:
	; zakázat UDRE interrupt pokud nic k odeslání
	lds r16, UCSR0B
	andi r16, ~(1 << UDRIE0)
	sts UCSR0B, r16
	reti

; === RX_Read: Výstup r24 = znak, r25 = 1 pokud data, jinak 0
RX_Read:
	lds r18, RX_Count
	cpi r18, 0
	breq RX_EMPTY_FUNC
	lds r19, RX_Tail
	ldi r20, lo8(RX_Buffer)
	add r19, r20
	ld r24, Z
	dec r18
	sts RX_Count, r18
	lds r19, RX_Tail
	inc r19
	cpi r19, RX_BUFFER_SIZE
	brlt RX_T2
	clr r19
RX_T2:
	sts RX_Tail, r19
	ldi r25, 1
	ret
RX_EMPTY_FUNC:
	ldi r24, 0x00
	clr r25
	ret

; === TX_Write: vstup r24 = znak, blokuje při plném bufferu
TX_Write:
TX_WAIT:
	lds r18, TX_Count
	cpi r18, TX_BUFFER_SIZE
	breq TX_WAIT
	lds r19, TX_Head
	ldi r20, lo8(TX_Buffer)
	add r19, r20
	st Z, r24
	inc r18
	sts TX_Count, r18
	lds r19, TX_Head
	inc r19
	cpi r19, TX_BUFFER_SIZE
	brlt TX_H2
	clr r19
TX_H2:
	sts TX_Head, r19

	; povolit UDRE interrupt
	lds r16, UCSR0B
	ori r16, (1 << UDRIE0)
	sts UCSR0B, r16
	ret
.global main
main: jmp RESET
