; .. vim: ft=asm showbreak=--»\  noexpandtab fileencoding=utf-8 nomodified   wrap textwidth=0 foldmethod=marker foldmarker={{{,}}} foldcolumn=4 ruler showcmd lcs=tab\:|- list tabstop=8 noexpandtab nosmarttab softtabstop=0 shiftwidth=0 linebreak  tags=./tags;,tags; 

// 
#define __SFR_OFFSET 0x00		// set the Special Function Register Offset from 0x20 to 0x00 in order to use AVR PORT definitions
#include <avr/io.h>
#include <avr/interrupt.h>
#include <stdbool.h>
#include "MHF-002.h"
#include "FORTH-Defines.h"
#include "FORTH-Macros.h"
/*
pg.111
EICRB – External Interrupt Control Register B
• Bits 7:0 – ISC71, ISC70 - ISC41, ISC40: External Interrupt 7 - 4 Sense Control Bits
The External Interrupts 7 - 4 are activated by the external pins INT7:4 if the SREG I-flag and the corresponding
interrupt mask in the EIMSK is set. The level and edges on the external pins that activate the interrupts are defined
in Table 15-3. The value on the INT7:4 pins are sampled before detecting edges. If edge or toggle interrupt is
selected, pulses that last longer than one clock period will generate an interrupt. Shorter pulses are not guaranteed
to generate an interrupt. Observe that CPU clock frequency can be lower than the XTAL frequency if the XTAL
divider is enabled. If low level interrupt is selected, the low level must be held until the completion of the currently
executing instruction to generate an interrupt. If enabled, a level triggered interrupt will generate an interrupt
request as long as the pin is held low.
Table 15-3.  EICRB 
ISCn? Description
 1 0
 0 0 The low level of INTn generates an interrupt request
 0 1 Any logical change on INTn generates an interrupt request
 1 0 The falling edge between two samples of INTn generates an interrupt request
 1 1 The rising edge between two samples of INTn generates an interrupt request
Note:
15.2.3
Interrupt Sense Control(1)
1. n = 7, 6, 5 or 4.
When changing the ISCn1/ISCn0 bits, the interrupt must be disabled by clearing its Interrupt Enable bit in the
EIMSK Register. Otherwise an interrupt can occur when the bits are changed.
EIMSK – External Interrupt Mask Register
EIMSK
• Bits 7:0 – INT7:0: External Interrupt Request 7 - 0 Enable
When an INT7:0 bit is written to one and the I-bit in the Status Register (SREG) is set (one), the corresponding
external pin interrupt is enabled. The Interrupt Sense Control bits in the External Interrupt Control Registers –
EICRA and EICRB – defines whether the external interrupt is activated on rising or falling edge or level sensed.
Activity on any of these pins will trigger an interrupt request even if the pin is enabled as an output. This provides a
way of generating a software interrupt.
*/

/*
    28fc:	6e 98       	cbi	0x0d, 6	; 13
    28fe:	76 9a       	sbi	0x0e, 6	; 14

    2900:	ee 98       	cbi	0x1d, 6	; 29
    2902:	ea e6       	ldi	r30, 0x6A	; 106
    2904:	f0 e0       	ldi	r31, 0x00	; 0
    2906:	80 81       	ld	r24, Z
    2908:	8f 7e       	andi	r24, 0xEF	; 239
    290a:	80 83       	st	Z, r24
    290c:	80 81       	ld	r24, Z
    290e:	80 62       	ori	r24, 0x20	; 32
    2910:	80 83       	st	Z, r24
    2912:	e6 9a       	sbi	0x1c, 6	; 28
    2914:	ee 9a       	sbi	0x1d, 6	; 29
    2916:	08 95       	ret
*/

gfunc PS2_init	; {{{
	Ldi3	Zx,	PS2_input_ROM_Size
	in	r24,	RAMPZ
	out	RAMPZ,	Z_hlo
	elpm	r25,	Z
	out	RAMPZ,	r24
	Ldi2	Zx2,	PS2_input
	st	Z,	r25
	call	BUF_Init_Z
	set_input_pullup(PS2_INSIDE)
	cbi	EIMSK,	INT6		; disable INT6
	Ldi2	Zx2,	EICRB
	ld	r24,	Z
	andi	r24,	~_BV(ISC60)
	ori	r24,	_BV(ISC61)
	st	Z,	r24		;  ISC60 = 0 ISC61 = 1
	sbi	EIFR,	INT6		; clear pending flag
	sbi	EIMSK,	INT6		; enable INT6
;	sei				; enable interrupt when convenient
	ret
; }}}

gfunc INT6_vect	; {{{
	push r1
	push r0
	in	r0,	SREG
	push r0
	in	r0,	RAMPZ
	push r0
	clr	r1
	push r22	; Parsx_lo
	push r23	; Parsx_hi
	push r24	; MHF-002 temp register
	push ZL
	push ZH
	set_input_all(PS2_DATA, out)
	set_output(PS2_OE)			;  enable output, read, disable
	out_lo(PS2_OE)
	in r22,XCAT(PIN,PS2_DATA_PORT)
	in r22,XCAT(PIN,PS2_DATA_PORT)
	in r22,XCAT(PIN,PS2_DATA_PORT)
	out_hi(PS2_OE)
	set_output_all(PS2_DATA, out)
	clr r1
	out XCAT(PORT,PS2_DATA_PORT),r1
	Ldi2	Zx2,	PS2_input
	call	BUF_Write_ZP
	sbi	DDRD,0
	sbi	PIND,0
	pop ZH
	pop ZL
	pop r24
	pop r23
	pop r22
	pop r0
	out	RAMPZ,	r0
	pop r0
	out	SREG,	r0
	pop r0
	pop r1
	reti


; }}}

.section .bss
DEF_BUFF PS2_input, 16

/*
ISR(INT6_vect)
{
   DDRF=0;
   // PS2-OE = PE2 - enable output, read, disable
   DDRE |= _BV(2);
   PORTE &= ~ _BV(2); // LOW
   // nop
   uint8_t key;
    key=PINF;
    key=PINF;
    key=PINF;	// with 1k  resistors it seems, that we need 2clocks to stabilise and we can read in 3. clock stable value.
   PORTE |= _BV(2); //high
   DDRF=0xff;
   PORTF=~key;
   
// TX0_WriteStr(" [0x");
// TX0_WriteHex8(key);
// TX0_WriteStr("] ");
   

}

*/

