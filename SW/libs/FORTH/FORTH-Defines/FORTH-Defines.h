#ifndef FORTH_DEFINES_H
#define FORTH_DEFINES_H

#define USE_XAA16_0x8x

//	Y + r2 are calee protected - will not change over calls
#define 	IP_lo	YL	// r28
#define 	IP_hi	YH	// r29
#define 	IP_hlo	r2

//	X + r0 - temporary, cannot use Z, as we need it for EIJMP in NEXT
#define 	DT_lo	XL	// r30
#define 	DT_hi	XH	// r31
#define 	DT_hlo	r0

//	Top Of the Stack is 24bit (calee protected)
#define 	TOS_lo	r3
#define 	TOS_hi	r4
#define 	TOS_hlo	r5

//	Stack is in RAM 0 (calee protected)
#define 	ST_lo	r6
#define 	ST_hi	r7
//	#define 	ST_hlo	0	// immediate

//	Return Stack is in RAM 0 (calee protected)
#define 	RS_lo	r8
#define 	RS_hi	r9
//	#define 	RS_hlo	0	// immediate

#ifdef USE_XAA16_0x8x
//	XAA16_0x8x - if used, set XAA16 to bit 0 of given register to bank extended RAM
	#define	XAA16_0x8x(reg) \
		cbi PORTG,3 \
		sbrc \reg,0 \
		sbi PORTG,3
#else
	#define	XAA16_0x8x(reg) 
#endif


#endif
