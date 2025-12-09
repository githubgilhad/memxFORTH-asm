; vim: filetype=asm noexpandtab fileencoding=utf-8 nomodified nowrap textwidth=270 foldmethod=marker foldmarker={{{,}}} foldcolumn=4 ruler showcmd lcs=tab\:|- list: 

#pragma once

; ////////////////////////////////////////////////////////////////////////////////

.macro PushR a_lo, a_hi, a_hlo ; {{{ push "a" to RS, 3B
	movw ZL, RS_lo
	st -Z, \a_hlo
	st -Z, \a_hi
	st -Z, \a_lo
	movw RS_lo,ZL
.endm	
	; }}}
.macro PopR a_lo, a_hi, a_hlo ; {{{ pop "a" from RS, 3B
	movw ZL, RS_lo
	ld \a_lo,  Z+
	ld \a_hi,  Z+
	ld \a_hlo, Z+
	movw RS_lo,ZL
.endm			; }}}
.macro Set3 a_lo, a_hi, a_hlo,  b_lo, b_hi, b_hlo ; {{{  "a" = "b", 3B
	movw \a_lo, \b_lo
	mov \a_hlo, \b_hlo
.endm			; }}}
.macro Lds3 a_lo, a_hi, a_hlo,  address ; {{{  LDS "a", address, 3B
	lds \a_lo, \address
	lds \a_hi, \address+1
	lds \a_hlo, \address+2
.endm			; }}}



