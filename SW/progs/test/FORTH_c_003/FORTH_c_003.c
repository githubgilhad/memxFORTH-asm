#include <avr/io.h>
#include <avr/interrupt.h>
// LIBS: Serial.RTS/usart0 FORTH/FORTH-Engine FORTH/FORTH-Memory
// LOCLIBS: primitives

#include "Serial.RTS/usart0/usart0.h"
#include "FORTH/FORTH-Engine/FORTH-Engine.h"

#define TEXT __attribute__((section(".text")))
#define DST_SIZE 30
#define RST_SIZE 30

#include "user_offsets.c"

P24 DataStack[DST_SIZE];
P24 *DataStackFirst = &DataStack[0];
P24 *DataStackLast = &DataStack[DST_SIZE - 1];

P24 ReturnStack[RST_SIZE];
P24 *ReturnStackFirst = &ReturnStack[0];
P24 *ReturnStackLast = &ReturnStack[RST_SIZE - 1];

// External FORTH primitives
extern void f_dup(void);
extern void f_drop(void);
extern void f_swap(void);
extern void f_over(void);
extern void f_plus(void);
extern void f_minus(void);
extern void f_times(void);
extern void f_div(void);
extern void f_at(void);
extern void f_store(void);
extern void f_char_at(void);
extern void f_char_store(void);
extern void f_key(void);
extern void f_emit(void);
extern void f_exit(void);
extern void f_docol(void);
extern void f_lit(void);

// FORTH start function - initializes registers and executes a word
// word_addr: 24-bit address of codeword to execute
TEXT void FORTH_start(uint32_t word_addr) {
	// Initialize registers according to FORTH-Defines.h
	// IP = Instruction Pointer (r8-r10) - will be set to word_addr
	// TOS = Top Of Stack (r4-r6) - initialized to 0
	// ST = Stack Pointer (Y register, r28-r29) - points to end of DataStack
	// RS = Return Stack Pointer (r2-r3) - points to end of ReturnStack
	
	uint8_t word_lo = word_addr & 0xFF;
	uint8_t word_hi = (word_addr >> 8) & 0xFF;
	uint8_t word_hlo = (word_addr >> 16) & 0xFF;
	
	__asm__ __volatile__ (
		// Set r1 to 0 (zero register) - must be first
		"clr r1\n\t"
		
		// Initialize TOS to 0
		"clr r4\n\t"
		"clr r5\n\t"
		"clr r6\n\t"
		
		// Initialize ST (Y register) to end of DataStack (stacks grow down)
		"ldi r28, lo8(%0)\n\t"
		"ldi r29, hi8(%0)\n\t"
		
		// Initialize RS (r2-r3) to end of ReturnStack, use registers over r15 for ldi
		"ldi r16, lo8(%1)\n\t"
		"ldi r17, hi8(%1)\n\t"
		"mov r2, r16\n\t"
		"mov r3, r17\n\t"
		// Set IP to word_addr (r8-r10)
		"mov r8, %2\n\t"	// lo byte
		"mov r9, %3\n\t"	// hi byte
		"mov r10, %4\n\t"	// hlo byte
		
		// Jump to NEXT (never returns)
		"rjmp NEXT\n\t"
		:
		: "i" (&DataStack[DST_SIZE]),	// %0 - end of DataStack
		  "i" (&ReturnStack[RST_SIZE]),	// %1 - end of ReturnStack
		  "r" (word_lo),			// %2 - word_addr lo
		  "r" (word_hi),			// %3 - word_addr hi
		  "r" (word_hlo)			// %4 - word_addr hlo
		: "r1", "r4", "r5", "r6", "r28", "r29", "r2", "r3", "r8", "r9", "r10"
	);
	__builtin_unreachable();
}

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
User User_test;
TEXT int main(void) {
	setup();
	
	// For now, just echo serial input
	// Later, this will start FORTH interpreter
//	FORTH_start((uint32_t)(uintptr_t)&f_dup); // for now any address is fine, will be replaced by real FORTH interpreter later
	User_test.IP=(uint32_t)(uintptr_t)&w_test_cw;
	User_test.DST=&DataStack[DST_SIZE];
	User_test.RST=&ReturnStack[RST_SIZE];
	User_test.TOS=0xCACAA7;
	User_test.DT=0xCACAA7;
	C2FORTH(&User_test, (uint32_t)(uintptr_t)&run_in_FORTH_xt_in_IP);
	TX0_WriteHex24(User_test.TOS);
	while (1) {
		loop();
	}
}

