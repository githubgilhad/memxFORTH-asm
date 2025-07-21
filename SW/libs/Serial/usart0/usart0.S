#include <avr/io.h>
#include <avr/interrupt.h>


; === Konstanta pro baud rate 115200 při 16 MHz a U2Xn = 0: UBRR = 8
.equ BAUD_UBRR,8



.macro IRQ_push_entry	; {{{
	push r1
	push r0
	in r0,_SFR_IO_ADDR(SREG)
	push r0
	in r0,_SFR_IO_ADDR(RAMPZ)
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
	out _SFR_IO_ADDR(RAMPZ),r0
	pop r0
	out _SFR_IO_ADDR(SREG),r0
	pop r0
	pop r1
.endm			; }}}

; === RX/TX buffer velikosti
.equ RX0_BUFFER_SIZE,64
.equ RX0_BUFFER_THRESHOLD,8
.equ TX0_BUFFER_SIZE,32

; === Sekce dat
.section .bss
qwer1: .byte 0
RX0_Count:		.byte 0	; if zero, head==tail means empty, if RX0_BUFFER_SIZE,  head==tail means full
RX0_Head:		.byte 0	; new character will came here
RX0_Tail:		.byte 0	; outcoming character will came from here
RX0_Buffer:		.skip RX0_BUFFER_SIZE	; data

TX0_Count:		.byte 0
TX0_Head:		.byte 0
TX0_Tail:		.byte 0
TX0_Buffer:		.skip TX0_BUFFER_SIZE
qwer2: .byte 0

.section .text

nop	; ctors end and trampolines will be here, lets have RESET named

; === setup()
.global usart0_setup
usart0_setup:
	sts RX0_Count, r1
	sts RX0_Head,  r1
	sts RX0_Tail,  r1
	sts TX0_Count, r1
	sts TX0_Head,  r1
	sts TX0_Tail,  r1
;
	; USART0 init: 8N1, RX+TX enable, RX interrupt, UDRE interrupt enable (TX)
	ldi r16, hi8(BAUD_UBRR)
	sts UBRR0H, r16
	ldi r16, lo8(BAUD_UBRR)
	sts UBRR0L, r16

;	ldi r16, 0	; U2Xn = 0
	ldi r16, (0 << RXC0) | (0 << TXC0) | (0 << UDRE0) | (0 << FE0) | (0 << DOR0) | (0 << UPE0) | (0 << U2X0) | (0 << MPCM0) 
	sts UCSR0A, r16
		;	Bit 1 – U2Xn: Double the USART Transmission Speed
		;	This bit only has effect for the asynchronous operation. Write this bit to zero when using synchronous operation.
		;	Writing this bit to one will reduce the divisor of the baud rate divider from 16 to 8 effectively doubling the transfer rate for asynchronous communication.
		;	• Bit 0 – MPCMn: Multi-processor Communication Mode
		;	This bit enables the Multi-processor Communication mode. When the MPCMn bit is written to one, all the incoming frames received by the USART Receiver that do not contain address information will be ignored. The Transmitter is unaffected by the MPCMn setting.


	ldi r16, (1 << RXEN0) | (1 << TXEN0) | (1 << RXCIE0) | (1 << TXCIE0) | (1 << UDRIE0)
	sts UCSR0B, r16
		; enable Receiver, Transmitter,  RX Complete, USART Data Register Empty , TX Complete (with reti only)
		;	UCSRnB
		;	• Bit 7 – RXCIEn: RX Complete Interrupt Enable n
		;	Writing this bit to one enables interrupt on the RXCn Flag. A USART Receive Complete interrupt will be generated only if the RXCIEn bit is written to one, the Global Interrupt Flag in _SFR_IO_ADDR(SREG) is written to one and the RXCn bit in UCSRnA is set.
		;	• Bit 6 – TXCIEn: TX Complete Interrupt Enable n
		;	Writing this bit to one enables interrupt on the TXCn Flag. A USART Transmit Complete interrupt will be generated only if the TXCIEn bit is written to one, the Global Interrupt Flag in _SFR_IO_ADDR(SREG) is written to one and the TXCn bit in UCSRnA is set.
		;	• Bit 5 – UDRIEn: USART Data Register Empty Interrupt Enable n
		;	Writing this bit to one enables interrupt on the UDREn Flag. A Data Register Empty interrupt will be generated only if the UDRIEn bit is written to one, the Global Interrupt Flag in _SFR_IO_ADDR(SREG) is written to one and the UDREn bit in UCSRnA is set.
		;	• Bit 4 – RXENn: Receiver Enable n
		;	Writing this bit to one enables the USART Receiver. The Receiver will override normal port operation for the RxDn pin when enabled. Disabling the Receiver will flush the receive buffer invalidating the FEn, DORn, and UPEn Flags.
		;	• Bit 3 – TXENn: Transmitter Enable n
		;	Writing this bit to one enables the USART Transmitter. The Transmitter will override normal port operation for the TxDn pin when enabled. The disabling of the Transmitter (writing TXENn to zero) will not become effective until ongoing and pending transmissions are completed, that is, when the Transmit Shift Register and Transmit Buffer Register do not contain data to be transmitted. When disabled, the Transmitter will no longer override the TxDn port.
		;	• Bit 2 – UCSZn2: Character Size n
		;	The UCSZn2 bits combined with the UCSZn1:0 bit in UCSRnC sets the number of data bits (Character SiZe) in a frame the Receiver and Transmitter use.
		;	• Bit 1 – RXB8n: Receive Data Bit 8 n
		;	RXB8n is the ninth data bit of the received character when operating with serial frames with nine data bits. Must be read before reading the low bits from UDRn.
		;	• Bit 0 – TXB8n: Transmit Data Bit 8 n
		;	TXB8n is the ninth data bit in the character to be transmitted when operating with serial frames with nine data bits.  Must be written before writing the low bits to UDRn.


	ldi r16, (1 << UCSZ01) | (1 << UCSZ00)
	sts UCSR0C, r16
		; Asynchronous USART, Parity Mode disabled, Stop Bit(s) 1, Character Size = 8bit, Clock Polarity =0



	ret

