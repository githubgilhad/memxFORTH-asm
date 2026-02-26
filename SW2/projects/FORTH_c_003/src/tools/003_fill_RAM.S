#include <avr/io.h>
;	.init0 first part on boot, no stack
;	.init1 
;	.init2 SP defined
;	.init3 <======================== HERE we are
;	.init4 fill .data from FLASH
;	.init5 fill .bss with 0
;	.init6
;	.init7
;	.init8
;	.init9 call main
.section .init3
.global fill_ram_pattern
fill_ram_pattern:
	ldi r30, lo8(__heap_start)
	ldi r31, hi8(__heap_start)
	
	ldi r26, lo8(__stack)
	ldi r27, hi8(__stack)
	
	ldi r24, 0xA5
	
1:
	cp  r30, r26
	cpc r31, r27
	brsh 2f
	
	st  Z+, r24
	rjmp 1b
2:

;	MCRA = (1<<SRE);     // Enable External Memory Interface
;	XMCRB = 0x00;         // Bez maskování horní části adresního prostoru

	sbi _SFR_IO_ADDR(DDRG),  3
	sbi _SFR_IO_ADDR(PORTG), 3		; XAA16 on
	ldi r24, 1<<SRE
	sts XMCRA, r24		; set bit SRE
	clr r24
	sts XMCRB, r24		; clear XMCRB

fill_high_ram_pattern:
	ldi r30, lo8(0x2200)
	ldi r31, hi8(0x2200)
	
	clr r26
	
	ldi r24, 'H'
	
1:
	cp  r30, r26
	cpc r31, r26
	breq 2f		; overflow from 64kB to 0x0000
	
	st  Z+, r24
	rjmp 1b
2:
