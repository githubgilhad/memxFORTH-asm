#include <avr/io.h>
#include "../FORTH-Defines/FORTH-Defines.h"
#include "../FORTH-Macros/FORTH-Macros.h"

.section .text.FORTH.main.libs
.global B1at, B3at, W1at, W3at, Memory_failed

B1at:	; Parsx = [Zx+++] 
	; in: Zx, out: Parsx=r22,r23,r24 (as 1 byte at Zx), Zx += 1
	; check for 80+40=80 for RAM:
	mov r21, Z_hlo
	andi r21, 0x80+0x40
	cpi r21, 0x80
	breq B1at.RAM
	cpi r21, 0x40
	breq B1at.store
	rjmp Memory_failed	; fail, no address at all
B1at.RAM:
	ld Parsx_lo, Z+
	clr Parsx_hi
	clr Parsx_hlo
	tst ZH
	brne B1at.RAM.ok
	cpi ZL,1
	brlo Memory_failed
				; fall thru
B1at.RAM.ok:
	clT
	ret
B1at.store:
	mov r21, Z_hlo
	andi r21, 0x46
	cpi r21, 0x40
	breq B1at.40	; normal FLASH
	cpi r21, 0x44
	breq B1at.44	; Shared RAM
;	cmp r21, 0x42
;	breq B1at_42	; Extended RAM out of mapped range
B1at.42:
	rjmp Memory_failed	; not now

B1at.40:
	out _SFR_IO_ADDR(RAMPZ), Z_hlo	; only &0x03 is used
	elpm Parsx_lo, Z+
	clr Parsx_hi
	clr Parsx_hlo
	in Z_hlo, _SFR_IO_ADDR(RAMPZ)
	ori Z_hlo, 0x40
	clT
	ret
B1at.44:
	rjmp Memory_failed	; now we cannot use Shared memory
	; }}}


B3at:	; Parsx = [Zx+++] 
	; in: Zx, out: Parsx=r22,r23,r24 (as 3 bytes at Zx), Zx += 3
	; check for 80+40=80 for RAM:
	mov r21, Z_hlo
	andi r21, 0x80+0x40
	cpi r21, 0x80
	breq B3at.RAM
	cpi r21, 0x40
	breq B3at.store
	rjmp Memory_failed	; fail, no address at all
B3at.RAM:
	ld Parsx_lo, Z+
	ld Parsx_hi, Z+
	ld Parsx_hlo, Z+
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
	elpm Parsx_lo, Z+
	elpm Parsx_hi, Z+
	elpm Parsx_hlo, Z+
	in Z_hlo, _SFR_IO_ADDR(RAMPZ)
	ori Z_hlo, 0x40
	clT
	ret
B3at.44:
	rjmp Memory_failed	; now we cannot use Shared memory
	; }}}

Memory_failed:
	seT
	ret

W1at:	; [Zx++] = Parsx_lo (1 byte)
	; in: Zx, Parsx_lo=r22, out: Zx += 1
	; check for RAM (0x80) vs FLASH/other
	mov r21, Z_hlo
	andi r21, 0x80
	cpi r21, 0x80
	breq W1at.RAM
	rjmp Memory_failed	; FLASH is read-only, fail
W1at.RAM:
	st Z+, Parsx_lo
	tst ZH
	brne W1at.RAM.ok
	cpi ZL, 1
	brlo Memory_failed
W1at.RAM.ok:
	clT
	ret

W3at:	; [Zx+++] = Parsx (3 bytes)
	; in: Zx, Parsx=r22,r23,r24, out: Zx += 3
	; check for RAM (0x80) vs FLASH/other
	mov r21, Z_hlo
	andi r21, 0x80
	cpi r21, 0x80
	breq W3at.RAM
	rjmp Memory_failed	; FLASH is read-only, fail
W3at.RAM:
	st Z+, Parsx_lo
	st Z+, Parsx_hi
	st Z+, Parsx_hlo
	tst ZH
	brne W3at.RAM.ok
	cpi ZL, 4
	brlo Memory_failed
W3at.RAM.ok:
	clT
	ret
