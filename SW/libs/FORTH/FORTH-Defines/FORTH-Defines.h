#ifndef FORTH_DEFINES_H
#define FORTH_DEFINES_H


//	Y + r2 are calee protected - will not change over calls
#define 	IP_lo	YL	// r28
#define 	IP_hi	YH	// r29
#define 	IP_hlo	r2

//	X + r0 - temporary, cannot use Z, as we need it for EIJMP in NEXT
#define 	DT_lo	XL	// r30
#define 	DT_hi	XH	// r31
#define 	DT_hlo	r0



#endif
