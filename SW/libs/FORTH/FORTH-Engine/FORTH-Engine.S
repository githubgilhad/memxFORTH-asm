#include "../FORTH-Defines/FORTH-Defines.h"
; r2+Y = IP


; === NEXT uses EIJMP to move
; use: X,Y,Z r0,r2, r23,r24,r25
; in:  IP=r2+Y
; out: IP=r2+Y, DT=r0+X, eijmp(Z) 
.global NEXT
NEXT:
	// DT=*IP; IP++; jmp **DT
	sbrc IP_hlo,7	; skip if 0x80 not set (=FLASH)
	rjmp 1f
	out RAMPZ, IP_hlo
	movw ZL,   IP_lo
	elpm DT_lo,  Z+
	elpm DT_hi,  Z+
	elpm DT_hlo, Z+
	adiw IP_lo,  3
	rjmp 2f
1:
	ldd DT_lo,  Y+
	ldd DT_hi,  Y+
	ldd DT_hlo, Y+
2:
	movw ZL, DT_lo
	sbrc DT_hlo,7
	rjmp 1f
	out RAMPZ, DT_hlo
	elpm r24,    Z+
	elpm r25,    Z+
	elpm r23,    Z+ 	// hlo
	movw ZL,     r24
	out EIND,    r23
	eijmp
1:
	ldd r24,     Z+0
	ldd r25,     Z+1
	ldd r23,     Z+2	// hlo
	movw ZL,     r24
	out EIND,    r23
	eijmp
; === ====

; === EXIT returns from word
.global EXIT
EXIT:
