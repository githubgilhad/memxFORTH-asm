#include <avr/io.h>
#include "../../../../../libs/FORTH/FORTH-Defines/FORTH-Defines.h"
#include "../../../../../libs/FORTH/FORTH-Macros/FORTH-Macros.h"
#include "../../../../../libs/FORTH/FORTH-Memory/FORTH-Memory.h"
;	#include "../../../../../libs/FORTH/FORTH-Engine/FORTH-Engine.h"

#include "../../flags.h"
#include "../../TCB_offsets.inc"

; External memory functions
.extern W1at
.extern W3at


; grep global primitives.S |sed "s@.global f_\(.*\)@DEFWORD w_\1,\t\t0,\t\"\1\",\t\tf_\1\t// @">primitives.words.inc


#undef CURRENT_TEXT_SECTION
#undef CURRENT_DATA_SECTION
#define CURRENT_TEXT_SECTION .text.FORTH.words
#define CURRENT_DATA_SECTION .FORTH_data.headers
.section CURRENT_DATA_SECTION,"a",@progbits
.section CURRENT_TEXT_SECTION,"ax",@progbits
.balign 2

.section CURRENT_DATA_SECTION,"a",@progbits
gobj FORTH_WORDS_START	; {{{ trick for STOP value for search: 0.header with none data
	P24 0		// prev header none
1:
obj FORTH_WORDS_START.attr
	.byte FLG_HIDDEN
	.byte 0 //len 0 + FLG_HIDDEN = impossible to find
	// zero bytes of name here
	P24 0		// emty codeword
	; }}}

