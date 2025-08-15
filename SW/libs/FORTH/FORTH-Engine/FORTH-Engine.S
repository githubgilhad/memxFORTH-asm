#include <avr/io.h>
#include "../FORTH-Defines/FORTH-Defines.h"
; r2+Y = IP


; === EXIT returns from word (fall thru NEXT)
.global EXIT
EXIT:		// IP=popR();NEXT	{{{
	movw ZL, RS_lo
	ld IP_lo,Z+
	ld IP_hi,Z+
	ld IP_hlo,Z+
	movw RS_lo,ZL
;	jmp NEXT
; === fall thru NEXT === 		}}}

; === NEXT uses EIJMP to move
; use: X,Y,Z r0,r2, r23,r24,r25
; in:  IP=r2+Y
; out: IP=r2+Y, DT=r0+X, eijmp(Z) 
.global NEXT
NEXT: // DT=*IP++; jmp **DT++		{{{
	
	//  DT=*IP++
	sbrc IP_hlo,7	; skip if 0x80 not set (=FLASH)
	rjmp 1f
	out _SFR_IO_ADDR(RAMPZ), IP_hlo
	movw ZL,   IP_lo
	elpm DT_lo,  Z+
	elpm DT_hi,  Z+
	elpm DT_hlo, Z+
	movw IP_lo, XL
	in IP_hlo, _SFR_IO_ADDR(RAMPZ)
	rjmp 2f
1:
	XAA16_0x8x(IP_hlo)
	ld DT_lo,  Y+
	ld DT_hi,  Y+
	ld DT_hlo, Y+	; IP is Y, x80 -> x81 is not supported
	
	// jmp **DT++
2:
	movw ZL, DT_lo
	sbrc DT_hlo,7
	rjmp 1f
	out _SFR_IO_ADDR(RAMPZ), DT_hlo
	elpm r24,    Z+
	elpm r25,    Z+
	elpm r23,    Z+ 	// hlo
	movw DT_lo, ZL
	in DT_hlo, _SFR_IO_ADDR(RAMPZ)
	movw ZL,     r24
	out _SFR_IO_ADDR(EIND),    r23
	eijmp
1:
	XAA16_0x8x(DT_hlo)
	ldd r24,     Z+
	ldd r25,     Z+
	ldd r23,     Z+	// hlo
	movw DT_lo, ZL
	in DT_hlo, _SFR_IO_ADDR(RAMPZ)
	movw ZL,     r24
	out _SFR_IO_ADDR(EIND),    r23
	eijmp
; === ====				}}}

; === DOCOL enter composed word
.global DOCOL
DOCOL:		// pushR(IP);IP=DT;NEXT	{{{
	// pushR(IP)
	movw ZL,  RS_lo
	st -Z,   IP_hlo
	st -Z,   IP_hi
	st -Z,   IP_lo
	movw RS_lo,ZL
	
	// IP=DT
	movw IP_lo, DT_lo
	mov IP_hlo, DT_hlo
	
	// NEXT
	jmp NEXT
; === fall thru NEXT === 		}}}

