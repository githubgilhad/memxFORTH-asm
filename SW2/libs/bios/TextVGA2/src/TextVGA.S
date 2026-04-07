; .. vim: ft=asm showbreak=--»\  noexpandtab fileencoding=utf-8 nomodified   wrap textwidth=0 foldmethod=marker foldmarker={{{,}}} foldcolumn=4 ruler showcmd lcs=tab\:|- list tabstop=8 noexpandtab nosmarttab softtabstop=0 shiftwidth=0 linebreak  tags=./tags;,tags; 


#define __SFR_OFFSET 0x00		// set the Special Function Register Offset from 0x20 to 0x00 in order to use AVR PORT definitions
#include <avr/io.h>			// include PORTB, DDRD, ... symbols for easier register access

#include "MHF-002.h"
#include "TextVGA.inc"
#include "FORTH-Macros.h"		//  ../../../FORTH/FORTH-Macros/include/FORTH-Macros.h


#define	TIMER1_COMPA_start	39	// 0..511  position inside H line
#define	TIMER3_COMPA_start	(TextVGA_FIRST_SCAN_LINE *2)	// 0..1040  first horizontal line *2
#define	TIMER3_COMPC_start	(TextVGA_LAST_SCAN_LINE  *2)	// 0..1040  last horizontal line  *2

#define	HANDLER_OFFSET		25	// clocks from interrupt start to handler start
#define TOO_LONG		2	// how many we can compensate

; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Interface:
;
.section .bss.TextVGA

; // 1. fill these pointer to point to your VideoRam structures in FAST RAM (0x200..0x2200)
gobj TextVGA_VRAM		$	.word 0 	;  *T_VRAM
gobj TextVGA_CRAM		$	.word 0 	;  *T_CRAM
; // 2. this pointer goes to FLASH, like this: TextVGA_CharDef = pgm_get_far_address(StdTextCharDef);
gobj TextVGA_CharDef		$	.word 0,0 	; P_TextVGA_CharDef = uint32_t
	
; // if not NULL called in ISR after last line is drawn and lot of free time is ahead.  it is still in IRQ, so best approach is to just set few flags and bussy wait for them in main program. called 60 times per second
gobj TextVGA_VerticalBlank	$	.word 0 	; 16bits, gcc will use trampoline
gobj TextVGA_cursor_ptr		$	.word 0 	; pointer into VRAM where cursor should be drawn 
gobj TextVGA_cursor_char	$	.byte 0 	; Character for alternate as cursor 
gobj TextVGA_cursor_c_temp	$	.byte 0 	; INTERNAL place for alternating character 
gobj TextVGA_cursor_time	$	.byte 0 	; time for count down for alternating 
gobj TextVGA_cursor_enabled	$	.byte 0 	; 0 = disabled 

obj TextVGA_cursor_visible	$	.byte 0 	; actual state 
obj TextVGA_cursor_counter	$	.byte 0 	; counter down for alternating 

jitter: .word 0,0
.section .text.TextVGA

#define	Ltmp1	r0
#define	L_one	r2
#define	subline_ptrH	r4
#define	subline_ptrHL	r5
#define	line_startL	r6
#define	line_startH	r7
#define	jitter_act	r8
#define	jitter_min	r9
#define	jitter_max	r10
#define	subline_cnt	r16
#define	pinflip		r17
#define	temp_2	r22
#define	temp_3	r23
#define	temp_4	r24
#define	temp_5	r25

#define	CRAM_ptrL	YL
#define	CRAM_ptrH	YH


.macro check number	; {{{
	cpi temp_4, \number
	brlo 1f
1:
.endm			; }}}
.macro ONECHAR					// {{{ Z: address of char data (MSB is fixed, LSB depends on char), X: current VRAM position (one line)
	ld    ZL, X+				// 2CP ZL = (X), X = X + 1
	lpm   Ltmp1, Z				// 3CP get font byte from program memory for current chr on current line
	out   XCAT(PORT,VGA_DATA_PORT), Ltmp1	// 1CP put data to shift register's parallel input
	
	out   XCAT(PIN,VGA_LATCH_PORT), pinflip	// 1CP flip B7 LOW
	out   XCAT(PIN,VGA_LATCH_PORT), pinflip	// 1CP flip B7 HIGH
 .endm						// }}}
