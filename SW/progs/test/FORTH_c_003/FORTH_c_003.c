#include <avr/io.h>
#include <avr/interrupt.h>
#include <stdlib.h>

// nnLIBS: Serial.none/usart0 FORTH/FORTH-Engine FORTH/FORTH-Memory
// LIBS: Serial.RTS/usart0 FORTH/FORTH-Engine FORTH/FORTH-Memory
// LOCLIBS: 003_fill_RAM words/all_words C2forth bats debug io

//#include "Serial.none/usart0/usart0.h"
#include "Serial.RTS/usart0/usart0.h"
#include "FORTH/FORTH-Engine/FORTH-Engine.h"
#include "TCB_offsets.c"
#include "C2forth.h"
#include "flags.h"
#include "bats.h"
#include "debug.h"

#define TEXT __attribute__((section(".text")))
TEXT void write_char(char c){	// {{{
	TX0_Write(c);
}	// }}}
TEXT void write_charA(char c){	// {{{
	TX0_WriteA(c);
}	// }}}
TEXT char read_char(){	// {{{
	return RX0_Read();
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

typedef const __memx uint8_t *xpC;
typedef const __memx uint8_t   xC;
typedef const uint8_t *npC;
typedef const uint8_t   nC;


extern __memx const uint8_t w_TEST_cw;
extern __memx const uint8_t w_QUIT_cw;
extern __memx const uint8_t w_zzz_eol_1;
extern __memx const uint8_t ww_zzz_eol_2;
extern xC FORTH_WORDS_START;
extern xC FORTH_WORDS_END;
extern xC f_docol;
extern xC w_docol_cw;
extern const __memx uint32_t	val_of_w_exit_cw;
extern const __memx uint32_t	val_of_f_docol;

#define HERE_SIZE 0x300
uint8_t HERE1[HERE_SIZE];
#include <avr/pgmspace.h>


// #define F(str) ((const __attribute__((__progmem__))char*)(str))
#pragma GCC push_options
#pragma GCC optimize ("no-strict-aliasing")

static inline P24 U32_P24(uint32_t x){ return *(P24*)&x;  }
static inline uint32_t P24_U32(P24 x) { uint32_t r; __asm__ ( "clr %D0" : "=r" (r) : "0" (x)); return r; }
static inline uint32_t xpC_U32(xpC x) { uint32_t r; __asm__ ( "clr %D0" : "=r" (r) : "0" (x)); return r; }
static inline uint32_t npC_U32(npC x) { uint32_t r; __asm__ ( "clr %D0" : "=r" (r) : "0" (x)); return r; }
//static inline DOUBLE_t U32_D(uint32_t x){ return x & 0x00FFFFFFUL; }
#pragma GCC pop_options
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
TEXT uint32_t cw2name(uint32_t start) {	// {{{
	for (uint8_t i=0; i<32;i++) {
		start--;
		if(C_B1at(start) < 32) break;
	};
	return start;
}	// }}}
TEXT void C_Tracer(uint32_t DT,uint16_t IP,uint16_t RST,uint16_t DST,uint32_t TOS) {	// {{{
	uint8_t c;
	char cc;
	uint32_t a = cw2name(DT-3);
	c=C_B1at(a);
	
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
	uint32_t p;
	uint8_t len = TCB_test.WL_ORDER_len;
	for (uint8_t i=0;i<len;i++) {
		TX0_WriteStr("\r\n=== ");
		TX0_WriteHex8(i);
		TX0_WriteStr(" ===\r\n");
		p=P24_U32(TCB_test.WL_ORDER[i]);
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
		
		head= p;
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
			if (att & FLG_IMMEDIATE)	{ TX0_Write('I'); };
			if (att & FLG_HIDDEN)		{ TX0_Write('H'); };
			if (att & FLG_FOG)		{ TX0_Write('F'); };
			if (att & FLG_ADDR)		{ TX0_Write('A'); } 
			else
			switch (att & FLG_ARG_MASK) {
				case FLG_ARG_1:		{ TX0_Write('1'); };
				case FLG_ARG_2:		{ TX0_Write('2'); };
				case FLG_ARG_3:		{ TX0_Write('3'); };
				case FLG_ARG_4:		{ TX0_Write('4'); };
			};
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
TEXT void C_dump(uint32_t MEM) {	// {{{
	debug_dump (MEM,F("DEBUG"));
}	// }}}

// {{{ old FORTH
typedef uint32_t DOUBLE_t;	// 2 cell on data stack 4B
char buf[32];	// temporary buffer - stack eating structures cannot be in NEXT-chained functions, or stack will overflow !!!
DOUBLE_t cw2h(DOUBLE_t cw) {	// {{{ codeword address to head address
//TX0_WriteStr("cw2h( ");
// TX0_WriteHex24(xpC_U32(&FORTH_WORDS_START));
// TX0_Write('<');
// TX0_WriteHex24(cw);
// TX0_Write('<');
// TX0_WriteHex24( xpC_U32(&FORTH_WORDS_END));
// TX0_Write('|');
// TX0_WriteHex24(RAM(npC_U32(&HERE1[0])));
// TX0_Write('<');
// TX0_WriteHex24(cw);
// TX0_Write('<');
// TX0_WriteHex24( RAM(npC_U32(&HERE1[0]))+sizeof(HERE1) );
	if ( ! (
		( (xpC_U32(&FORTH_WORDS_START) <= cw) && ( cw < xpC_U32(&FORTH_WORDS_END)) ) ||
		( (RAM(npC_U32(&HERE1[0])) <= cw) && ( cw < RAM(npC_U32(&HERE1[0]))+sizeof(HERE1) ) )
		) ) { return 0; };
// TX0_Write('+');
	if (!cw) return 0;
// TX0_Write('+');
	uint8_t i =0;
	cw--;
	while ((i<33 ) && (i!=C_B1at(cw))) {i++;cw--;};
// TX0_Write('=');
// TX0_WriteHex8(i);
// TX0_Write(')');
	if (i<33) return cw-5;
	return 0;
}	// }}}
DOUBLE_t h2cw(DOUBLE_t h) {	// {{{ convert head address to codeword address
	h+=5;
	h+=1+C_B1at(h);
	return h;
}	// }}}
uint8_t name_to_buf(DOUBLE_t cw) {	// {{{ fill name into global buf codeword - return flags
	DOUBLE_t h=cw2h(cw);
	if (!h) {strcpy_P(buf,F(" Not a word "));return 0;};
	uint8_t flags,len;
	flags=C_B1at(h+4);
	len=C_B1at(h+5);
	uint8_t i=0;
	for (; i<len;i++) buf[i]=C_B1at(h+6+i);
	buf[i]=0;
	return flags;
}	// }}}

void C_export(uint32_t cw) {	// {{{ ; ' WORD export - try to export definition of WORD
	uint32_t val;
	uint8_t flags;
	if ( ! cw2h(cw)) { TX0_WriteStr("Not valid CW."); return;};
	TX0_Write('\r');
	TX0_Write('\n');
	TX0_Write(':');
	TX0_Write(' ');
	flags = name_to_buf(cw);
	TX0_WriteStr(buf);
	if (flags & FLG_IMMEDIATE) TX0_WriteStr(" IMMEDIATE");
	if (flags & FLG_HIDDEN) TX0_WriteStr(" ( HIDDEN )");
	if (flags & FLG_FOG) TX0_WriteStr(" ( FOG )");
	if (val_of_f_docol != C_B3at(cw)) {
		TX0_WriteStr(" NOT_DOCOL definition ");
		return;	// neumim rozepsat
		};
	cw+=3;
	do {
		val=C_B3at(cw);
		cw+=3;
		if (val == val_of_w_exit_cw) break;
		TX0_Write(' ');
		flags=name_to_buf(val);
		TX0_WriteStr(buf);
		if ( ((flags & FLG_ARG_MASK)==FLG_ARG_3) || ((flags & FLG_ADDR)==FLG_ADDR)) {
			val=C_B3at(cw);
			cw+=3;
			TX0_Write(' ');
			uint32_t h1=cw2h(val);
				if (h1) {	// it points to cw of existing word
					name_to_buf(val);
					TX0_WriteStr(buf);
					TX0_WriteStr(" ( \\'0x");
					TX0_WriteHex24(val);
					TX0_WriteStr(" )");
				} else {
					TX0_WriteStr("\\'0x");
					TX0_WriteHex24(val);
				};
			val=0;
		}
		else if ( ((flags & FLG_ARG_MASK)==FLG_ARG_4)) {
			val=C_B2at(cw);
			cw+=2;
			TX0_WriteStr(" \\'0x");
			TX0_WriteHex16(val);
			val=C_B2at(cw);
			cw+=2;
			TX0_WriteHex16(val);
			val=0;
		}
		else if ( ((flags & FLG_ARG_MASK)==FLG_ARG_2)) {
			val=C_B2at(cw);
			cw+=2;
			TX0_WriteStr(" \\'0x");
			TX0_WriteHex16(val);
			val=0;
		}
		else if ( ((flags & FLG_ARG_MASK)==FLG_ARG_1)) {
			val=C_B1at(cw);
			cw+=1;
			TX0_WriteStr(" \\'0x");
			TX0_WriteHex8(val);
			val=0;
		}
		else if ((flags & FLG_PSTRING) && (C_B3at(cw)<128)) { // too long strings probabely are not arguments
			val=C_B1at(cw);
			cw+=1;
			TX0_WriteStr(" \\'0x");
			TX0_WriteHex24(val);
			TX0_WriteStr(" \\\"");
			while (val--) TX0_WriteA(C_B1at(cw++));
			TX0_WriteStr("\"");
			val=0;
		};
	} while (1);
//	} while (val != val_of_w_exit_cw);
	TX0_WriteStr(" ;");
	TX0_Write('\r');
	TX0_Write('\n');

}	// }}}

// }}}
TEXT void setup(void) {
	usart0_setup();
	sei();
	/*
	TX0_WriteHex24(xpC_U32(&f_docol));	// vyjde to stejne obema zpusoby
	TX0_WriteHex24(val_of_f_docol);
	*/
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
	TCB_test.	LStackFirst	.ptr	= & TCB_test.LStack		[0];
	TCB_test.	LStackLast	.ptr	= & TCB_test.LStack		[LST_SIZE - 1];
	
	/*
	for (uint8_t i=0; i<DST_SIZE;++i)	TCB_test.DataStack[i] 	= u32_to_p24(P24_Canary);
	for (uint8_t i=0; i<RST_SIZE;++i)	TCB_test.ReturnStack[i]	= u32_to_p24(P24_Canary);
	for (uint8_t i=0; i<TIB_SIZE;++i)	TCB_test.TIB[i]	= 'T';
	for (uint8_t i=0; i<AIB_SIZE;++i)	TCB_test.AIB[i]	= 'A';
	for (uint8_t i=0; i<ORDER_SIZE;++i)	TCB_test.WL_ORDER[i]	= u32_to_p24(P24_Canary);
	*/
	
	for (uint8_t i=0; i<DST_SIZE;++i)	TCB_test.DataStack[i] 	= u32_to_p24(0x444444);
	for (uint8_t i=0; i<RST_SIZE;++i)	TCB_test.ReturnStack[i]	= u32_to_p24(0x525252);
	for (uint8_t i=0; i<LST_SIZE;++i)	TCB_test.LStack[i]	= u32_to_p24(0x4C4C4C);
	for (uint8_t i=0; i<TIB_SIZE;++i)	TCB_test.TIB[i]	= 'T';
	for (uint8_t i=0; i<AIB_SIZE;++i)	TCB_test.AIB[i]	= 'A';
	for (uint8_t i=0; i<ORDER_SIZE;++i)	TCB_test.WL_ORDER[i]	= u32_to_p24(0x4f4f4f);
	for (uint16_t i=0; i<HERE_SIZE;++i)	HERE1[i]	= 'H';
	
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
	TCB_test.	LST		.ptr	= & TCB_test.LStack		[LST_SIZE - 1];
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

