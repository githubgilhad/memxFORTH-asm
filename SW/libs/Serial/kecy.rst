.. vim:   noexpandtab fileencoding=utf-8 nomodified   wrap textwidth=0 foldmethod=marker foldmarker={{{,}}} foldcolumn=4 ruler showcmd lcs=tab\:|- list tabstop=8 noexpandtab nosmarttab softtabstop=0 shiftwidth=0 linebreak showbreak=»\	ft=rst


You said:

Potreboval bych pro avr-gcc prostredi napsat zaklad programu v assembleru, ktery pro chip atmega2560 a USART0 cte byty, uklada je do bufferu a z jineho bufferu cte a odesila byty, oboji rizeno interrupty. Hlavni program by zatim mohl proste cist byty z prijimaciho bufferu a zapisovat je do odesilaciho (proste echo). Nastaveni pro rychlost 115200 a obvykly Serial.
Prijimaci buffer by 64 bytu dlouhy, pokud by zbyvalo 8 a mene bytu, nastavil by se priznak RTS (aby protistrana prestala vysilat), plnil by se z intrerruptu pri prichodu znaku. Cetl by se po jednom znaku funkci, ktera by pri prazdnem bufferu neblokovala, ale vracela znak 0x00 a priznak, ze je buffer prazdny. 
Vysilaci buffer by byl velky jen 32 bytu, zapisoval by se po jednom znaku funkci, ktera by pri plnem bufferu blokovala, odesilal by se z interruptu, ale pokud by byl nastaveny CTS(ze protistrana nestiha), tak by se s odeslanim cekalo az tento priznak zmizi.
RTS a CTS by byly nejake konkretni piny (ted tu nemam schema, tak to zmenim pozdeji, CTS urcite umoznuje nejake preruseni)

ChatGPT said:

Rozumím. Chceš základní prostředí v assembleru pro avr-gcc, konkrétně pro ATmega2560, které implementuje:

* Funkce systému
	* USART0 RX interrupt přijímá znaky a ukládá je do 64B bufferu.
		* Pokud zbývá ≤ 8 bytů, nastaví se RTS (výstupní pin).
	* USART0 UDRE interrupt posílá znaky z 32B TX bufferu.
		* Pokud je CTS (vstupní pin) aktivní (protistrana nestíhá), odesílání se pozastaví.
	* Hlavní smyčka čte znaky z RX bufferu a zapisuje je do TX bufferu – echo.
	* Funkce pro čtení a zápis do bufferu:
		* RX čte znak (neblokuje, vrací stav prázdnosti).
		* TX zapisuje znak (blokuje při plném bufferu).

Níže je základní kostra v AVR assembleru (komentovaná), určená pro avr-gcc s -mmcu=atmega2560:
* Předpoklady (nastavitelné později)
	* Baud rate: 115200
	* RTS: Port D, bit 2 (PD2)
	* CTS: Port D, bit 3 (PD3) – s povolením externího přerušení
	* Používáme: USART0, tedy registry UDR0, UCSR0A, UCSR0B, UCSR0C, UBRR0H, UBRR0L
* Kód: usart0_echo.asm


.. code::

	.include "m2560def.inc"

	; === Konstanta pro baud rate 115200 při 16 MHz: UBRR = 16
	.equ BAUD_UBRR = 16

	; === RTS / CTS PINY
	.equ RTS_PIN = PD2
	.equ CTS_PIN = PD3

	; === RX/TX buffer velikosti
	.equ RX_BUFFER_SIZE = 64
	.equ RX_BUFFER_THRESHOLD = 8
	.equ TX_BUFFER_SIZE = 32

	; === Sekce dat
	.dseg
	RX_Buffer:		.byte RX_BUFFER_SIZE
	RX_Head:		.byte 1
	RX_Tail:		.byte 1
	RX_Count:		.byte 1

	TX_Buffer:		.byte TX_BUFFER_SIZE
	TX_Head:		.byte 1
	TX_Tail:		.byte 1
	TX_Count:		.byte 1

	.cseg
	.org 0x00
		rjmp RESET

	.org USART0_RX_vect
		rjmp USART0_RX_ISR

	.org USART0_UDRE_vect
		rjmp USART0_UDRE_ISR

	; === RESET
	RESET:
		ldi r16, HIGH(RAMEND)
		out SPH, r16
		ldi r16, LOW(RAMEND)
		out SPL, r16

		; USART0 init: 8N1, RX+TX enable, RX interrupt, UDRE interrupt enable (TX)
		ldi r16, high(BAUD_UBRR)
		out UBRR0H, r16
		ldi r16, low(BAUD_UBRR)
		out UBRR0L, r16

		ldi r16, (1 << RXEN0) | (1 << TXEN0) | (1 << RXCIE0) | (1 << UDRIE0)
		out UCSR0B, r16

		ldi r16, (1 << UCSZ01) | (1 << UCSZ00)
		out UCSR0C, r16

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
		push r16
		in r16, UDR0

		; načíst hlavu a počet
		lds r18, RX_Count
		cpi r18, RX_BUFFER_SIZE
		breq RX_FULL ; buffer plný – ignorujeme příchozí znak

		lds r19, RX_Head
		ldi r20, lo8(RX_Buffer)
		add r19, r20
		st Z, r16
		inc r18 ; RX_Count++
		sts RX_Count, r18

		lds r19, RX_Head
		inc r19
		cpi r19, RX_BUFFER_SIZE
		brlt RX_H_OK
		clr r19
	RX_H_OK:
		sts RX_Head, r19

		; RTS: pokud zbývá málo místa, nastav pin
		cpi r18, RX_BUFFER_SIZE - RX_BUFFER_THRESHOLD
		brlt RTS_CLEAR
		sbi PORTD, RTS_PIN
		rjmp RX_EXIT
	RTS_CLEAR:
		cbi PORTD, RTS_PIN

	RX_EXIT:
		pop r16
		reti
	RX_FULL:
		pop r16
		reti

	; === USART0 UDRE ISR
	USART0_UDRE_ISR:
		; CTS kontrola – pokud CTS=1, čekáme
		sbis PIND, CTS_PIN
		reti ; CTS aktivní, neodešleme

		lds r18, TX_Count
		cpi r18, 0
		breq TX_EMPTY

		lds r19, TX_Tail
		ldi r20, lo8(TX_Buffer)
		add r19, r20
		ld r16, Z
		out UDR0, r16

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
		in r16, UCSR0B
		andi r16, ~(1 << UDRIE0)
		out UCSR0B, r16
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
		in r16, UCSR0B
		ori r16, (1 << UDRIE0)
		out UCSR0B, r16
		ret

* Poznámky:
	* Můžeš upravit RTS/CTS piny dle konkrétního schématu.
	* CTS kontroluje, zda se vůbec má posílat – UDRE ISR čeká pokud je CTS aktivní.
	* Funkce RX_Read a TX_Write jsou připraveny volat z C nebo ASM programu.
	* TX_Write blokuje, ale lze ji upravit i na neblokující variantu.

