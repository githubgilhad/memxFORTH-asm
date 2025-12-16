// vim: ft=asm showbreak=--»\  noexpandtab fileencoding=utf-8 nomodified wrap textwidth=0 foldmethod=marker foldmarker={{{,}}} foldcolumn=4 ruler showcmd lcs=tab\:|- list: tabstop=8 linebreak
// ,,g = gcc, exactly one space after "set"
#define __SFR_OFFSET 0x00		// set the Special Function Register Offset from 0x20 to 0x00 in order to use AVR PORT definitions
#include <avr/io.h>			// include PORTB, DDRD, ... symbols for easier register access

#include "MHF-002/MHF-002/MHF-002.h"
#include "TextVGA.def"

; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Interface:
;
.section .bss.TextVGA

; // 1. fill these pointer to point to your VideoRam structures in FAST RAM (0x200..0x2200)
.global TextVGA_VRAM, TextVGA_CRAM
; // 2. this pointer goes to FLASH, like this: TextVGA_CharDef = pgm_get_far_address(StdTextCharDef);
.global TextVGA_CharDef
; // if not NULL called in ISR after last line is drawn and lot of free time is ahead.  it is still in IRQ, so best approach is to just set few flags and bussy wait for them in main program. called 60 times per second
.global TextVGA_VerticalBlank

; // /////////// automagically updated variables:

.global TextVGA_scanline; // 0..199 top porch, 200..400 visible
.global TextVGA_textline; // 0..24 line of text
.global TextVGA_subline; // 0..7 line of character

.section .text.TextVGA
// Then make sure this (normal C) functions are called from respective IRQ handlers
.global TextVGA_TIMER1_OVF_vect_handler, TextVGA_TIMER3_OVF_vect_handler

// Then call TextVGA_begin() so the VideoRam is showed on VGA monitor

.global TextVGA_begin;

// Call TextVGA_end() to stop displaying VideoRam (and then maybe activate other driver similar way)

.global TextVGA_end;
; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Implementation:
.macro check number	; {{{
	cpi r20, \number
	brlo 1f
1:
.endm			; }}}
.macro inc_mem mem	; {{{
	lds r24, \mem
	inc r24
	sts \mem, r24
.endm			; }}}
.macro inc_mem2 mem	; {{{
	lds r24, \mem
	lds r25, \mem +1
	adiw r24, 1
	sts \mem, r24
	sts \mem+1, r25
.endm			; }}}
.macro ONECHAR					// {{{ Z: address of char data (MSB is fixed, LSB depends on char), X: current VRAM position (one line)
	ld    ZL, X+				// 2CP ZL = (X), X = X + 1
	lpm   r21, Z				// 3CP get font byte from program memory for current chr on current line
	out   XCAT(PORT,VGA_DATA_PORT), r21	// 1CP put data to shift register's parallel input
	
	out   XCAT(PIN,VGA_LATCH_PORT), r24	// 1CP flip B7 LOW
	out   XCAT(PIN,VGA_LATCH_PORT), r24	// 1CP flip B7 HIGH
 .endm						// }}}

.section .bss.TextVGA
TextVGA_VRAM:	.word 0 	; *T_VRAM
TextVGA_CRAM:	.word 0 	; *T_CRAM
TextVGA_CharDef:	.word 0,0 	; P_TextVGA_CharDef = uint32_t
TextVGA_VerticalBlank:	.word 0 	; 16bits, gcc will use trampoline
TextVGA_scanline:	.word 0 	; // 0..59 top porch, 60..260 visible
TextVGA_textline:	.byte 0 	; // 0..24 line of text
TextVGA_subline:	.byte 0 	; // 0..7 line of character
TextVGA_VRAM_ptr:	.word 0 	; start of current line in VRAM
TextVGA_CRAM_ptr:	.word 0 	; current line in CRAM
TextVGA_subline_ptr:	.word 0 	; start of current subline in Flash - 24bit, but lo=0 by definition


.section .text.TextVGA
; // Then make sure this (normal C) functions are called from respective IRQ handlers

