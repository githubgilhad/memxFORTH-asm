#pragma once

#include <stdint.h>
#include <stddef.h>
#include "FORTH-Defines.h"
typedef struct __attribute__((packed)) { uint8_t lo, hi, hlo; } P24s;
// typedef struct __attribute__((packed)) { uint8_t lo, hi; } P16;
// typedef union { struct { uint8_t lo; uint8_t hi; uint8_t hlo; };
typedef union { 	P24s dta;
			uint16_t u16;
			__memx const void  *ptr;
			void * ptr_ram;
		} P24;
typedef union { struct { uint8_t lo; uint8_t hi; };
			uint16_t u16;
			void *ptr;
			P24 *ptr_P24;
		} P16;


typedef struct __attribute__((packed)) {
	P24 read_char;
	P24 write_char;
	P24 cls;
	P24 set_cursor_visible;
	P24 set_cursor_char;
	P24 set_cursor_X;
	P24 set_cursor_Y;
	P24 set_cursor_XY;
	P24 put_char_XY;
	P24 set_def_color;
	P24 set_row_color;
	P24 set_row_color_Y;
	P24 char_at_XY;
	P24 MAX_LINES;
	P24 MAX_COLUMNS;
	P24 wait;
	P24 cr;
	P24 HEADLESS;
	P24 HEADMORE;
} Virtual_Table;

typedef struct __attribute__((packed)) {
	// FORTH state
	P24 IP;
	P16 DST;
	P16 RST;
	P16 LST;
	P24 TOS;
	P24 DT; 	// probably not used, we will return to yield() before NEXT	//  probably not used, generated in NEXT
	P16 TCB_cur;	// address of this variable
	uint8_t STATE;	// 0 interpret, 1 compile
	uint8_t BASE;	// 2..36
	P24 HERE;	// place in RAM for next word (or external RAM)
	P16 TIB_len;	// #TIB - offset to last char in TIB now
	P16 TIB_cur;	// >IN - offset to first unread char in TIB
	P16 TIB_max;	// TIB.max -size of TIB
	P16 AIB_len;	// #AIB - offset to last char in AIB now
	P16 AIB_max;	// AIB.max - max allowed len for ACCEPT
	P16 AIB_cur;	// >AIN - offset to first unread char in AIB
	uint8_t WL_ORDER_len;	// number of WLs in ORDER (255 is too much anyway)
	P24 WL_CURRENT;	// current wordlist
	P16 getc_ctx;	// input_stack_t *s, for getc input chain stack parameter; pointer to RAM
	P16 DataStackFirst;
	P16 DataStackLast;
	P16 ReturnStackFirst;
	P16 ReturnStackLast;
	P16 LStackFirst;
	P16 LStackLast;

	P24 DataStack[DST_SIZE];
	P24 ReturnStack[RST_SIZE];
	P24 LStack[LST_SIZE];
	uint8_t TIB[TIB_SIZE];
	uint8_t AIB[AIB_SIZE];
	P24 WL_ORDER[ORDER_SIZE];
	Virtual_Table *VT;
	// something_else
	uint32_t something_else;
} Thread_Controll_Block;

