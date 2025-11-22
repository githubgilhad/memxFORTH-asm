; vim: filetype=asm noexpandtab fileencoding=utf-8 nomodified nowrap textwidth=270 foldmethod=marker foldmarker={{{,}}} foldcolumn=4 ruler showcmd lcs=tab\:|- list: 

#pragma once

#define USE_LINE_16

; ////////////////////////////////////////////////////////////////////////////////

;	Y + r2 are calee protected - will not change over calls
#define 	IP_lo	YL	
				; r28
#define 	IP_hi	YH	
				; r29
#define 	IP_hlo	r2
#define 	IP	IP_lo, IP_hi, IP_hlo

;	C calls destroy X, but it is restored in NEXT and needed in DOCOL just after the NEXT
;	X + r0 - temporary, cannot use Z, as we need it for EIJMP in NEXT
#define 	DT_lo	XL	
				; r30
#define 	DT_hi	XH	
				; r31
#define 	DT_hlo	r0
#define 	DT	DT_lo, DT_hi, DT_hlo

;	Top Of the Stack is 24bit (calee protected)
#define 	TOS_lo	r3
#define 	TOS_hi	r4
#define 	TOS_hlo	r5
#define 	TOS	TOS_lo, TOS_hi, TOS_hlo

;	Stack is in RAM 0 (calee protected)
#define 	ST_lo	r6
#define 	ST_hi	r7
;	#define 	ST_hlo	0	// immediate
#define 	ST	ST_lo, ST_hi

;	Return Stack is in RAM 0 (calee protected)
#define 	RS_lo	r8
#define 	RS_hi	r9
;	#define 	RS_hlo	0	// immediate
#define 	RS	RS_lo, RS_hi

.macro LINE_16 reg
#ifdef USE_LINE_16
;	LINE_16 - if used, set LINE_16 (XAA16) to bit 0 of given register to bank extended RAM
	cbi _SFR_IO_ADDR(PORTG),3
	sbrc \reg,0
	sbi _SFR_IO_ADDR(PORTG),3
#endif
.endm