func horizontal_line_handler	; {{{
				; all registers are saved and initialised in vertical_start_handler
;	sbi	DDRD,0			; Debug - SCL Led blik
;	sbi	PIND,0			; Debug - SCL Led blik
	lds	temp_4,	TCNT1L	; {{{ synchronise
	lds	temp_5,	TCNT1H
	clr	Ltmp1
	subi	temp_4,	lo8(TIMER1_COMPA_start+HANDLER_OFFSET)	; should result in 0..3 depending on interrupted instruction
	sbci	temp_5,	hi8(TIMER1_COMPA_start+HANDLER_OFFSET)
	
	; pokud byl borrow → přičti 1040
	; vytvoříme masku 0xFFFF nebo 0x0000 podle C flagu
	
	sbc	Ltmp1,	Ltmp1      ; Ltmp1 = 0xFF pokud byl borrow, jinak 0x00
	
	ldi  temp_2, lo8(1040)	; 1040 = period
	ldi  temp_3, hi8(1040)
	
	and  temp_2, r18
	and  temp_3, r18
	
	add  temp_4, temp_2
	adc  temp_5, temp_3

	mov	jitter_act,	temp_4
	cpse	temp_5,	r1
	rjmp	horizontal_line_handler_end
	cpi temp_4, TOO_LONG
	brlo	1f
	sbi	DDRD,0			; Debug - SCL Led blik
	sbi	PIND,0			; Debug - SCL Led blik
	rjmp	horizontal_line_handler_end
1:
;	}}}
;	mov	jitter_act,	temp_4
;	check 4
;	check 3
;	check 2
	check 1
	
	out RAMPZ, subline_ptrHL
	mov ZH, subline_ptrH
; ONECHAR expanded
	ld    ZL, X+				// 2CP ZL = (X), X = X + 1
	lpm   Ltmp1, Z				// 3CP get font byte from program memory for current chr on current line
	out   XCAT(PORT,VGA_DATA_PORT), Ltmp1	// 1CP put data to shift register's parallel input
	
	out   XCAT(PIN,VGA_LATCH_PORT), pinflip	// 1CP flip B7 LOW
	out_lo(VGA_ENABLE)			// this doubles first column of pixels, moving it down instead eats this column and left space on first character, which is worse
	out   XCAT(PIN,VGA_LATCH_PORT), pinflip	// 1CP flip B7 HIGH

.rept TextVGA_COLUMNS -1
	ONECHAR
.endr

; VGA_ENABLE hi must be 8 clocks after last ONECHAR
	nop $ nop $ nop $ nop $ nop $ nop 
	out_hi(VGA_ENABLE)

horizontal_line_handler_end:
	cp	jitter_act,	jitter_max
	brlo	1f
	mov	jitter_max,	jitter_act
1:
	cp	jitter_act,	jitter_min
	brsh	1f
	mov	jitter_min,	jitter_act
1:

	dec	subline_cnt
	breq	horizontal_line_handler_new_line
	add	subline_ptrH,	L_one
	adc	subline_ptrHL,	r1
	
	movw	XL,	line_startL
	ret
horizontal_line_handler_new_line:
	ldi	subline_cnt,	TextVGA_SUBLINES
	
	movw	line_startL,	XL
	
	lds subline_ptrH, TextVGA_CharDef+1	; TextVGA_CharDef+0 = 0 by definition
	lds subline_ptrHL, TextVGA_CharDef+2
	
	ld	Ltmp1,	Y+
	sts XCAT(PORT,VGA_COLOR_PORT),Ltmp1
	
	ret
;	}}}
func vertical_start_handler	; {{{
	in	ZL,	RAMPZ
	push	ZL
	PUSHX(0,29)	; Z=r30:31 already saved
	eor r1,r1
	
	; {{{ set constants here
	mov	L_one,	r1
	inc	L_one
; }}}
	; {{{ blik cursor
	
	lds temp_4, TextVGA_cursor_counter
	tst temp_4
	brne 1f
		lds temp_4, TextVGA_cursor_visible
		cpse	temp_4,r1
		ser temp_4
		com temp_4
		sts TextVGA_cursor_visible,temp_4
		lds temp_4, TextVGA_cursor_time
1:
	dec temp_4
	sts TextVGA_cursor_counter, temp_4
; }}}
	; {{{ set variables here
;	lds	ZL,	TextVGA_CRAM
;	lds	ZH,	TextVGA_CRAM+1
;	ld	YL,	Z+	; CRAM_ptr
;	ld	YH,	Z+
	lds	YL,	TextVGA_CRAM	; CRAM_ptr
	lds	YH,	TextVGA_CRAM+1
	
	lds XL, TextVGA_VRAM
	lds XH, TextVGA_VRAM+1
	
	movw	line_startL,	XL
	
	lds subline_ptrH, TextVGA_CharDef+1	; TextVGA_CharDef+0 = 0 by definition
	lds subline_ptrHL, TextVGA_CharDef+2
	ldi	subline_cnt,	TextVGA_SUBLINES
	
	ldi pinflip, 1<<VGA_LATCH_PIN

	lds	temp_4,		jitter+2
	dec	temp_4
	sts	jitter+2,	temp_4
	brne	1f
	sts	jitter+1,	temp_4
	sts	jitter+0,	temp_4
1:
	lds	jitter_min,	jitter+0
	lds	jitter_max,	jitter+1
; }}}
	; {{{ set pins
	set_output_all(VGA_COLOR,sts)	; output COLORs
	set_output_all(VGA_DATA,out)	; prepare for outputting DATA
	set_output(VGA_LATCH)
	out_hi(VGA_LATCH)		; hi=get data, low=clock out

	ld	Ltmp1,	Y+
	sts XCAT(PORT,VGA_COLOR_PORT),Ltmp1
; }}}
	; {{{ set cursor
	lds Ltmp1, TextVGA_cursor_enabled
	tst Ltmp1
	breq 1f
	lds Ltmp1, TextVGA_cursor_visible
	tst Ltmp1
	breq 1f
	lds ZL, TextVGA_cursor_ptr
	lds ZH, TextVGA_cursor_ptr+1
	ld Ltmp1, Z
	sts TextVGA_cursor_c_temp, Ltmp1
	lds Ltmp1,	TextVGA_cursor_char
	st Z, Ltmp1
1:
; }}}
	; enter loop
	lds	temp_5,	TCNT3L
1:
	lds	temp_4,	TCNT3L
	cp	temp_4,	temp_5
	breq	1b
1:
	lds	temp_4,	TCNT1L
	cpi	temp_4,	lo8(TIMER1_COMPA_start+10)
	brlo	1b
1:
	lds	temp_4,	TCNT1L
	cpi	temp_4,	lo8(TIMER1_COMPA_start+20)
	brsh	1b

	ldi  temp_4, (1<<OCF1A)		; clear pending interrupt
	out  TIFR1, temp_4
	; {{{ enable interrupt TIMER1_COMPA by OCIE1A
	lds	temp_4,	TIMSK1
	ori	temp_4,	(1<<OCIE1A)
	sts	TIMSK1,	temp_4
; }}}
	ldi  temp_4, (1<<OCF1A)		; clear pending interrupt
	out  TIFR1, temp_4
	sei
1:	rjmp 1b
vertical_start_handler_end:
	sts	jitter,		jitter_min
	sts	jitter+1,	jitter_max
	lds XL, TextVGA_VRAM
	lds XH, TextVGA_VRAM+1
	ldi temp_4, 'A'
	add jitter_min, temp_4
	st	X+,	jitter_min
	add jitter_max, temp_4
	st	X+,	jitter_max
	nop		;;;
	lds Ltmp1, TextVGA_cursor_enabled
	tst Ltmp1
	breq 1f
	lds Ltmp1, TextVGA_cursor_visible
	tst Ltmp1
	breq 1f
	lds ZL, TextVGA_cursor_ptr
	lds ZH, TextVGA_cursor_ptr+1
	lds Ltmp1, TextVGA_cursor_c_temp
	st Z, Ltmp1
1:
	
	; disable interrupt TIMER1_COMPA by OCIE1A
	lds	r24,	TIMSK1
	andi	r24,	~ (1<<OCIE1A)
	sts	TIMSK1,	 r24
		lds Zl, TextVGA_VerticalBlank
		lds ZH, TextVGA_VerticalBlank+1
		sbiw ZL,0
		breq 1f
		icall
1:
	POPX(0,29)
	pop	ZL
	out	RAMPZ, ZL
	ret
;	}}}
func vertical_end_handler	; {{{ makes vertical_start_handler leave its loop
				; tricky part - stack hack
	in	ZL,	SPL
	in	ZH,	SPH
	adiw	ZL,	9	;;; maybe stack ret is just 16bit? NO, it is 24bit and AVRemu is wrong !!!
				; stack is reti.addr.ess ZL ZH SREG ret.addr.ess here, need to fix reti part, Z point there
	push	r24
;	ldi	r24,	pm_hh8(vertical_start_handler_end)
;	st	Z+,	r24
;	ldi	r24,	pm_hi8(vertical_start_handler_end)
;	st	Z+,	r24
	ldi	r24,	pm_lo8(vertical_start_handler_end)
	st	Z+,	r24
	pop	r24
	ret
;	}}}
gfunc TextVGA_begin	; {{{
	in	r0,	SREG
	push	r0
	cli
; === handlers	{{{


.macro	handler	name,	asm_function	; {{{ name=lo8/hi8((gs(asm_function)) via r24:r25
	ldi	r24,	lo8(gs(\asm_function))
	ldi	r25,	hi8(gs(\asm_function))
	sts	\name,		r24
	sts	\name+1,	r25
.endm				; }}}
	handler TIMER1_COMPA_vect_handler,	horizontal_line_handler
	handler TIMER3_COMPA_vect_handler,	vertical_start_handler
	handler TIMER3_COMPC_vect_handler,	vertical_end_handler

; }}}
; === pins {{{
	set_output(VGA_LATCH)		; 
	out_hi(VGA_LATCH)		; hi=get data, low=clock out
	set_output(VGA_ENABLE)		; 
	out_hi(VGA_ENABLE)		; hi=disabled, no output
	set_output(VGA_VSYNC)
	set_output(VGA_HSYNC)
	set_output_all(VGA_DATA,out)
	set_output_all(VGA_COLOR,sts)
; }}}
; === variables {{{
	ldi r24, lo8(VRAM)
	ldi r25, hi8(VRAM)
	sts TextVGA_cursor_ptr, r24
	sts TextVGA_cursor_ptr+1, r25
	sts TextVGA_cursor_counter, r1
	ldi r24,DEFAULT_CURSOR_SPEED
	sts TextVGA_cursor_time, r24
	ldi r24, DEFAULT_CURSOR_CHAR
	sts TextVGA_cursor_char, r24
	ldi r24, 0xFF
	sts TextVGA_cursor_enabled, r24
	sts TextVGA_cursor_visible, r24
; }}}
; === timers {{{
	cli
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


; }}}
; {{{ Timer1: VGA HSYNC

	// *****************************
	// ***** Timer1: VGA HSYNC *****
	// *****************************
	//           PB[6] D12          
		; write H, then L, read L, then H - pg.135
		; TCNT1=0;
	sts TCNT1H,r1
	sts TCNT1L,r1

//	// Mode: set timer to Fast PWM with TOP = ICR1

/* ===================== TIMER1 ===================== */
/*
PB6 (OC1B)
perioda: 512 ticku → ICR1 = 511
LOW: 61 ticku → OCR1B = 61
interrupt: TIMER1_COMPA_start → OCR1A = TIMER1_COMPA_start
*/
	; PB6 jako výstup
	sbi DDRB, PB6
	
	; Fast PWM, TOP = ICR1
	; TCCR1A = COM1B1 | COM1B0 | WGM11	;  // COM1B = 0b11, WGM11=1
	ldi r24, (1 << COM1B1) | (1 << COM1B0) | (1 << WGM11)
	sts TCCR1A, r24
	
	; TCCR1B = WGM13 | WGM12 | CS10
	ldi r24, (1<<WGM13) | (1<<WGM12) | (1<<CS10)	; // WGM13:2 = 1110 => Fast PWM ICR1 top, prescaler 1
	sts TCCR1B, r24
	; TCCR1C ignored in PWM
	
	; ICR1 = 511 ;     // perioda = 512 ticks (32 µs)
	ldi r24, lo8(511)
	ldi r25, hi8(511)
	sts ICR1H, r25
	sts ICR1L, r24
	
	; OCR1B = 60 ; // 61 ticků LOW ≈ 3.8 µs
	ldi r24, 60
	sts OCR1BH, r1
	sts OCR1BL, r24
	
; === interrupts
	
	; OCR1A = TIMER1_COMPA_start
	ldi r24, lo8(TIMER1_COMPA_start)
	ldi r25, hi8(TIMER1_COMPA_start)
	sts OCR1AH, r25
	sts OCR1AL, r24
	
;	; enable inside TIMER3_COMPA_vect_handler
;	; enable interrupt OCIE1A
;	ldi r24, (1<<OCIE1A)
;	sts TIMSK1, r24

; }}} 	Timer1: VGA HSYNC end
; {{{	Timer3: VGA VSYNC
	// *****************************
	// ***** Timer3: VGA VSYNC *****
	// *****************************
	//            PE[4] D2          

		; write H, then L, read L, then H - pg.135
		; TCNT3=0;
	sts TCNT3H,r1
	sts TCNT3L,r1
	
//	// Mode: Fast PWM, TOP=ICR3, Set on Compare, Clear on Bottom

/* ===================== TIMER3 ===================== */
/*
PE4 (OC3B)
prescaler 256 → tick = 16us

perioda: 1040 ticku → ICR3 = 1039
LOW: 4 ticky → OCR3B = 3

interrupty:
tick 5 → OCR3A
tick 13 → OCR3C
*/
	
	; PE4 jako výstup
	sbi DDRE, PE4
	
	; TCCR3A = COM3B1 | COM3B0 | WGM31
	ldi r24, (1<<COM3B1) | (1<<COM3B0) |(1<<WGM31)
	sts TCCR3A, r24
	
	; prescaler 256
	ldi r24, (1<<WGM33) | (1<<WGM32) | (1<<CS32)
	sts TCCR3B, r24
	
	; ICR3 = 1039 (1040 ticků = přesný čas)
	ldi r24, lo8(1039)
	ldi r25, hi8(1039)
	sts ICR3H, r25
	sts ICR3L, r24
	
	; OCR3B = 4 (64 µs)
	ldi r24, lo8(4)
	ldi r25, hi8(4)
	sts OCR3BH, r25
	sts OCR3BL, r24
	
	; OCR3A = TIMER3_COMPA_start
	ldi r24, lo8(TIMER3_COMPA_start)
	ldi r25, hi8(TIMER3_COMPA_start)
	sts OCR3AH, r25
	sts OCR3AL, r24
	
	; OCR3C = TIMER3_COMPC_start
	ldi r24, lo8(TIMER3_COMPC_start)
	ldi r25, hi8(TIMER3_COMPC_start)
	sts OCR3CH, r25
	sts OCR3CL, r24
	
	; enable interrupts
	ldi r24, (1<<OCIE3A) | (1<<OCIE3C)
	sts TIMSK3, r24

; }}}	Timer3: VGA VSYNC ends

	ldi	r24,	0xFF
	sts	jitter,	r24
	ldi	r24,	0
	sts	jitter+1,	r24
	; GTCCR = 0;	// clear TSM => all timers start synchronously
	out	GTCCR,	r1
	pop	r0
	out	SREG,	r0
	ret
; }}}

; // Call TextVGA_end() to stop displaying VideoRam (and then maybe activate other driver similar way)

TextVGA_end:		; {{{ disable interrupts and timers output
.type TextVGA_end, @function

	; no interrupt on Timer1
		; TIMSK1 = 0; 
	sts TIMSK1, r1
	
	; no output pin for OCR1B
	sts TCCR1A, r1

	; no interrupt on Timer3
		; TIMSK3 = 0; 
	sts TIMSK3, r1
	
	; no output pin for OCR3B
	sts TCCR3A, r1

	handler TIMER1_COMPA_vect_handler,	EMPTY_HANDLER
	handler TIMER3_COMPA_vect_handler,	EMPTY_HANDLER
	handler TIMER3_COMPC_vect_handler,	EMPTY_HANDLER
	ret
; }}}



#include "FORTH-Defines.h"
gfunc TextVGA_HEADLESS	; {{{ time saving, no display
	Ldi3	Zx,  		DebugLEDs_values + 5*3
	Ldi3	Parsx,	0x0000FF
	call	W3at
	call	DebugLEDs_show

	lds r24,TIMSK3
	andi r24, ~((1<<OCIE3A) | (1<<OCIE3C))
	sts TIMSK3, r24
	ret
; }}}
gfunc TextVGA_HEADMORE	; {{{ full display
	Ldi3	Zx,		DebugLEDs_values + 5*3
	Ldi3	Parsx,	0x00FF00
	call	W3at
	call	DebugLEDs_show

1:
	lds	temp_4,	TCNT3L	; {{{ wait for overflow
	lds	temp_5,	TCNT3H
	tst	temp_5
	brne	1b
	cpi	temp_4, 10
	brsh	1b		; }}}
	in	r0,	SREG
	push	r0
	cli
	lds r24,TIMSK3
	ori r24, (1<<OCIE3A) | (1<<OCIE3C)
	sts TIMSK3, r24
	ldi  temp_4, (1<<OCF3A) | (1<<OCF3C)		; clear pending interrupt
	out  TIFR3, temp_4
	pop	r0
	out	SREG,	r0
	ret
; }}}

#undef	HANDLER_OFFSET
#undef	TOO_LONG
