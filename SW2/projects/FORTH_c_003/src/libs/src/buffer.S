; .. vim: ft=asm showbreak=--»\  noexpandtab fileencoding=utf-8 nomodified   wrap textwidth=0 foldmethod=marker foldmarker={{{,}}} foldcolumn=4 ruler showcmd lcs=tab\:|- list tabstop=8 noexpandtab nosmarttab softtabstop=0 shiftwidth=0 linebreak  tags=./tags;,tags; 
#include <avr/io.h>

#include "FORTH-Defines.h"
#include "FORTH-Macros.h"

; 

.section .text.LIBS.main
gfunc BUF_Init_Z	; {{{ initialise/clear buffer
	std	Z + BUF_Count,	r1
	std	Z + BUF_Head,	r1
	std	Z + BUF_Tail,	r1
	ret
; }}}
gfunc BUF_Used_ZP	; {{{ OUT: Parsx_lo = bytes inside buffer
	ldd	Parsx_lo,	Z + BUF_Count
	ret
; }}}
gfunc BUF_Free_ZP	; {{{ OUT: Parsx_lo = bytes free in buffer
	push	Tx
	ldd	Tx,		Z + BUF_Count
	ldd	Parsx_lo,	Z + BUF_Size
	sub	Parsx_lo,	Tx
	pop	Tx
	ret
; }}}
gfunc BUF_Read_ZP	; {{{ IN: Zx2 Buffer; OUT: Zx2 Buffer, Parsx_lo char, Parsx_hi = buffer len BEFORE read (1..RX0_BUFFER_SIZE) or 0 if nothing was read;
	ldd	Parsx_hi,	Z + BUF_Count
	tst	Parsx_hi
	mov	Parsx_lo,	Parsx_hi
	brne	1f
	ret
1:
	push	ZL
	push	ZH
	push	Tx
	;						; protected section
	in	Tx,		_SFR_IO_ADDR(SREG)	;
	cli						;
	ldd	Parsx_lo,	Z + BUF_Count		;
	dec	Parsx_lo				; Counter -1
	std	Z + BUF_Count,	Parsx_lo		;
	out	_SFR_IO_ADDR(SREG),	Tx		; uprotected
	;
	ldd	Tx,		Z + BUF_Size
	ldd	Parsx_lo,	Z + BUF_Tail
	inc	Parsx_lo			; Tail +1
	std	Z + BUF_Tail,	Parsx_lo
	cp	Parsx_lo,	Tx
	brlt	1f
	std	Z + BUF_Tail,	r1
1:
	dec	Parsx_lo
	add	ZL,		Parsx_lo
	adc	ZH,		r1
	ldd	Parsx_lo,	Z + BUF_Data
	pop	Tx
	pop	ZH
	pop	ZL
	ret
; }}}

gfunc BUF_Write_ZP	; {{{ IN: Zx2 Buffer; Parsx_lo char;  OUT: Zx2 Buffer, Parsx_lo char, Parsx_hi = FREE buff BEFORE write (1..RX0_BUFFER_SIZE) or 0 and write FAILED;
	push	Tx
	ldd	Parsx_hi,	Z + BUF_Size
	ldd	Tx,		Z + BUF_Count
	sub	Parsx_hi,	Tx
	brne	1f
	pop	Tx
	ret
1:
	push	ZL
	push	ZH
	push	Parsx_hi	; FREE buff BEFORE write
	;						; protected section
	in	Parsx_hi,	_SFR_IO_ADDR(SREG)	;
	cli						;
	ldd	Tx,		Z + BUF_Count		;
	inc	Tx					; Counter +1
	std	Z + BUF_Count,	Tx			;
	out	_SFR_IO_ADDR(SREG),	Parsx_hi	; uprotected
	;
	pop	Parsx_hi				; FREE buff BEFORE write
	ldd	Tx,		Z + BUF_Head
	add	ZL,		Tx
	adc	ZH,		r1
	std	Z + BUF_Data,	Parsx_lo
	pop	ZH
	pop	ZL
	inc	Tx				; Head +1
	push	Temp_lo
	ldd	Temp_lo,	Z + BUF_Size
	cp	Tx,		Temp_lo
	pop	Temp_lo
	brlt	1f
	clr	Tx
1:
	std	Z + BUF_Head,	Tx
	
	pop	Tx
	ret
; }}}

gfunc BUF_Read_C	; {{{ uint16_t BUF_Read_C(uint8_t *Buff);
	movw ZL, Cpar1_lo
	call BUF_Read_ZP
	movw Cpar1_lo,Parsx_lo
	ret
; }}}
gfunc BUF_Free_C	; {{{ uint8_t BUF_Free_C(uint8_t *Buff);
	movw ZL, Cpar1_lo
	call BUF_Free_ZP
	mov Cpar1_lo,Parsx_lo
	ret
; }}}
gfunc BUF_Used_C	; {{{ uint8_t BUF_Used_C(uint8_t *Buff);
	movw ZL, Cpar1_lo
	call BUF_Used_ZP
	mov Cpar1_lo,Parsx_lo
	ret
; }}}
gfunc BUF_Write_C	; {{{ uint16_t BUF_Write_C(uint8_t *Buff, uint8_t c);
	movw ZL, Cpar1_lo
	mov Parsx_lo, Cpar2_lo
	call BUF_Write_ZP
	movw Cpar1_lo,Parsx_lo
	ret
; }}}
