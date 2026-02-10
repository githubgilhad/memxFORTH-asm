#include <avr/io.h>
#include <avr/interrupt.h>
#include <stdlib.h>

// nnLIBS: Serial.none/usart0 FORTH/FORTH-Engine FORTH/FORTH-Memory
// LIBS: Serial.RTS/usart0 FORTH/FORTH-Engine FORTH/FORTH-Memory
// LOCLIBS: 003_fill_RAM words/all_words C2forth

//#include "Serial.none/usart0/usart0.h"
#include "Serial.RTS/usart0/usart0.h"
#include "FORTH/FORTH-Engine/FORTH-Engine.h"
#include "TCB_offsets.c"
#include "C2forth.h"
#include "flags.h"

#define TEXT __attribute__((section(".text")))
TEXT void write_char(char c){	// {{{
	TX0_Write(c);
}	// }}}
TEXT void write_num8(uint8_t n) {	// {{{
	if (n>99) {
		write_char('0'+ n/100);
		n=n % 100;
		};
	if (n>9) {
		write_char('0'+ n/10);
		n=n % 10;
		};
		write_char('0'+n);
}	// }}}
TEXT uint32_t c_to_number(char *buf, uint8_t base) {	// {{{
/*
    TX0_WriteStr("c_to_number(\"");
    TX0_WriteStr(buf);
    TX0_WriteStr("\", ");
    write_num8(base);
    TX0_Write(')');
    */
    char *end;
    int neg = 0;
    int32_t val;

    if (*buf == 0)
        return 0;   // empty token = error

    /* <cnum>  := '<char>' */
    if (buf[0] == '\'' && buf[2] == '\'' && buf[3] == 0) {
        uint32_t r = (uint8_t)buf[1];
        return r | 0xFF000000;
    }

    /* radix prefixes */
    switch (*buf) {
        case '#': base = 10; buf++; break;
        case '$': base = 16; buf++; break;
        case '%': base = 2;  buf++; break;
        default: /* BASEnum */ break;
    }

    /* optional sign */
    if (*buf == '-') {
        neg = 1;
        buf++;
    }

    if (*buf == 0)
        return 0;   // "-" alone is invalid

    val = strtol(buf, &end, base);

    /* must consume whole token */
    if (*end != 0)
        return 0;

    if (neg)
        val = -val;

    /* truncate to CELL = 24 bit, add FF as 4.byte as sign of success */
    /*
    TX0_Write('=');
    TX0_WriteHex24(val);
    TX0_Write(';');
    */

    return val | 0xFF000000;
}	// }}}
TEXT void c_cursor_xy(uint8_t x, uint8_t y) {	// {{{
//	write_char('\r');
//	write_char('\n');
//return;
	write_char('\e');
	write_char('[');
	write_num8(y+1);
	write_char(';');
	write_num8(x+1);
	write_char('H');
}	// }}}
Thread_Controll_Block TCB_test;
extern uint8_t TX0_WriteHex8(uint8_t h);  
extern uint8_t TX0_WriteHex16(uint16_t h);
extern uint8_t TX0_WriteHex24(uint32_t h);

// External FORTH primitives
extern void f_dup(void);
extern void run_in_FORTH_xt_in_IP(void);
extern __memx const uint8_t w_TEST_cw;
extern __memx const uint8_t w_QUIT_cw;
extern __memx const uint8_t w_zzz_eol_1;
extern __memx const uint8_t ww_zzz_eol_2;
extern __memx const uint8_t FORTH_WORDS_START;

#include <avr/pgmspace.h>

P24 C_B3at(P24 in) {	// {{{
	P24 out;
	__asm__ volatile (
	/* vstup: in je v r22:r23:r24 */
	
	"mov r30, r22 \n\t"   /* lo  */
	"mov r31, r23 \n\t"   /* hi  */
	"mov r25, r24 \n\t"   /* hlo */
	
	"call B3at     \n\t"  /* zavolání asm */
	
	/* výstup: r22:r23:r24 už obsahují návrat */
	: "=r" (out)          /* out ← r22:r23:r24 */
	: "r" (in)            /* in  → r22:r23:r24 */
	: "r25", "r30", "r31", "memory"
	);
	
	return out;
}	// }}}
uint8_t C_B1at(uint32_t in) __attribute__((naked));
uint8_t C_B1at(uint32_t in)
{
    __asm__ volatile (
        "mov r30, r22 \n\t"
        "mov r31, r23 \n\t"
        "mov r25, r24 \n\t"
        "call B1at     \n\t"
        "mov r24, r22 \n\t"
        "ret"
    );
}	// }}}
static inline P24 u32_to_p24(uint32_t v) // {{{
{
    P24 p;
    p.dta.lo  = (uint8_t)(v & 0xFF);
    p.dta.hi  = (uint8_t)((v >> 8) & 0xFF);
    p.dta.hlo = (uint8_t)((v >> 16) & 0xFF);
    return p;
} // }}}
static inline uint32_t p24_to_u32(P24 p)	// {{{
{
    return  ((uint32_t)p.dta.lo) |
            ((uint32_t)p.dta.hi  << 8) |
            ((uint32_t)p.dta.hlo << 16);
}	// }}}
TEXT void C_Tracer(uint32_t DT,uint16_t IP,uint16_t RST,uint16_t DST,uint32_t TOS) {	// {{{
	uint8_t c;
	char cc;
	uint32_t a = (uint32_t)DT-3;
	for (uint8_t i=0; i<32;i++) {
		a--;
		c = C_B1at(a);
		if (c <32) break;
	};
	
	P24 *rst_ptr = (P24 *)(uintptr_t)RST;
	P24 *dst_ptr = (P24 *)(uintptr_t)DST;
	uint16_t depth_R = &TCB_test.ReturnStack[RST_SIZE-1] - rst_ptr;
	uint16_t depth_D = &TCB_test.DataStack[DST_SIZE-2] - dst_ptr;
	
	
	write_char('\r');
	write_char('\n');
	write_num8(depth_R);
	for (int8_t i=0;i< depth_R; i++) write_char('\t');
	write_char(' ');
	DT-=3;
	TX0_WriteHex24(DT);
	write_char(' ');
	write_num8(c);
	write_char(' ');
	if (c<32) for (uint8_t i=0; i<c;i++) { 
		a++;
		cc = C_B1at(a);
		write_char(cc);
//		write_char(pgm_read_byte_far(a));
	};
	write_char('\e');
	write_char('[');
	write_num8(80+1);
	write_char('G');
	write_num8(depth_D);
	for (int8_t i=2;i< depth_D+1; i++) { 
		write_char(' '); 
		TX0_WriteHex24(p24_to_u32(TCB_test.DataStack[DST_SIZE-2-i])); 
	};
	write_char(':');
	TX0_WriteHex24(TOS);
	
	write_char('\e');
	write_char('[');
	write_num8(190+1);
	write_char('G');
	write_num8(depth_R);
	write_char(' ');
	for (int8_t i=1;i< depth_R+1; i++) { 
		TX0_WriteHex24(p24_to_u32(TCB_test.ReturnStack[RST_SIZE-1-i])); 
		write_char(' '); 
	};
	write_char('|');
	write_char(' ');
	TX0_WriteHex24(IP - 3 );
	write_char(' ');
	write_char('|');
	
return;
/*
	write_char('\e');
	write_char('[');
	write_num8(y+1);
	write_char(';');
	write_num8(x+1);
	write_char('H');
	*/
}	// }}}
TEXT void C_words() {	// {{{
	uint32_t head, a;
	P24 p;
	uint8_t len = TCB_test.WL_ORDER_len;
	for (uint8_t i=0;i<len;i++) {
		TX0_WriteStr("\r\n=== ");
		TX0_WriteHex8(i);
		TX0_WriteStr(" ===\r\n");
		p=TCB_test.WL_ORDER[i];
		/*
		TX0_WriteHex8(p.dta.hlo);
		TX0_WriteHex8(p.dta.hi);
		TX0_WriteHex8(p.dta.lo);
		TX0_Write(':');
		*/
		
		p=C_B3at(p);
		/*
		TX0_WriteHex8(p.dta.hlo);
		TX0_WriteHex8(p.dta.hi);
		TX0_WriteHex8(p.dta.lo);
		TX0_Write(':');
		*/
		
		head= p24_to_u32(p);
		uint8_t count=10;
		
		uint8_t b,b1,b2,b3,att;
		
		while (head) {
		if (! count--) { count=10; TX0_Write('\r');TX0_Write('\n');};
		TX0_Write('<');
		// TX0_WriteHex24(head);
		// TX0_Write(':');
		a=head;
		b1=C_B1at(a++);
		b2=C_B1at(a++);
		b3=C_B1at(a++);
		head= b1+0x100*b2+0x10000*b3;
		// TX0_WriteHex24(head);
		// TX0_Write(':');
		att=C_B1at(a++);//attrib
		if (att){
			if (att & FLG_IMMEDIATE)
			if (att & FLG_IMMEDIATE)	{ TX0_Write('I'); };
			if (att & FLG_HIDDEN)		{ TX0_Write('H'); };
			if (att & FLG_FOG)		{ TX0_Write('F'); };
			if (att & FLG_ARG_1)		{ TX0_Write('1'); };
			if (att & FLG_ARG_2)		{ TX0_Write('2'); };
//			if (att & FLG_ARG_3)		{ TX0_Write('3'); };
			if (att & FLG_PSTRING)		{ TX0_Write('P'); };
			TX0_Write(':');
		};
		b=C_B1at(a++);
		if (b) for (uint8_t i=0; i<b;i++) TX0_Write( C_B1at(a++));
		TX0_Write('>');
		TX0_Write(' ');
		};
	};
}	// }}}


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
uint8_t HERE1[0x300];
// static 
P24 WL_all;
P24 WL_all_2;
P24 WL_all_3;
TEXT int main(void) {
	setup();
//	C_words();
	TX0_Write('\r');
	TX0_Write('\n');
	TX0_Write('#');
	TX0_Write('>');
	
	WL_all	.ptr = &w_zzz_eol_1;
	WL_all_2.ptr = &ww_zzz_eol_2;
	WL_all_3.ptr = &FORTH_WORDS_START;
	TCB_test.	TCB_cur 	.ptr	= & TCB_test;
	TCB_test.	DataStackFirst	.ptr	= & TCB_test.DataStack		[0];
	TCB_test.	DataStackLast	.ptr	= & TCB_test.DataStack		[DST_SIZE - 1];
	TCB_test.	ReturnStackFirst.ptr	= & TCB_test.ReturnStack	[0];
	TCB_test.	ReturnStackLast	.ptr	= & TCB_test.ReturnStack	[RST_SIZE - 1];
	
	/*
	for (uint8_t i=0; i<DST_SIZE;++i)	TCB_test.DataStack[i] 	= u32_to_p24(P24_Canary);
	for (uint8_t i=0; i<RST_SIZE;++i)	TCB_test.ReturnStack[i]	= u32_to_p24(P24_Canary);
	for (uint8_t i=0; i<TIB_SIZE;++i)	TCB_test.TIB[i]	= 'T';
	for (uint8_t i=0; i<AIB_SIZE;++i)	TCB_test.AIB[i]	= 'A';
	for (uint8_t i=0; i<ORDER_SIZE;++i)	TCB_test.WL_ORDER[i]	= u32_to_p24(P24_Canary);
	*/
	
	for (uint8_t i=0; i<DST_SIZE;++i)	TCB_test.DataStack[i] 	= u32_to_p24(0x444444);
	for (uint8_t i=0; i<RST_SIZE;++i)	TCB_test.ReturnStack[i]	= u32_to_p24(0x525252);
	for (uint8_t i=0; i<TIB_SIZE;++i)	TCB_test.TIB[i]	= 'T';
	for (uint8_t i=0; i<AIB_SIZE;++i)	TCB_test.AIB[i]	= 'A';
	for (uint8_t i=0; i<ORDER_SIZE;++i)	TCB_test.WL_ORDER[i]	= u32_to_p24(0x4f4f4f);
	
	// For now, just echo serial input
	TCB_test.	STATE			= F_INTERPRETING ;
	TCB_test.	BASE			= 10 ; 
	TCB_test.	HERE		.ptr	= & HERE1;
	TCB_test.	TIB_len		.u16	= 0 ;  
	TCB_test.	TIB_cur		.u16	= 1 ;  
	TCB_test.	AIB_len		.u16	= 0 ;  
	TCB_test.	AIB_max		.u16	= 0 ;  
	TCB_test.	AIB_cur		.u16	= 1 ;  
	TCB_test.	WL_ORDER_len		= 3 ;
	TCB_test.	WL_ORDER[0]	.ptr	= & WL_all;
	TCB_test.	WL_ORDER[1]	.ptr	= & WL_all_2;
	TCB_test.	WL_ORDER[2]	.ptr	= & WL_all_3;
	TCB_test.	WL_CURRENT	.ptr	= & WL_all_3;
	// Set this to your word
	TCB_test.	IP		.ptr	= & w_TEST_cw;
	TCB_test.	DST		.ptr	= & TCB_test.DataStack		[DST_SIZE - 2];
	TCB_test.	RST		.ptr	= & TCB_test.ReturnStack	[RST_SIZE - 1];
	TCB_test.	TOS			=   u32_to_p24( P24_Canary );
	TCB_test.	DT			=   u32_to_p24( P24_Canary );
/*
	C2FORTH(&TCB_test, (uint32_t)(uintptr_t)&run_in_FORTH_xt_in_IP);
	TX0_WriteHex24(p24_to_u32(TCB_test.TOS));
	TX0_Write('\r');
	TX0_Write('\n');
	TX0_Write('#');
	TX0_Write('>');
*/
	TCB_test.	IP		.ptr	= & w_QUIT_cw;
/**/	
	C2FORTH(&TCB_test, (uint32_t)(uintptr_t)&run_in_FORTH_xt_in_IP);
	TX0_Write('\r');
	TX0_Write('\n');
	TX0_Write('=');
	TX0_WriteHex24(p24_to_u32(TCB_test.TOS));
	TX0_Write('\r');
	TX0_Write('\n');
	TX0_Write('$');
	TX0_Write('>');

	/*
	TCB_test.IP=u32_to_p24((uint32_t)(uintptr_t)&w_QUIT_cw);
	C2FORTH(&TCB_test, (uint32_t)(uintptr_t)&run_in_FORTH_xt_in_IP);
	TX0_Write('\r');
	TX0_Write('\n');
	TX0_Write('#');
	TX0_Write('>');
	*/
	while (1) {
		loop();
	}
}

