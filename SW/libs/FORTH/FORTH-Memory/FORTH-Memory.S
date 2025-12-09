#include <avr/io.h>
#include "../FORTH-Defines/FORTH-Defines.h"
#include "../FORTH-Macros/FORTH-Macros.h"

.section .text.FORTH.main.libs
.global B1at, B3at, W1at, W3at, Memory_failed
Memory_failed:
	seT
	ret

B3at:	; Parsx = [Zx+++] 
	; in: Zx, out: r22,r23,r24 (as 3 bytes at Zx), Zx += 3 
	; check for 80+40=80 for RAM:
	mov r21, Z_hlo
	andi r21, 0x80+0x40
	cpi r21, 0x80
	breq B3at.RAM
	cpi r21, 0x40
	breq B3at.store
	rjmp Memory_failed	; fail, no address at all
B3at.RAM:
	ld r22, Z+
	ld r23, Z+
	ld r24, Z+
	tst ZH
	brne B3at.RAM.ok
	cpi ZL,4
	brlo Memory_failed
				; fall thru
B3at.RAM.ok:
	clT
	ret
B3at.store:
	mov r21, Z_hlo
	andi r21, 0x46
	cpi r21, 0x40
	breq B3at.40	; normal FLASH
	cpi r21, 0x44
	breq B3at.44	; Shared RAM
;	cmp r21, 0x42
;	breq B3at_42	; Extended RAM out of mapped range
B3at.42:
	rjmp Memory_failed	; not now

B3at.40:
	out _SFR_IO_ADDR(RAMPZ), Z_hlo	; only &0x03 is used
	elpm r22, Z+
	elpm r23, Z+
	elpm r24, Z+
	in Z_hlo, _SFR_IO_ADDR(RAMPZ)
	ori Z_hlo, 0x40
	clT
	ret
B3at.44:
	rjmp Memory_failed	; now we cannot use Shared memory
	; }}}