TextVGA_TIMER1_OVF_vect_handler:	; {{{ VGA Hsync
.type TextVGA_TIMER1_OVF_vect_handler, @function
	eor r0,r0
	lds r24, TextVGA_scanline
	lds r25, TextVGA_scanline + 1
	adiw r24,1
	sts TextVGA_scanline, r24
	sts TextVGA_scanline+1, r25
	subi r24, lo8(TextVGA_FIRST_SCAN_LINE)
	sbci r25, hi8(TextVGA_FIRST_SCAN_LINE)
	brsh 1f
	ret	; PS/2 will be handled separately
; 	rjmp .TextVGA_TIMER1_OVF_vect_handler_end_before
1:
	subi r24, lo8(TextVGA_ACTIVE_SCAN_LINES)
	sbci r25, hi8(TextVGA_ACTIVE_SCAN_LINES)
	brlo 1f
	ret	; PS/2 will be handled separately
;	rjmp .TextVGA_TIMER1_OVF_vect_handler_end_after
1:
	set_output_all(VGA_COLOR,sts)	; output COLORs
	lds ZL,TextVGA_CRAM_ptr
	lds ZH,TextVGA_CRAM_ptr+1
	ld r20,Z
	sts XCAT(PORT,VGA_COLOR_PORT),r20
	
	set_output_all(VGA_DATA,out)	; prepare for outputting DATA
		; ZL = 0 by def, we reuse it now for RAMPZ, will be overwritten later
	in ZL, RAMPZ
	push ZL
	lds ZL, TextVGA_subline_ptr+1
	out RAMPZ, ZL
	lds ZH, TextVGA_subline_ptr

	lds XL, TextVGA_VRAM_ptr
	lds XH, TextVGA_VRAM_ptr+1
	
	lds r20, TCNT1	; synchronise
	andi r20, 7
	check 7
	check 6
	check 5
	check 4
	check 3
	check 2
	check 1
	
	set_output(VGA_LATCH)
	out_hi(VGA_LATCH)		; hi=get data, low=clock out
	ldi r24, 1<<VGA_LATCH_PIN
; ONECHAR expanded
	ld    ZL, X+				// 2CP ZL = (X), X = X + 1
	lpm   r21, Z				// 3CP get font byte from program memory for current chr on current line
	out   XCAT(PORT,VGA_DATA_PORT), r21	// 1CP put data to shift register's parallel input
	
	out   XCAT(PIN,VGA_LATCH_PORT), r24	// 1CP flip B7 LOW
	out_lo(VGA_ENABLE)
	out   XCAT(PIN,VGA_LATCH_PORT), r24	// 1CP flip B7 HIGH

.rept TextVGA_ROWS -1
	ONECHAR
.endr

	pop ZL
	out RAMPZ, ZL
nop
nop
nop
; VGA_ENABLE hi must be 8 clocks after last ONECHAR
	out_hi(VGA_ENABLE)
;
	;
	inc_mem2 TextVGA_subline_ptr
	lds r24, TextVGA_subline
	inc r24
	andi r24,0x07
	sts TextVGA_subline, r24
	brne 1f
		; next line
		lds r24, TextVGA_CharDef+1	; TextVGA_CharDef+0 = 0 by definition
		lds r25, TextVGA_CharDef+2
		sts TextVGA_subline_ptr, r24
		sts TextVGA_subline_ptr+1, r25
		inc_mem2 TextVGA_CRAM_ptr
	lds r24, TextVGA_VRAM_ptr
	lds r25, TextVGA_VRAM_ptr+1
	adiw r24, TextVGA_ROWS
	sts TextVGA_VRAM_ptr, r24
	sts TextVGA_VRAM_ptr+1, r25

		inc_mem TextVGA_textline
		cpi r24, TextVGA_LINES +1
		brne 1f
		; last line just ended, call TextVGA_VerticalBlank (maybe via trampoline)
		lds Zl, TextVGA_VerticalBlank
		lds ZH, TextVGA_VerticalBlank+1
		sbiw ZL,0
		breq 1f
		icall

1:
	ret



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; PS/2 will be handled separately
;.TextVGA_TIMER1_OVF_vect_handler_end_before:	// before visible after
;.TextVGA_TIMER1_OVF_vect_handler_end_after:	// after visible area
; }}}

TextVGA_TIMER3_OVF_vect_handler:	; {{{  VGA VSync
.type TextVGA_TIMER3_OVF_vect_handler, @function
	eor r0,r0
	sts TextVGA_scanline, r0
	sts TextVGA_scanline+1, r0
	sts TextVGA_textline, r0
	sts TextVGA_subline, r0
	lds r24, TextVGA_VRAM
	lds r25, TextVGA_VRAM+1
	sts TextVGA_VRAM_ptr, r24
	sts TextVGA_VRAM_ptr+1, r25
	lds r24, TextVGA_CRAM
	lds r25, TextVGA_CRAM+1
	sts TextVGA_CRAM_ptr, r24
	sts TextVGA_CRAM_ptr+1, r25
	lds r24, TextVGA_CharDef+1	; TextVGA_CharDef+0 = 0 by definition
	lds r25, TextVGA_CharDef+2
	sts TextVGA_subline_ptr, r24
	sts TextVGA_subline_ptr+1, r25
	; TODO enable Hsync IRQ
	ret
; }}}

; // Then call TextVGA_begin() so the VideoRam is showed on VGA monitor

TextVGA_begin:		; {{{ set Timers, enable IRQs, set DDRs
.type TextVGA_begin, @function
	set_output(VGA_LATCH)		; 
	out_hi(VGA_LATCH)		; hi=get data, low=clock out
	set_output(VGA_ENABLE)		; 
	out_hi(VGA_ENABLE)		; hi=disabled, no output
	set_output(VGA_VSYNC)
	set_output(VGA_HSYNC)
	set_output_all(VGA_DATA,out)
	set_output_all(VGA_COLOR,sts)
	cli
	; set timers
	ldi r24, (1<<TSM) | (1<<PSRASY) | (1 <<PSRSYNC)
	out GTCCR, r24
		; GTCCR= (1<<TSM) | (1<<PSRASY) | (1 <<PSRSYNC); // stop Timers 0,1,3,4,5 for synchronisation pg. 166:
			/* Bit 7 - TSM: Timer/Counter Synchronization Mode
			Writing the TSM bit to one activates the Timer/Counter Synchronization mode. In this mode, the value that is writ-
			ten to the PSRASY and PSRSYNC bits is kept, hence keeping the corresponding prescaler reset signals asserted.
			This ensures that the corresponding Timer/Counters are halted and can be configured to the same value without
			the risk of one of them advancing during configuration. When the TSM bit is written to zero, the PSRASY and
			PSRSYNC bits are cleared by hardware, and the Timer/Counters start counting simultaneously.
			
			Bit 0  PSRSYNC: Prescaler Reset for Synchronous Timer/Counters
			When this bit is one, Timer/Counter0, Timer/Counter1, Timer/Counter3, Timer/Counter4 and Timer/Counter5 pres-
			caler will be Reset. This bit is normally cleared immediately by hardware, except if the TSM bit is set. Note that
			Timer/Counter0, Timer/Counter1, Timer/Counter3, Timer/Counter4 and Timer/Counter5 share the same prescaler
			and a reset of this prescaler will affect all timers.
			*/




	// *****************************
	// ***** Timer1: VGA HSYNC *****
	// *****************************
	//           PB[6] D12          
		; write H, then L, read L, then H - pg.135
		; TCNT1=0;
	sts TCNT1H,r1
	sts TCNT1L,r1

//	// Mode: set timer to Fast PWM with TOP = ICR1
	
	; attach output pin PB6 = OC1B
			/*
			TCCR1A
			Bit 7:6  COMnA1:0: Compare Output Mode for Channel A
			Bit 5:4  COMnB1:0: Compare Output Mode for Channel B
			Bit 3:2  COMnC1:0: Compare Output Mode for Channel C
			The COMnA1:0, COMnB1:0, and COMnC1:0 control the output compare pins (OCnA, OCnB, and OCnC respec-
			tively) behavior. If one or both of the COMnA1:0 bits are written to one, the OCnA output overrides the normal port
			functionality of the I/O pin it is connected to. If one or both of the COMnB1:0 bits are written to one, the OCnB out-
			put overrides the normal port functionality of the I/O pin it is connected to. If one or both of the COMnC1:0 bits are
			written to one, the OCnC output overrides the normal port functionality of the I/O pin it is connected to. However,
			note that the Data Direction Register (DDR) bit corresponding to the OCnA, OCnB or OCnC pin must be set in
			order to enable the output driver.
			*/
		; TCCR1A = (1 << COM1B1) | (1 << COM1B0) | (1 << WGM11); // COM1B = 0b11, WGM11=1
	ldi r24, (1 << COM1B1) | (1 << COM1B0) | (1 << WGM11)
	sts TCCR1A, r24
		; TCCR1B = (1 << WGM13) | (1 << WGM12) | (1 << CS10);     // WGM13:2 = 1110 => Fast PWM ICR1 top, prescaler 1
	ldi 24, (1 << WGM13) | (1 << WGM12) | (1 << CS10)
	sts TCCR1B, r24
		; TCCR1C ignored in PWM
	
		; ICR1 = 511;     // perioda = 512 ticks (32 µs)
	ldi r24, lo8(511)
	ldi r25, hi8(511)
	sts ICR1H, r25
	sts ICR1L, r24
		; OCR1B = 60;   // 61 ticků LOW ≈ 3.8 µs
	ldi r24, 60
	sts OCR1BH, r1
	sts OCR1BL, r24
			// F_CPU  16 MHz - 1 tick = 62,5 ns
			//
			// For period 32 µs I need
			// 32 μs / 62,5 ns = 512 ticks
			// 61 ticks LOW ≈ 3.8 µs

	; Enable this interrupt TIMER1_OVF_vect:
			; Bit 0 -  TOIEn: Timer/Countern, Overflow Interrupt Enable
			/* When this bit is written to one, and the I-flag in the Status Register is set (interrupts globally enabled), the
			Timer/Countern Overflow interrupt is enabled. The corresponding Interrupt Vector (see “Interrupts” on page 101) is
			executed when the TOVn Flag, located in TIFRn, is set.
			*/
		
		; TIMSK1 = (1 << TOIE1); 
	ldi r24, (1 << TOIE1)
	sts TIMSK1, r24
	
			// ISR timer overflow
			// ISR(TIMER1_OVF_vect) {}
			// This will be called each 32 µs

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	// *****************************
	// ***** Timer3: VGA VSYNC *****
	// *****************************
	//            PE[4] D2          

		; write H, then L, read L, then H - pg.135
		; TCNT3=0;
	sts TCNT3H,r1
	sts TCNT3L,r1
	
//	// Mode: Fast PWM, TOP=ICR3, Set on Compare, Clear on Bottom

	;  attach output pin PE4 = OC3B
		; TCCR3A = (1 << COM3B1) | (1 << COM3B0) | (1 << WGM31); 
	ldi r24, (1 << COM3B1) | (1 << COM3B0) | (1 << WGM31)
	sts TCCR3A, r24
		; TCCR3B = (1 << WGM33) | (1 << WGM32) | (1 << CS32) | (1 << CS30); // prescaler 1024
	ldi r24, (1 << WGM33) | (1 << WGM32) | (1 << CS32) | (1 << CS30)
	sts TCCR3B, r24
		; TCCR3C ignored in PWM
	
		; ICR3 = 259;   // period = 130 ticks	// // 60cols (24MHz): 389, 40cols (16MHz): 259, compare match register A (TOP) -> 16.64ms
	ldi r24, lo8(259)
	ldi r25, hi8(259)
	sts ICR3H, r25
	sts ICR3L, r24
		; OCR3B = 0;    // LOW = 1 tick = 64 µs
	sts OCR3BH, r1
	sts OCR3BL, r1

	; Enable this interrupt TIMER3_OVF_vect:
		; TIMSK3 = (1 << TOIE3);	// enable timer overflow interrupt setting vlines = 0
	ldi r24, (1 << TOIE3)
	sts TIMSK3, r24
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

		; GTCCR = 0;	// clear TSM => all timers start synchronously
	out GTCCR, r1
		; UCSR1B = 0;	// brute-force the USART1 off just in case... ??
	sts UCSR1B, r1

	sei

	ret
; }}}

; // Call TextVGA_end() to stop displaying VideoRam (and then maybe activate other driver similar way)

TextVGA_end:		; {{{ disable interrupts and timers output
.type TextVGA_end, @function

	; no interrupt on Timer1 Overflow
		; TIMSK1 = 0; 
	sts TIMSK1, r1
	
	; no output pin for OCR1B
	sts TCCR1A, r1

	; no interrupt on Timer3 Overflow
		; TIMSK3 = 0; 
	sts TIMSK3, r1
	
	; no output pin for OCR3B
	sts TCCR3A, r1

	ret
; }}}
