#include <stdint.h>
#include <stddef.h>
#include "../../../libs/FORTH/FORTH-Defines/FORTH-Defines.h"
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
	// FORTH state
	P24 IP;
	P16 DST;
	P16 RST;
	P24 TOS;
	P24 DT; 	// probably not used, we will return to yield() before NEXT	//  probably not used, generated in NEXT
	P16 TCB_cur;	// address of this variable
	uint8_t STATE;	// 0 interpret, 1 compile
	uint8_t BASE;	// 2..36
	P24 HERE;	// place in RAM for next word (or external RAM)
	P16 TIB_len;	// #TIB - offset to last char in TIB now
	P16 TIB_cur;	// >IN - offset to first unread char in TIB
	P16 AIB_len;	// #AIB - offset to last char in AIB now
	P16 AIB_max;	// AIB.max - max allowed len for ACCEPT
	P16 AIB_cur;	// >AIN - offset to first unread char in AIB
	uint8_t WL_ORDER_len;	// number of WLs in ORDER (255 is too much anyway)
	P24 WL_CURRENT;	// current wordlit
	P16 DataStackFirst;
	P16 DataStackLast;
	P16 ReturnStackFirst;
	P16 ReturnStackLast;

	P24 DataStack[DST_SIZE];
	P24 ReturnStack[RST_SIZE];
	uint8_t TIB[TIB_SIZE];
	uint8_t AIB[AIB_SIZE];
	P24 WL_ORDER[ORDER_SIZE];
	// something_else
	uint32_t something_else;
} Thread_Controll_Block;

/* export offsets for ASM */

/* This generate text, that we will extract later. Not necessery valid code. */
#define GEN(sym, val) \
	asm volatile (".equ " #sym ", %0" :: "i"(val))


void gen_offsets(void)		// this is envelope for our generated text, it will NOT be compiled, just macro expanded.
{
	// FORTH state
	GEN(TCB_IP,			offsetof(Thread_Controll_Block, IP));
	GEN(TCB_DST,			offsetof(Thread_Controll_Block, DST));
	GEN(TCB_RST,			offsetof(Thread_Controll_Block, RST));
	GEN(TCB_TOS,			offsetof(Thread_Controll_Block, TOS));
	GEN(TCB_DT,			offsetof(Thread_Controll_Block, DT));
	GEN(TCB_TCB_cur,		offsetof(Thread_Controll_Block, TCB_cur));
	GEN(TCB_STATE,			offsetof(Thread_Controll_Block, STATE));
	GEN(TCB_BASE,			offsetof(Thread_Controll_Block, BASE));
	GEN(TCB_HERE,			offsetof(Thread_Controll_Block, HERE));
	GEN(TCB_TIB_len,		offsetof(Thread_Controll_Block, TIB_len));
	GEN(TCB_TIB_cur,		offsetof(Thread_Controll_Block, TIB_cur));
	GEN(TCB_AIB_len,		offsetof(Thread_Controll_Block, AIB_len));
	GEN(TCB_AIB_max,		offsetof(Thread_Controll_Block, AIB_max));
	GEN(TCB_AIB_cur,		offsetof(Thread_Controll_Block, AIB_cur));
	GEN(TCB_WL_ORDER_len,		offsetof(Thread_Controll_Block, WL_ORDER_len));
	GEN(TCB_WL_CURRENT,		offsetof(Thread_Controll_Block, WL_CURRENT));
	GEN(TCB_DataStackFirst,		offsetof(Thread_Controll_Block, DataStackFirst));
	GEN(TCB_DataStackLast,		offsetof(Thread_Controll_Block, DataStackLast));
	GEN(TCB_ReturnStackFirst,	offsetof(Thread_Controll_Block, ReturnStackFirst));
	GEN(TCB_ReturnStackLast,	offsetof(Thread_Controll_Block, ReturnStackLast));
	GEN(TCB_DataStack,		offsetof(Thread_Controll_Block, DataStack));
	GEN(TCB_ReturnStack,		offsetof(Thread_Controll_Block, ReturnStack));
	GEN(TCB_TIB,			offsetof(Thread_Controll_Block, TIB));
	GEN(TCB_AIB,			offsetof(Thread_Controll_Block, AIB));
	GEN(TCB_WL_ORDER,		offsetof(Thread_Controll_Block, WL_ORDER));
	// something_else
	GEN(TCB_something_else,		offsetof(Thread_Controll_Block, something_else));
	// total size
	GEN(TCB_SIZE,			sizeof(Thread_Controll_Block));
};
