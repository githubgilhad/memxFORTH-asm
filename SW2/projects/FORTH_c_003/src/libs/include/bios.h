/* vim: ft=cpp showbreak=--»\  noexpandtab fileencoding=utf-8 nomodified wrap textwidth=0 foldmethod=marker foldmarker={{{,}}} foldcolumn=4 ruler showcmd lcs=tab\:|- list: tabstop=8 linebreak tags=./tags;,tags; 
 * */
// ,,g = gcc, exactly one space after "set"
//
#pragma once
#include "../../FORTH_c_003.h"
#include <stdbool.h>
#include <stdint.h>
#include <avr/pgmspace.h>
#include "StdTextCharDef.h"
#include "SnakeCharDef.h"
#include "SnakeCharDef2.h"
#include "ScanToASCII.h"
#include "apply_shift.h"
#include "PS2_driver.h"
#include "buffer.h"
#include "DebugLEDs.h"
#include "getc.h"
#include "TextVGA.h"
uint8_t process_scan_code(uint8_t code);

void bios_setup(); 

// VT candidates:
uint8_t ps2_getc(void *state, char *out_char);		// ignore state, return GETC_OK==0 on success, write char 

void VGA_write_char(uint8_t c);				// write char to cursor, move cursor, screll screen if needed
void VGA_cls();						// clear screen with default character and color, moves cursor to 0,0
void VGA_set_cursor_visible(bool c);			// set new value, return old
void VGA_set_cursor_char(uint8_t c);			// set new value, return old
void VGA_set_cursor_X(uint8_t x);			// set new value, return old
void VGA_set_cursor_Y(uint8_t y);			// set new value, return old
void VGA_set_cursor_XY(uint8_t x, uint8_t y);		// set new value
uint16_t VGA_get_cursor_XY();				// get value (r24 = X, r25 = Y) X+256*Y
void VGA_put_char_XY(char c, uint8_t x, uint8_t y);	// put char on screen without moving cursor
void VGA_set_def_color(uint8_t col);			// set current row color
void VGA_set_def_char(uint8_t c);			// set default char for cls and scroll
void VGA_set_row_color(uint8_t col);			// set current row color
void VGA_set_row_color_Y(uint8_t col, uint8_t y);	// set row color
uint8_t VGA_char_at_XY(uint8_t x, uint8_t y);		// return char at X,Y
uint8_t VGA_MAX_LINES();				// 
uint8_t VGA_MAX_COLUMNS();				// 
void VGA_cr(); 
void VGA_HEADLESS();
void VGA_HEADMORE();
