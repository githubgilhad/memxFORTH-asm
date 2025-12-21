#pragma once

#include "TextVGA.def"
typedef void (*isr_handler)(void);
typedef char T_TextVGA_VRAM[TextVGA_LINES][TextVGA_ROWS];
typedef uint8_t T_TextVGA_CRAM[TextVGA_LINES];
// typedef const uint8_t T_TextVGA_CharDef[][256]; // at least 8 sublines // PROBLEM with >16 bit addresses
typedef uint_farptr_t P_TextVGA_CharDef; // at least 8 sublines


// 1. fill these pointer to point to your VideoRam structures in FAST RAM (0x200..0x2200)

extern T_TextVGA_VRAM *TextVGA_VRAM;
extern T_TextVGA_CRAM *TextVGA_CRAM;

// 2. this pointer goes to FLASH, like this: TextVGA_CharDef = pgm_get_far_address(StdTextCharDef);

extern P_TextVGA_CharDef TextVGA_CharDef;

// 3. Then make sure this (normal C) functions are called from respective IRQ handlers

void TextVGA_TIMER1_OVF_vect_handler();
void TextVGA_TIMER3_OVF_vect_handler();

extern isr_handler TextVGA_VerticalBlank; // if not NULL called in ISR after last line is drawn and lot of free time is ahead
	// it is still in IRQ, so best approach is to just set few flags and bussy wait for them in main program
	// called 60 times per second

// 4. Then call TextVGA_begin() so the VideoRam is showed on VGA monitor

void TextVGA_begin();

// 5. now the content is displayed 60x per second, just fill in characters and colors

// 6. Call TextVGA_end() to stop displaying VideoRam (and then maybe activate other driver similar way)

void TextVGA_end();

// /////////// automagically updated variables:

extern volatile uint16_t TextVGA_scanline; // 0..199 top porch, 200..400 visible
extern volatile uint8_t TextVGA_textline; // 0..24 line of text
extern volatile uint8_t TextVGA_subline; // 0..7 line of character
