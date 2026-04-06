#define __SFR_OFFSET 0x00		// set the Special Function Register Offset from 0x20 to 0x00 in order to use AVR PORT definitions
#include <avr/io.h>
#include "../../flags.h"

#include "FORTH-Defines.h"
#include "FORTH-Macros.h"
#include "FORTH-Memory.h"
#include "../../../version.h"
;	#include "FORTH-Engine.h"

#include "../../TCB_offsets.inc"
#include "../../getc.inc"
#include "TextVGA.inc"

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
101:
102:
103:
104:
obj FORTH_WORDS_START.attr
	.byte FLG_HIDDEN
	.byte 0 //len 0 + FLG_HIDDEN = impossible to find
	// zero bytes of name here
	P24 0		// emty codeword
	; }}}

