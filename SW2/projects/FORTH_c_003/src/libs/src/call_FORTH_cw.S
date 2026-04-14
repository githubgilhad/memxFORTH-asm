; .. vim: ft=asm showbreak=--»\  noexpandtab fileencoding=utf-8 nomodified   wrap textwidth=0 foldmethod=marker foldmarker={{{,}}} foldcolumn=4 ruler showcmd lcs=tab\:|- list tabstop=8 noexpandtab nosmarttab softtabstop=0 shiftwidth=0 linebreak  tags=./tags;,tags; 

#include <avr/io.h>
#include "FORTH-Defines.h"
#include "FORTH-Macros.h"
#include "FORTH-Memory.h"
;	#include "FORTH-Engine.h"
gfunc call_FORTH_cw	; {{{ in: Zx, out: C-regs mangled
	Push3_x	IP
	Ldi3i IP, return_home	; DT=*IP; IP = return_home ~ next word ptr
	call B3at
	Set3 DT, Zx		; Parsx=*DT; DT+=3
	Set3 Zx, Parsx
	Div2 Zx
	out _SFR_IO_ADDR(EIND), Z_hlo
	eicall			; call, so we return *Parsx (it is FORTH function with NEXT)

	Pop3_x	IP
	ret




; }}}
