#include <avr/io.h>
#include "../../../libs/FORTH/FORTH-Defines/FORTH-Defines.h"
#include "../../../libs/FORTH/FORTH-Macros/FORTH-Macros.h"
#include "../../../libs/FORTH/FORTH-Memory/FORTH-Memory.h"
;	#include "../../../libs/FORTH/FORTH-Engine/FORTH-Engine.h"
.macro TCB_2_Z member	; {{{
	movw r30, r24   ; Z = user*
	ldi Tx, lo8(\member)
	add ZL, Tx
	ldi Tx, hi8(\member)
	adc ZH, Tx
.endm	; }}}
#include "TCB_offsets.inc"

C2FORTH:	; {{{ C2FORTH(User *data, void (*fn)(void));
.global C2FORTH
.type   C2FORTH, @function
	; r25:r24 = User *
	; r23:r22 = void (*fn)(void)
	; store C registers
	push r2
	push r3
	push r4
	push r5
	push r6
	push r7
	push r8
	push r9
	push r10
	push r11
	push r12
	push r13
	push r14
	push r15
	push r16
	push r17
	push r28
	push r29
	
	; r24:r25 = user*
	push r24
	push r25
	
	; read user data
	TCB_2_Z TCB_IP
	Ld3Z IP
	TCB_2_Z TCB_DST
	Ld2Z DST
	TCB_2_Z TCB_RST
	Ld2Z RST
	TCB_2_Z TCB_TOS
	Ld3Z TOS
	TCB_2_Z TCB_DT
	Ld3Z DT
	TCB_2_Z TCB_TCB_cur
	Ld2Z TCB
	
	movw r30, r22	; Z = *fn; r24:r25 = user*
	icall
	
	pop r25
	pop r24
	; write  user data
	
	TCB_2_Z TCB_IP
	St3Z IP
	TCB_2_Z TCB_DST
	St2Z DST
	TCB_2_Z TCB_RST
	St2Z RST
	TCB_2_Z TCB_TOS
	St3Z TOS
	TCB_2_Z TCB_DT
	St3Z DT
	
	pop r29
	pop r28
	pop r17
	pop r16
	pop r15
	pop r14
	pop r13
	pop r12
	pop r11
	pop r10
	pop r9
	pop r8
	pop r7
	pop r6
	pop r5
	pop r4
	pop r3
	pop r2
	
	clr r1
	ret
	; }}}

run_in_FORTH_xt_in_IP:	; {{{ run_in_FORTH_xt_in_IP(User *data); run xt stored in IP and returns
.global run_in_FORTH_xt_in_IP
.type   run_in_FORTH_xt_in_IP, @function
	
	Set3 Zx, IP
	Ldi3i IP, return_home	; DT=*IP; IP = return_home ~ next word ptr
	call B3at
	Set3 DT, Zx		; Parsx=*DT; DT+=3
	Set3 Zx, Parsx
	Div2 Zx
	out _SFR_IO_ADDR(EIND), Z_hlo
	eicall			; call, so we return *Parsx (it is FORTH function with NEXT)
	ret
	; }}}
f_return_home:
	ret	; here we return to calling function, no NEXT
.section .FORTH_data ,"a",@progbits
return_home:
	.global return_home
	.type return_home, @object
	P24 return_home2
return_home2:
	.global return_home2
	.type return_home2, @object
	P24 f_return_home
