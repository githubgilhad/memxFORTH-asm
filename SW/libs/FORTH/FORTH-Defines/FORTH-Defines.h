; // vim: filetype=asm noexpandtab fileencoding=utf-8 nomodified nowrap textwidth=270 foldmethod=marker foldmarker={{{,}}} foldcolumn=4 ruler showcmd lcs=tab\:|- list: 

#pragma once

#define USE_LINE_16
#define P24_Canary 0xCACAA7

#ifdef __ASSEMBLER__
;//////////////////////////////////////////////////////////////////////////////

#define 	Temp r18
;	Z + r25 is temp, usualy for memory access
#define 	Z_lo ZL
#define 	Z_hi ZH
#define 	Z_hlo r25
#define 	Zx ZL, ZH, Z_hlo
#define 	Zx2 ZL, ZH

;	Parsx for functions
#define 	Parsx_lo r22
#define 	Parsx_hi r23
#define 	Parsx_hlo r24
#define 	Parsx Parsx_lo, Parsx_hi, Parsx_hlo
#define 	Parsx2 Parsx_lo, Parsx_hi

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
#define 	DT2	DT_lo, DT_hi

;	Top Of the Stack is 24bit (calee protected)
#define 	TOS_lo	r4
#define 	TOS_hi	r5
#define 	TOS_hlo	r6
#define 	TOS	TOS_lo, TOS_hi, TOS_hlo
#define 	TOS2	TOS_lo, TOS_hi

;	Stack is in RAM 0 (calee protected)
#define 	DST_lo	YL
				; r28
#define 	DST_hi	YH
				; r29
#define 	DST_hlo	r1
				; DST_hlo is zero
#define 	DST	DST_lo, DST_hi
#define 	DST3	DST_lo, DST_hi, DST_hlo

;	Return Stack is in RAM 0 (calee protected)
#define 	RST_lo	r2
#define 	RST_hi	r3
#define 	RST_hlo	r1
				; RST_hlo is zero
#define 	RST	RST_lo, RST_hi
#define 	RST3	RST_lo, RST_hi, RST_hlo

;	Thread_Conroll_Block is in RAM 0 (calee protected)
#define 	TCB_lo	r12
#define 	TCB_hi	r13
#define 	TCB_hlo	r1
				; TCB_hlo is zero
#define 	TCB	TCB_lo, TCB_hi
#define 	TCB3	TCB_lo, TCB_hi, TCB_hlo

#endif

#define DST_SIZE 30
#define RST_SIZE 30
#define TIB_SIZE 80
#define AIB_SIZE 80
#define ORDER_SIZE 16
