#include <avr/io.h>
#include "../FORTH-Defines/FORTH-Defines.h"
#include "../FORTH-Macros/FORTH-Macros.h"
#include "../FORTH-Memory/FORTH-Memory.h"
; r2+Y = IP
; .section .rodata.FORTH
; .db <prev,len,"name",docol,data> ....
; {{{ sections
.section .text.LIBS.zz_end
.global LIBS_END
LIBS_END: nop
.section .text.LIBS.aa_start
.global LIBS_START
LIBS_START: nop
.section .text.FORTH.zz_end
.global FORTH_END
FORTH_END: nop
.section .text.FORTH.aa_start
.global FORTH_START
FORTH_START: nop
; }}}
.section .bss.FORTH
gobj FORTH_IRQ
	.byte 0		; bit.0 = IRQ, rest ignored
gobj FORTH_IRQ_addr
	.byte 0,0,0	; xt of handler
#ifdef DoNEXTcounter
gobj NEXTcounter
	.byte 0,0,0, 0,0,0, 0	; 4us, 1ms, 262ms,   1m, 4:46h, 50d, 35.5 year (overflow if increased on 16 Mhz, more realistic are times ~ 50 longer)
#endif
.section .text.FORTH.main
.balign 2
; === DOCOL enter composed word
gfunc DOCOL	; pushR(IP);IP=DT;NEXT	{{{
	PushR IP
	Set3 IP, DT
	rjmp NEXT
; ===  === 		}}}

; === EXIT returns from word (fall thru NEXT)
gfunc EXIT		;  IP=popR();NEXT	{{{
	PopR IP
;	rjmp NEXT
; === fall thru NEXT === 		}}}

; === NEXT uses EIJMP to move
; use: X,Z r0,r5,r6,r7, r23,r24,r25
; in:  IP=r5,r6,r7
; out: IP=r5,r6,r7, DT=r0+X, eijmp(Z), r1=0

gfunc NEXT // DT=*IP++; jmp **DT++		{{{
	clr r1
#ifdef DoNEXTcounter
	ldi ZL, lo8(NEXTcounter)
	ldi ZH, hi8(NEXTcounter)
	sec	; set Carry
1:
	ld r24, Z
	adc r24,r1
	st Z+,r24
	brcs 1b	; branch on Carry Set
#endif
	lds Parsx_hlo, FORTH_IRQ	; Parsx_hlo = scratch
	sbrc Parsx_hlo,0
	rjmp NEXT.IRQ		; if FORTH_IRQ jmp NEXT.IRQ
	Set3 Zx, IP
	call B3at
	Set3 IP, Zx		; DT=*IP; IP +=3
	Set3 Zx, Parsx
	call B3at
	Set3 DT, Zx		; Parsx=*DT; DT+=3
; call Tracer
	Set3 Zx, Parsx
	Div2 Zx
	out _SFR_IO_ADDR(EIND), Z_hlo
NEXT.eijmp:
	.global NEXT.eijmp
	eijmp			; jmp *Parsx (not call, it is FORTH function with NEXT)
NEXT.IRQ:
	Lds3 Zx, FORTH_IRQ_addr
	call B3at
	Set3 DT, Zx
	Set3 Zx, Parsx
	out _SFR_IO_ADDR(EIND), Z_hlo
	eijmp
; === ====				}}}

; //////////////////////////////////////////
; {{{ some old junk to decode ram/rom/other banks
	//  DT=*IP++
	sbrc IP_hlo,7	; skip if 0x80 not set (=FLASH)
	rjmp 1f
	out _SFR_IO_ADDR(RAMPZ), IP_hlo	; select FLASH bank
	movw ZL,   IP_lo		; Read DT from current IP, inc IP
	elpm DT_lo,  Z+
	elpm DT_hi,  Z+
	elpm DT_hlo, Z+
	movw IP_lo, ZL			; save IP as incrementing was done corectly in HW for rampZ:Zh:Zl
	in IP_hlo, _SFR_IO_ADDR(RAMPZ)
	rjmp 2f

1:
	LINE_16 IP_hlo		; if using RAM banks, select RAM bank (ignored by non-baked basic RAM)
	ld DT_lo,  Y+
	ld DT_hi,  Y+
	ld DT_hlo, Y+	; IP is Y, x80 -> x81 (overrun to next bank) is not supported/checked
	
	// jmp **DT++ - same tricks as above
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
	; prepare jump
	movw ZL,     r24
	out _SFR_IO_ADDR(EIND),    r23
	eijmp
1:
	LINE_16 DT_hlo
	ldd r24,     Z+
	ldd r25,     Z+
	ldd r23,     Z+	// hlo
	movw DT_lo, ZL
	in DT_hlo, _SFR_IO_ADDR(RAMPZ)
	; prepare jump
	movw ZL,     r24
	out _SFR_IO_ADDR(EIND),    r23
	eijmp
; === ====				}}}


