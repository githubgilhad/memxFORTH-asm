#include <avr/io.h>
#include <avr/interrupt.h>
// LIBS: Serial.RTS/usart0 FORTH/FORTH-Engine FORTH/FORTH-Memory
// LOCLIBS: 003_fill_RAM words/all_words C2forth

#include "Serial.RTS/usart0/usart0.h"
#include "FORTH/FORTH-Engine/FORTH-Engine.h"
#include "TCB_offsets.c"
#include "C2forth.h"

#define TEXT __attribute__((section(".text")))



// External FORTH primitives
extern void f_dup(void);
extern void run_in_FORTH_xt_in_IP(void);
extern uint8_t w_test_cw;

TEXT void setup(void) {
	usart0_setup();
	sei();
}

TEXT void loop(void) {
	uint16_t ch = RX0_Read();
	if (ch >> 8) { // Pokud r25 != 0
		TX0_Write((char)(ch & 0xFF)); // Blokuje dokud není volno
		if ((ch & 0xFF)==13)
			TX0_Write(10); // Blokuje dokud není volno
	};
//	for (int i=0;i<256;i++) ch=PORTF;
//	__asm__ __volatile__ ("jmp NEXT \n\t");
//	NEXT();
}
Thread_Controll_Block TCB_test;
static inline P24 u32_to_p24(uint32_t v)
{
    P24 p;
    p.lo  = (uint8_t)(v & 0xFF);
    p.hi  = (uint8_t)((v >> 8) & 0xFF);
    p.hlo = (uint8_t)((v >> 16) & 0xFF);
    return p;
}
static inline uint32_t p24_to_u32(P24 p)
{
    return  ((uint32_t)p.lo) |
            ((uint32_t)p.hi  << 8) |
            ((uint32_t)p.hlo << 16);
}
static inline P16 u16_to_p16(uint16_t v)
{
    P16 p;
    p.lo  = (uint8_t)(v & 0xFF);
    p.hi  = (uint8_t)((v >> 8) & 0xFF);
    return p;
}
static inline uint16_t p16_to_u16(P16 p)
{
    return  ((uint16_t)p.lo) |
            ((uint16_t)p.hi  << 8);
}
TEXT int main(void) {
	setup();
	TCB_test.DataStackFirst.ptr_P24 = &TCB_test.DataStack[0];
	TCB_test.DataStackLast.ptr_P24 = &TCB_test.DataStack[DST_SIZE - 1];
	for (uint8_t i=0; i<DST_SIZE;++i) TCB_test.DataStack[i]=u32_to_p24(P24_Canary);

	TCB_test.ReturnStackFirst.ptr_P24 = &TCB_test.ReturnStack[0];
	TCB_test.ReturnStackLast.ptr_P24 = &TCB_test.ReturnStack[RST_SIZE - 1];
	for (uint8_t i=0; i<RST_SIZE;++i) TCB_test.ReturnStack[i]=u32_to_p24(P24_Canary);
	
	// For now, just echo serial input
	TCB_test.IP=u32_to_p24((uint32_t)(uintptr_t)&w_test_cw);
	TCB_test.DST=u16_to_p16((uint16_t)(uintptr_t)&(TCB_test.DataStack[DST_SIZE-2]));
	TCB_test.RST=u16_to_p16((uint16_t)(uintptr_t)&(TCB_test.ReturnStack[RST_SIZE-1]));
	TCB_test.TOS=u32_to_p24(P24_Canary);
	TCB_test.DT=u32_to_p24(P24_Canary);
	C2FORTH(&TCB_test, (uint32_t)(uintptr_t)&run_in_FORTH_xt_in_IP);
	TX0_WriteHex24(p24_to_u32(TCB_test.TOS));
	while (1) {
		loop();
	}
}

