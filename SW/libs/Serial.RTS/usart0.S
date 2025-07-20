
.include "m2560def.inc"

; === Konstanta pro baud rate 115200 při 16 MHz: UBRR = 16
.equ BAUD_UBRR,16

; === RTS / CTS PINY
.equ RTS_PIN,PD2
.equ CTS_PIN,PD3


.macro IRQ_push_entry	; {{{
	push r1
	push r0
	in r0,SREG
	push r0
	in r0,RAMPZ
	push r0
	clr r1	; use for 0
.endm			; }}}
.macro IRQ_push_16_20_Z	; {{{
	push r16
	push r17
	push r18
	push r19
	push r20
	push ZL
	push ZH
.endm			; }}}
.macro IRQ_pop_16_20_Z	; {{{
	pop ZH
	pop ZL
	pop r20
	pop r19
	pop r18
	pop r17
	pop r16
.endm			; }}}
.macro IRQ_pop_entry	; {{{
	pop r0
	out RAMPZ,r0
	pop r0
	out SREG,r0
	pop r0
	pop r1
.endm			; }}}

; === RX/TX buffer velikosti
.equ RX_BUFFER_SIZE,64
.equ RX_BUFFER_THRESHOLD,8
.equ TX_BUFFER_SIZE,32

; === Sekce dat
.section .bss
qwer1: .byte 0
RX_Count:		.byte 0	; if zero, head==tail means empty, if RX_BUFFER_SIZE,  head==tail means full
RX_Head:		.byte 0	; new character will came here
RX_Tail:		.byte 0	; outcoming character will came from here
RX_Buffer:		.skip RX_BUFFER_SIZE	; data

TX_Count:		.byte 0
TX_Head:		.byte 0
TX_Tail:		.byte 0
TX_Buffer:		.skip TX_BUFFER_SIZE
qwer2: .byte 0

.section .text

nop	; ctors end and trampolines will be here, lets have RESET named

; === setup()
.global usart0_setup
usart0_setup:
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

	; CTS pin jako zdroj interruptu
	lds r16, EICRA		; EICRA pg.110
	andi r16, 0b00111111
	ori r16,  0b00100000  ; ISC21:20 = 10 → falling edge
	sts EICRA, r16		; OVERIT PIN

	sbi EIMSK, INT3      ; povolit INT3
	sbis PIND, CTS_PIN	; CTS check – if is low, we can send so no need for INT
	cbi EIMSK, INT3      ; zakazat INT3

	ret

; === USART0 RX ISR
.global USART0_RX_ISR
USART0_RX_ISR:
	IRQ_push_entry
	IRQ_push_16_20_Z
	lds r16, UDR0	; incomming data

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
	IRQ_pop_16_20_Z
	IRQ_pop_entry
	reti

; === RX0_Read: Výstup r24 = znak, r25 = 1 pokud data, jinak 0
.global RX0_Read
RX0_Read:
	lds r18, RX_Count
	cpi r18, 0
	breq RX_EMPTY_FUNC
	lds r19, RX_Tail
	ldi ZL, lo8(RX_Buffer)
	ldi ZH, hi8(RX_Buffer)
	add ZL, r19
	adc ZH, r1
	ld r24, Z
	in r25,SREG
	cli			; ==== no interrupts here
	lds r18, RX_Count	; RX_Count --
	dec r18
	sts RX_Count, r18
	out SREG,r25		; ==== ok
	inc r19
	cpi r19, RX_BUFFER_SIZE
	brlt RX__skip_overflow_read
	clr r19
RX__skip_overflow_read:
	sts RX_Tail, r19
	ldi r25, 1
	ret
RX_EMPTY_FUNC:
	cbi PORTD, RTS_PIN	; clear RTS
	ldi r24, 0x00
	clr r25
	ret






; === USART0 UDRE ISR	 - is output register empty?
.global USART0_UDRE_ISR
USART0_UDRE_ISR:
	IRQ_push_entry
	
	sbis PIND, CTS_PIN	; CTS check – if is low, we can send
	NOP ; FIXME suppose we can send anytime
	rjmp TX_send		; yes, we can
				; no we cannot - disable USART0_UDRE_ISR, enable CTS_PIN INTR
	
	sbi EIMSK, INT3      ; povolit INT3
; USART0_UDRE_ISR_disable:
	push r16
	lds r16, UCSR0B		; disable us
	andi r16, ~(1 << UDRIE0)
	sts UCSR0B, r16

	pop r16
	IRQ_pop_entry
	reti

TX_send:
	IRQ_push_16_20_Z

	lds r18, TX_Count
	cpi r18, 0
	breq TX_EMPTY

	lds r19, TX_Tail
	ldi ZL, lo8(RX_Buffer)
	ldi ZH, hi8(RX_Buffer)
	add ZL, r19
	adc ZH, r1
	ld  r16,Z
	sts UDR0, r16	; send it
	dec r18		; TX_Count--
	sts TX_Count, r18
	inc r19		; Tail++
	cpi r19, TX_BUFFER_SIZE
	brlt TX__skip_overflow	; modulo overflow?
	clr r19			; yes, max->0
TX__skip_overflow:
	sts TX_Head, r19	; normal way

	rjmp TX__exit
TX_EMPTY:
	; zakázat UDRE interrupt pokud nic k odeslání
	lds r16, UCSR0B
	andi r16, ~(1 << UDRIE0)
	sts UCSR0B, r16
TX__exit:
	IRQ_pop_16_20_Z
	IRQ_pop_entry
	reti

.global INT3_ISR
INT3_ISR:	; called when CTS is low and send is still blocked
	IRQ_push_entry
	cbi EIMSK, INT3      ; zakazat INT3
	push r16
	lds r16, UCSR0B		; enable TX
	ori r16, (1 << UDRIE0)
	sts UCSR0B, r16

	pop r16
	IRQ_pop_entry
	reti



; === TX0_Write: vstup r24 = znak, blokuje při plném bufferu
.global TX0_Write
TX0_Write:
TX_WAIT:
	lds r18, TX_Count
	cpi r18, TX_BUFFER_SIZE
	breq TX_WAIT
	lds r19, TX_Head
	ldi ZL, lo8(RX_Buffer)
	ldi ZH, hi8(RX_Buffer)
	add ZL, r19
	adc ZH, r1
	st Z, r24
	in r25,SREG
	cli			; ==== no interrupts here
	lds r18, TX_Count	; TX_Count ++
	inc r18
	sts TX_Count, r18
	out SREG,r25		; ==== ok
	lds r19, TX_Head
	inc r19
	cpi r19, TX_BUFFER_SIZE
	brlt TX__skip_overflow_write
	clr r19
TX__skip_overflow_write:
	sts TX_Head, r19

	; povolit UDRE interrupt
	lds r16, UCSR0B
	ori r16, (1 << UDRIE0)
	sts UCSR0B, r16
	ret

