#pragma once

#include "TextRCA.def"
typedef void (*isr_handler)(void);
typedef char T_TextRCA_VRAM[TextRCA_LINES][TextRCA_ROWS];
typedef uint8_t T_TextRCA_CRAM[TextRCA_LINES];
// typedef const uint8_t T_TextRCA_CharDef[][256]; // at least 8 sublines // PROBLEM with >16 bit addresses
typedef uint_farptr_t P_TextRCA_CharDef; // at least 8 sublines


// 1. fill these pointer to point to your VideoRam structures in FAST RAM (0x200..0x2200)

extern T_TextRCA_VRAM *TextRCA_VRAM;
extern T_TextRCA_CRAM *TextRCA_CRAM;

// 2. this pointer goes to FLASH, like this: TextRCA_CharDef = pgm_get_far_address(StdTextCharDef);

extern P_TextRCA_CharDef TextRCA_CharDef;

// 3. Then make sure this (normal C) functions are called from respective IRQ handlers

void TextRCA_TIMER1_COMPA_vect_handler();
void TextRCA_TIMER3_OVF_vect_handler();
void TextRCA_TIMER1_OVF_vect_handler();

extern isr_handler TextRCA_VerticalBlank; // if not NULL called in ISR after last line is drawn and lot of free time is ahead
	// it is still in IRQ, so best approach is to just set few flags and bussy wait for them in main program
	// called 60 times per second

// 4. Then call TextRCA_begin() so the VideoRam is showed on RCA monitor

void TextRCA_begin();

// 5. now the content is displayed 60x per second, just fill in characters and colors

// 6. Call TextRCA_end() to stop displaying VideoRam (and then maybe activate other driver similar way)

void TextRCA_end();

// /////////// automagically updated variables:

extern volatile uint16_t TextRCA_scanline; // 0..13 top porch, 14.. visible
extern volatile uint8_t TextRCA_textline; // 0..24 line of text
extern volatile uint8_t TextRCA_subline; // 0..7 line of character