; === USART0 RX ISR
.global USART0_RX_ISR
USART0_RX_ISR:
	IRQ_push_entry
	IRQ_push_16_20_Z
	lds r16, UDR0	; incomming data

	; count ok?
	lds r18, RX0_Count
	cpi r18, RX0_BUFFER_SIZE	; is buffer full?
	breq RX0_FULL ; if yes, exit and ignore this char

	lds r19, RX0_Head	; not full, add char
	ldi ZL, lo8(RX0_Buffer)
	ldi ZH, hi8(RX0_Buffer)
	add ZL, r19
	adc ZH, r1
	st Z, r16
	inc r18		; RX0_Count++
	sts RX0_Count, r18
	inc r19		; HEAD++
	cpi r19, RX0_BUFFER_SIZE
	brlt 1f	; modulo overflow?
	clr r19			; yes, max->0
1:
	sts RX0_Head, r19	; normal way


RX0_EXIT:
RX0_FULL:
	IRQ_pop_16_20_Z
	IRQ_pop_entry
	reti

; === RX0_Read: Výstup r24 = znak, r25 = delka bufferu PRED ctenim (1..RX0_BUFFER_SIZE) pokud data, jinak 0
.global RX0_Read
RX0_Read:
	lds r18, RX0_Count
	mov r25,r18
	cpi r18, 0
	breq RX0_EMPTY_FUNC
	lds r19, RX0_Tail
	ldi ZL, lo8(RX0_Buffer)
	ldi ZH, hi8(RX0_Buffer)
	add ZL, r19
	adc ZH, r1
	ld r24, Z
	in r20,_SFR_IO_ADDR(SREG)
	cli			; ==== no interrupts here
	lds r18, RX0_Count	; RX0_Count --
	dec r18
	sts RX0_Count, r18
	out _SFR_IO_ADDR(SREG),r20		; ==== ok
	inc r19
	cpi r19, RX0_BUFFER_SIZE
	brlt 1f
	clr r19
1:
	sts RX0_Tail, r19
;	ldi r25, 1
	ret
RX0_EMPTY_FUNC:
	clr r24
;	clr r25
	ret

; === RX0_available: r24 = RX0_Count (# of waiting chars)
.global RX0_available
RX0_available:
	lds r24,RX0_Count
	ret

; === USART0 UDRE ISR	 - is output register empty?
.global USART0_UDRE_ISR
USART0_UDRE_ISR:
	IRQ_push_entry
	IRQ_push_16_20_Z

	lds r18, TX0_Count
	cpi r18, 0
	breq TX0_EMPTY

	lds r19, TX0_Tail
	ldi ZL, lo8(TX0_Buffer)
	ldi ZH, hi8(TX0_Buffer)
	add ZL, r19
	adc ZH, r1
	ld  r16,Z
	sts UDR0, r16	; send it
	dec r18		; TX0_Count--
	sts TX0_Count, r18
	inc r19		; Tail++
	cpi r19, TX0_BUFFER_SIZE
	brlt 1f	; modulo overflow?
	clr r19			; yes, max->0
1:
	sts TX0_Tail, r19	; normal way

	rjmp TX0__exit
TX0_EMPTY:
	; zakázat UDRE interrupt pokud nic k odeslání
	lds r16, UCSR0B
	andi r16, ~(1 << UDRIE0)
	sts UCSR0B, r16
TX0__exit:
	IRQ_pop_16_20_Z
	IRQ_pop_entry
	reti




; === TX0_Write: vstup r24 = znak, blokuje při plném bufferu, vystup r24 - aktualni delka bufferu
.global TX0_Write
TX0_Write:
	lds r18, TX0_Count
	cpi r18, TX0_BUFFER_SIZE
	breq TX0_Write
	lds r19, TX0_Head
	ldi ZL, lo8(TX0_Buffer)
	ldi ZH, hi8(TX0_Buffer)
	add ZL, r19
	adc ZH, r1
	st Z, r24
	in r25,_SFR_IO_ADDR(SREG)
	cli			; ==== no interrupts here
	lds r18, TX0_Count	; TX0_Count ++
	inc r18
	sts TX0_Count, r18
	out _SFR_IO_ADDR(SREG),r25		; ==== ok
	lds r19, TX0_Head
	inc r19
	cpi r19, TX0_BUFFER_SIZE
	brlt 1f
	clr r19
1:
	sts TX0_Head, r19

	; povolit UDRE interrupt
	lds r16, UCSR0B
	ori r16, (1 << UDRIE0)
	sts UCSR0B, r16
	mov r24,r18
	ret

; === TX0_used: output: r24 used space in TX buffer
.global TX0_used
TX0_used:
	lds r24, TX0_Count
	ret

; === TX0_free: output: r24 available space in TX buffer
.global TX0_free
TX0_free:
	ldi r24, TX0_BUFFER_SIZE
	lds r25, TX0_Count
	sub r24,r25
	ret
