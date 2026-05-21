; .. vim: ft=asm showbreak=--»\  noexpandtab fileencoding=utf-8 nomodified   wrap textwidth=0 foldmethod=marker foldmarker={{{,}}} foldcolumn=4 ruler showcmd lcs=tab\:|- list tabstop=8 noexpandtab nosmarttab softtabstop=0 shiftwidth=0 linebreak  tags=./tags;,tags; 


DEFWORD w_SOUND_PLAY,		0,		"SOUND.PLAY",		f_SOUND_PLAY		; ( NOTE_A4  --  ) start sound with this divisor
DEFWORD w_SOUND_STOP,		0,		"SOUND.STOP",		f_SOUND_STOP		; (  --  ) stop playing sound

	.equ NOTE_C4 , 3821
	.equ NOTE_CS4, 3607
	.equ NOTE_D4 , 3405
	.equ NOTE_DS4, 3214
	.equ NOTE_E4 , 3033
	.equ NOTE_F4 , 2863
	.equ NOTE_FS4, 2702
	.equ NOTE_G4 , 2551
	.equ NOTE_GS4, 2407
	.equ NOTE_A4 , 2272
	.equ NOTE_AS4, 2145
	.equ NOTE_B4 , 2024

	.equ NOTE_C5 , 1911
	.equ NOTE_D5 , 1702
	.equ NOTE_E5 , 1516
	.equ NOTE_F5 , 1431
	.equ NOTE_G5 , 1275
	.equ NOTE_A5 , 1136
	.equ NOTE_B5 , 1012

DEFCONSTI2	"NOTE_C4",	"NOTE_C4",	NOTE_C4,	line=3
DEFCONSTI2	"NOTE_CS4",	"NOTE_CS4",	NOTE_CS4,	line=3
DEFCONSTI2	"NOTE_D4",	"NOTE_D4",	NOTE_D4,	line=3
DEFCONSTI2	"NOTE_DS4",	"NOTE_DS4",	NOTE_DS4,	line=3
DEFCONSTI2	"NOTE_E4",	"NOTE_E4",	NOTE_E4,	line=3
DEFCONSTI2	"NOTE_F4",	"NOTE_F4",	NOTE_F4,	line=3
DEFCONSTI2	"NOTE_FS4",	"NOTE_FS4",	NOTE_FS4,	line=3
DEFCONSTI2	"NOTE_G4",	"NOTE_G4",	NOTE_G4,	line=3
DEFCONSTI2	"NOTE_GS4",	"NOTE_GS4",	NOTE_GS4,	line=3
DEFCONSTI2	"NOTE_A4",	"NOTE_A4",	NOTE_A4,	line=3
DEFCONSTI2	"NOTE_AS4",	"NOTE_AS4",	NOTE_AS4,	line=3
DEFCONSTI2	"NOTE_B4",	"NOTE_B4",	NOTE_B4,	line=3

DEFCONSTI2	"NOTE_C5",	"NOTE_C5",	NOTE_C5,	line=3
DEFCONSTI2	"NOTE_D5",	"NOTE_D5",	NOTE_D5,	line=3
DEFCONSTI2	"NOTE_E5",	"NOTE_E5",	NOTE_E5,	line=3
DEFCONSTI2	"NOTE_F5",	"NOTE_F5",	NOTE_F5,	line=3
DEFCONSTI2	"NOTE_G5",	"NOTE_G5",	NOTE_G5,	line=3
DEFCONSTI2	"NOTE_A5",	"NOTE_A5",	NOTE_A5,	line=3
DEFCONSTI2	"NOTE_B5",	"NOTE_B5",	NOTE_B5,	line=3
.section CURRENT_TEXT_SECTION,"ax",@progbits
gfunc func_SOUND_PLAY	; {{{
	; PL3 / OC5A jako output
	lds	Tx,	DDRL
	ori	Tx,	_BV(3)
	sts	DDRL,	Tx
	
	; nastavit compare value
	sts OCR5AL, r24
	sts OCR5AH, r25
	
	;
	; Toggle OC5A on compare match
	;
	; COM5A0 = 1
	;
	ldi r24, (1<<COM5A0)
	sts TCCR5A, r24
	
	;
	; CTC mode
	; WGM52 = 1
	;
	; prescaler = 8
	; CS51 = 1
	;
	ldi r24, (1<<WGM52) | (1<<CS51)
	sts TCCR5B, r24
	
	ret
; }}}
gfunc f_SOUND_PLAY	; {{{
	Set2	Cpar1,	TOS2
	rcall func_SOUND_PLAY
	PopST	TOS
	jmp NEXT
; }}}
gfunc func_SOUND_STOP	; {{{
	; stop timer
	ldi r24, 0
	sts TCCR5B, r24

	; disconnect OC5A
	sts TCCR5A, r24

	; output low
	lds	Tx,	PORTL
	andi	Tx,	~_BV(3)
	sts	PORTL,	Tx

	ret
; }}}
gfunc f_SOUND_STOP	; {{{
	rcall	func_SOUND_STOP
	jmp NEXT
; }}}

