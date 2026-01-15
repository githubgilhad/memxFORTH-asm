; vim: filetype=asm noexpandtab fileencoding=utf-8 nomodified nowrap textwidth=270 foldmethod=marker foldmarker={{{,}}} foldcolumn=4 ruler showcmd lcs=tab\:|- list: 

#pragma once

#define USE_LINE_16

; ////////////////////////////////////////////////////////////////////////////////

;	Z + r25 is temp, usualy for memory access
#define 	Z_hlo r25
#define 	Zx ZL, ZH, Z_hlo

;	Parsx for functions
#define 	Parsx_lo r22
#define 	Parsx_hi r23
#define 	Parsx_hlo r24
#define 	Parsx Parsx_lo, Parsx_hi, Parsx_hlo

;	Y + r2 are calee protected - will not change over calls
#define 	IP_lo	r8	
#define 	IP_hi	r9	
#define 	IP_hlo	r10	
#define 	IP	IP_lo, IP_hi, IP_hlo

;	C calls destroy X, but it is restored in NEXT and needed in DOCOL just after the NEXT
;	X + r0 - temporary, cannot use Z, as we need it for EIJMP in NEXT
#define 	DT_lo	XL	
				; r26
#define 	DT_hi	XH	
				; r27
#define 	DT_hlo	r7
#define 	DT	DT_lo, DT_hi, DT_hlo

;	Top Of the Stack is 24bit (calee protected)
#define 	TOS_lo	r4
#define 	TOS_hi	r5
#define 	TOS_hlo	r6
#define 	TOS	TOS_lo, TOS_hi, TOS_hlo

;	Stack is in RAM 0 (calee protected)
#define 	ST_lo	YL
				; r28
#define 	ST_hi	YH
				; r29
#define 	ST_hlo	r1
				; ST_hlo is zero
#define 	ST	ST_lo, ST_hi
#define 	ST3	ST_lo, ST_hi, ST_hlo

;	Return Stack is in RAM 0 (calee protected)
#define 	RS_lo	r2
#define 	RS_hi	r3
#define 	RS_hlo	r1
				; RS_hlo is zero
#define 	RS	RS_lo, RS_hi
#define 	RS3	RS_lo, RS_hi, RS_hlo

.macro LINE_16 reg
#ifdef USE_LINE_16
;	LINE_16 - if used, set LINE_16 (XAA16) to bit 0 of given register to bank extended RAM
	cbi _SFR_IO_ADDR(PORTG),3
	sbrc \reg,0
	sbi _SFR_IO_ADDR(PORTG),3
#endif
.endm

