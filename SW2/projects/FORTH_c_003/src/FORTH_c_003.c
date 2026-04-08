/* vim: ft=cpp showbreak=--»\  noexpandtab fileencoding=utf-8 nomodified wrap textwidth=0 foldmethod=marker foldmarker={{{,}}} foldcolumn=4 ruler showcmd lcs=tab\:|- list: tabstop=8 linebreak  tags=./tags;,tags;
 * */
// ,,g = gcc, exactly one space after "set"
//
#include "FORTH_c_003.h"
#include "version.h"
// External FORTH primitives
extern void f_dup(void);
extern void run_in_FORTH_xt_in_IP(void);

#define TEXT __attribute__((section(".text")))
TEXT void write_char(char c){	// {{{
	VGA0_Write(c);
}	// }}}
TEXT void write_charA(char c){	// {{{
	VGA0_WriteA(c);
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
    VGA0_WriteStr("c_to_number(\"");
    VGA0_WriteStr(buf);
    VGA0_WriteStr("\", ");
    write_num8(base);
    VGA0_Write(')');
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
    VGA0_Write('=');
    VGA0_WriteHex24(val);
    VGA0_Write(';');
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

Thread_Controll_Block TCB_test __attribute__((section(".highram")));
extern uint8_t VGA0_WriteHex8(uint8_t h);
extern uint8_t VGA0_WriteHex16(uint16_t h);
extern uint8_t VGA0_WriteHex24(uint32_t h);


#define HERE_SIZE 0x3000
uint8_t HERE1[HERE_SIZE] __attribute__((section(".highram")));


// #define F(str) ((const __attribute__((__progmem__))char*)(str))
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
	for (uint16_t i=0;i< depth_R; i++) write_char('\t');
	write_char(' ');
	DT-=3;
	VGA0_WriteHex24(DT);
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
	for (uint16_t i=2;i< depth_D+1; i++) {
		write_char(' ');
		VGA0_WriteHex24(p24_to_u32(TCB_test.DataStack[DST_SIZE-2-i]));
	};
	write_char(':');
	VGA0_WriteHex24(TOS);
	
	write_char('\e');
	write_char('[');
	write_num8(190+1);
	write_char('G');
	write_num8(depth_R);
	write_char(' ');
	for (uint16_t i=1;i< depth_R+1; i++) {
		VGA0_WriteHex24(p24_to_u32(TCB_test.ReturnStack[RST_SIZE-1-i]));
		write_char(' ');
	};
	write_char('|');
	write_char(' ');
	VGA0_WriteHex24(IP - 3 );
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
	uint8_t page=10;
	for (uint8_t i=0;i<len;i++) {
		VGA0_WriteStr("\r\n=== ");
		VGA0_WriteHex8(i);
		VGA0_WriteStr(" ===\r\n");
		p=P24_U32(TCB_test.WL_ORDER[i]);
		/*
		VGA0_WriteHex8(p.dta.hlo);
		VGA0_WriteHex8(p.dta.hi);
		VGA0_WriteHex8(p.dta.lo);
		VGA0_Write(':');
		*/
		
		p=C_B3at(p);
		/*
		VGA0_WriteHex8(p.dta.hlo);
		VGA0_WriteHex8(p.dta.hi);
		VGA0_WriteHex8(p.dta.lo);
		VGA0_Write(':');
		*/
		
		head= p;
		uint8_t count=10;
		
		uint8_t b,b1,b2,b3,att;
		
		while (head) {
		if (! count--) { 
			count=10; VGA0_Write('\r');TX0_Write('\n');
			if (!page--) {
				char nic;
				page=10; VGA0_WriteStr("-- page --");while (GETC_OK != serial_getc(NULL, &nic)){;};
				VGA0_Write('\r');TX0_Write('\n');
				};
			};
		VGA0_Write('<');
		/*
		VGA0_WriteHex24(head);
		VGA0_Write(':');
		*/
		a=head;
		b1=C_B1at(a++);
		b2=C_B1at(a++);
		b3=C_B1at(a++);
//		head= b1+0x100UL*b2+0x10000UL*b3;
		head = (uint32_t)b1
			| ((uint32_t)b2 << 8)
			| ((uint32_t)b3 << 16);
		/*
		VGA0_WriteHex24(head);
		VGA0_Write(':');
		*/
		att=C_B1at(a++);//attrib
		if (att){
			if (att & FLG_IMMEDIATE)	{ VGA0_Write('I'); };
			if (att & FLG_HIDDEN)		{ VGA0_Write('H'); };
			if (att & FLG_FOG)		{ VGA0_Write('F'); };
			if (att & FLG_ADDR)		{ VGA0_Write('A'); }
			else
			switch (att & FLG_ARG_MASK) {
				case FLG_ARG_1:		{ VGA0_Write('1'); break;};
				case FLG_ARG_2:		{ VGA0_Write('2'); break;};
				case FLG_ARG_3:		{ VGA0_Write('3'); break;};
				case FLG_ARG_4:		{ VGA0_Write('4'); break;};
			};
			if (att & FLG_PSTRING)		{ VGA0_Write('P'); };
			VGA0_Write(':');
		};
		b=C_B1at(a++);
		if (b) for (uint8_t i=0; i<b;i++) VGA0_Write( C_B1at(a++));
		VGA0_Write('>');
		VGA0_Write(' ');
		};
	VGA0_Write('\r');
	VGA0_Write('\n');
	};
}	// }}}
TEXT void C_dump(uint32_t MEM) {	// {{{
	nodebug=false;
	debug_dump (MEM,F("DEBUG"));
}	// }}}

uint8_t serial_getc(void *state, char *out_char) {	// {{{
	(void)state;	// state UNUSED, no compiler complains
	uint16_t ch;
	uint8_t ps2_res;
	ps2_res = ps2_getc(NULL,out_char);
	if (ps2_res == GETC_OK) return GETC_OK;
	
	ch = RX0_Read();
	*out_char = (ch & 0xFF);
	return (ch >> 8)? GETC_OK:GETC_AGAIN;
}	// }}}

// {{{ old FORTH
typedef uint32_t DOUBLE_t;	// 2 cell on data stack 4B
char buf[32];	// temporary buffer - stack eating structures cannot be in NEXT-chained functions, or stack will overflow !!!
DOUBLE_t cw2h(DOUBLE_t cw) {	// {{{ codeword address to head address
//VGA0_WriteStr("cw2h( ");
// VGA0_WriteHex24(xpC_U32(&FORTH_WORDS_START));
// VGA0_Write('<');
// VGA0_WriteHex24(cw);
// VGA0_Write('<');
// VGA0_WriteHex24( xpC_U32(&FORTH_WORDS_END));
// VGA0_Write('|');
// VGA0_WriteHex24(RAM(npC_U32(&HERE1[0])));
// VGA0_Write('<');
// VGA0_WriteHex24(cw);
// VGA0_Write('<');
// VGA0_WriteHex24( RAM(npC_U32(&HERE1[0]))+sizeof(HERE1) );
	if ( ! (
		( (xpC_U32(&FORTH_WORDS_START) <= cw) && ( cw < xpC_U32(&FORTH_WORDS_END)) ) ||
		( (RAM(npC_U32(&HERE1[0])) <= cw) && ( cw < RAM(npC_U32(&HERE1[0]))+sizeof(HERE1) ) )
		) ) { return 0; };
// VGA0_Write('+');
	if (!cw) return 0;
// VGA0_Write('+');
	uint8_t i =0;
	cw--;
	while ((i<33 ) && (i!=C_B1at(cw))) {i++;cw--;};
// VGA0_Write('=');
// VGA0_WriteHex8(i);
// VGA0_Write(')');
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
	bool new;
	if ( ! cw2h(cw)) { VGA0_WriteStr("Not valid CW."); return;};
	VGA0_Write('\r');
	VGA0_Write('\n');
	VGA0_WriteStr("DEFWORD	w_");
	flags = name_to_buf(cw);
	VGA0_WriteStr(buf);
	VGA0_WriteStr(",	0");
	if (flags & FLG_IMMEDIATE) VGA0_WriteStr("+ FLG_IMMEDIATE");
	if (flags & FLG_HIDDEN) VGA0_WriteStr("+ FLG_HIDDEN");
	if (flags & FLG_FOG) VGA0_WriteStr("+ FLG_FOG");
	if ((flags & FLG_ARG_MASK) == FLG_ARG_1 ) VGA0_WriteStr("+ FLG_ARG_1");
	if ((flags & FLG_ARG_MASK) == FLG_ARG_2 ) VGA0_WriteStr("+ FLG_ARG_2");
	if ((flags & FLG_ARG_MASK) == FLG_ARG_3 ) VGA0_WriteStr("+ FLG_ARG_3");
	if ((flags & FLG_ARG_MASK) == FLG_ARG_4 ) VGA0_WriteStr("+ FLG_ARG_4");
	if (flags & FLG_PSTRING) VGA0_WriteStr("+ FLG_PSTRING");
	if (flags & FLG_ADDR) VGA0_WriteStr("+ FLG_ADDR");
	if (val_of_f_docol != C_B3at(cw)) {
		VGA0_WriteStr(" NOT_DOCOL definition ");
		return;	// neumim rozepsat
		};
	VGA0_WriteStr(",	\"");
	VGA0_WriteStr(buf);
	VGA0_WriteStr("\",	f_docol\r\n	P24s	");
	new=true;
	cw+=3;
	do {
		val=C_B3at(cw);
		cw+=3;
		if (val == val_of_w_exit_cw) break;
		if (! new) VGA0_WriteStr(", ");
		new=false;
		flags=name_to_buf(val);
		VGA0_WriteStr("w_");
		VGA0_WriteStr(buf);
		VGA0_WriteStr("_cw");
		if ( ((flags & FLG_ARG_MASK)==FLG_ARG_3) || ((flags & FLG_ADDR)==FLG_ADDR)) {
			val=C_B3at(cw);
			cw+=3;
			uint32_t h1=cw2h(val);
				if (h1) {	// it points to cw of existing word
					VGA0_WriteStr(", w_");
					name_to_buf(val);
					VGA0_WriteStr(buf);
					VGA0_WriteStr("_cw");
				} else {
					VGA0_WriteStr(", 0x");
					VGA0_WriteHex24(val);
				};
			val=0;
		}
		else if ( ((flags & FLG_ARG_MASK)==FLG_ARG_4)) {
			val=C_B2at(cw);
			cw+=2;
			VGA0_WriteStr("\r\n		.long	0x");
			VGA0_WriteHex16(val);
			val=C_B2at(cw);
			cw+=2;
			VGA0_WriteHex16(val);
			VGA0_WriteStr("\"\r\n	P24s	");
			new=true;
			val=0;
		}
		else if ( ((flags & FLG_ARG_MASK)==FLG_ARG_2)) {
			val=C_B2at(cw);
			cw+=2;
			VGA0_WriteStr("\r\n		.word	0x");
			VGA0_WriteHex16(val);
			VGA0_WriteStr("\"\r\n	P24s	");
			new=true;
			val=0;
		}
		else if ( ((flags & FLG_ARG_MASK)==FLG_ARG_1)) {
			val=C_B1at(cw);
			cw+=1;
			VGA0_WriteStr("\r\n		.byte	0x");
			VGA0_WriteHex8(val);
			VGA0_WriteStr("\"\r\n	P24s	");
			new=true;
			val=0;
		}
		else if ((flags & FLG_PSTRING) && (C_B1at(cw)<128)) { // too long strings probabely are not arguments
			val=C_B1at(cw);
			cw+=1;
			VGA0_WriteStr("\r\n		.byte	0x");
			VGA0_WriteHex8(val);
			VGA0_WriteStr("\r\n		.ascii \"");
			while (val--) VGA0_WriteA(C_B1at(cw++));
			VGA0_WriteStr("\"\r\n	P24s	");
			new=true;
			val=0;
		};
	} while (1);
//	} while (val != val_of_w_exit_cw);
	if (! new) VGA0_WriteStr(",	");
	VGA0_WriteStr(" w_exit_cw");
	VGA0_Write('\r');
	VGA0_Write('\n');

}	// }}}
void C_show(uint32_t cw) {	// {{{ ; ' WORD export - try to export definition of WORD
	uint32_t val;
	uint8_t flags;
	if ( ! cw2h(cw)) { VGA0_WriteStr("Not valid CW."); return;};
	VGA0_Write('\r');
	VGA0_Write('\n');
	VGA0_Write(':');
	VGA0_Write(' ');
	flags = name_to_buf(cw);
	VGA0_WriteStr(buf);
	if (flags & FLG_IMMEDIATE) VGA0_WriteStr(" IMMEDIATE");
	if (flags & FLG_HIDDEN) VGA0_WriteStr(" ( HIDDEN )");
	if (flags & FLG_FOG) VGA0_WriteStr(" ( FOG )");
	if ((flags & FLG_ARG_MASK) == FLG_ARG_1 ) VGA0_WriteStr(" ( FLG_ARG_1 )");
	if ((flags & FLG_ARG_MASK) == FLG_ARG_2 ) VGA0_WriteStr(" ( FLG_ARG_2 )");
	if ((flags & FLG_ARG_MASK) == FLG_ARG_3 ) VGA0_WriteStr(" ( FLG_ARG_3 )");
	if ((flags & FLG_ARG_MASK) == FLG_ARG_4 ) VGA0_WriteStr(" ( FLG_ARG_4 )");
	if (flags & FLG_PSTRING) VGA0_WriteStr(" ( FLG_PSTRING )");
	if (flags & FLG_ADDR) VGA0_WriteStr(" ( FLG_ADDR )");
	if (val_of_f_docol != C_B3at(cw)) {
		VGA0_WriteStr(" NOT_DOCOL definition ");
		return;	// neumim rozepsat
		};
	cw+=3;
	do {
		val=C_B3at(cw);
		cw+=3;
		if (val == val_of_w_exit_cw) break;
		VGA0_Write(' ');
		flags=name_to_buf(val);
		VGA0_WriteStr(buf);
		if ( ((flags & FLG_ARG_MASK)==FLG_ARG_3) || ((flags & FLG_ADDR)==FLG_ADDR)) {
			val=C_B3at(cw);
			cw+=3;
			VGA0_Write(' ');
			uint32_t h1=cw2h(val);
				if (h1) {	// it points to cw of existing word
					name_to_buf(val);
					VGA0_WriteStr(buf);
					VGA0_WriteStr(" ( $");
					VGA0_WriteHex24(val);
					VGA0_WriteStr(" )");
				} else {
					VGA0_WriteStr("$");
					VGA0_WriteHex24(val);
				};
			val=0;
		}
		else if ( ((flags & FLG_ARG_MASK)==FLG_ARG_4)) {
			val=C_B2at(cw);
			cw+=2;
			VGA0_WriteStr(" $");
			VGA0_WriteHex16(val);
			val=C_B2at(cw);
			cw+=2;
			VGA0_WriteHex16(val);
			val=0;
		}
		else if ( ((flags & FLG_ARG_MASK)==FLG_ARG_2)) {
			val=C_B2at(cw);
			cw+=2;
			VGA0_WriteStr(" $");
			VGA0_WriteHex16(val);
			val=0;
		}
		else if ( ((flags & FLG_ARG_MASK)==FLG_ARG_1)) {
			val=C_B1at(cw);
			cw+=1;
			VGA0_WriteStr(" $");
			VGA0_WriteHex8(val);
			val=0;
		}
		else if ((flags & FLG_PSTRING) && (C_B1at(cw)<128)) { // too long strings probabely are not arguments
			val=C_B1at(cw);
			cw+=1;
			VGA0_WriteStr(" $");
			VGA0_WriteHex8(val);
			VGA0_WriteStr(" \\\"");
			while (val--) VGA0_WriteA(C_B1at(cw++));
			VGA0_WriteStr("\"");
			val=0;
		};
	} while (1);
//	} while (val != val_of_w_exit_cw);
	VGA0_WriteStr(" ;");
	VGA0_Write('\r');
	VGA0_Write('\n');

}	// }}}

// }}}

// =======================vvvv VGA vvvv=============================== {{{

volatile uint32_t frames;	// increase after frame displayed
volatile bool VB_flag;		// set on start of each Vertical Blank
void VB_handler(){
	frames++;
	VB_flag=true;
}
void wait(uint32_t dt){ 
	uint32_t f; 
	f=frames;
	while (frames-f < dt) func_yield(); 
	}

T_TextVGA_VRAM VRAM;
T_TextVGA_CRAM CRAM={0x0f, 0xcf, 0xd4,0xd4,0x9f,0xf9,0xf1,0xf2,0xf3,0xf4,0xf5,0xf6,0xf6,0xf7,0xf8,0xf9,0xfa,0xfb,0xfc,0xfd,0xfe,0xff,0xf0,0xf0,0xf0,};
// =======================^^^^ VGA ^^^^=============================== }}}
uint32_t C_RANDOM(uint32_t max) { 
//	VGA0_WriteStr("RND(");
//	VGA0_WriteHex24(max);
	uint32_t r = rand() % max ; 
//	VGA0_WriteStr(")=");
//	VGA0_WriteHex24(r);
	return r;
	}
char str_buf[80];
uint32_t C_num2str(uint32_t num, Thread_Controll_Block *TCB) {
	ltoa(num,str_buf,TCB->BASE);
	uint32_t adr=(uint16_t)str_buf;
	uint32_t len=strlen(str_buf);
	return adr+ (len <<16);
	
}
// ========================vvvv setup vvvv========================================= {{{
TEXT void setup(void) {
	usart0_setup();
#ifndef NO_VGA
	DebugLEDs_init();
#endif

TextVGA_VRAM = &VRAM;
TextVGA_CRAM = &CRAM;
TextVGA_CharDef = pgm_get_far_address(StdTextCharDef);
TextVGA_CharDef = pgm_get_far_address(SnakeCharDef);
TextVGA_CharDef = pgm_get_far_address(SnakeCharDef2);
TextVGA_VerticalBlank=VB_handler;
#ifndef NO_VGA
TextVGA_begin();
#endif
char *pt=&VRAM[0][0];
for (uint8_t j =24;j<TextVGA_LINES;j++) CRAM[j]=0xf4;
CRAM[49]=0x28;
CRAM[50]=0x48;
for (uint16_t i =0;i<TextVGA_COLUMNS*TextVGA_LINES;i++) *pt++ = i & 0xff;

for (uint16_t i =0 ; i< TextVGA_LINES;i++) {
	VRAM[i][0] = '0'+(i/10);
	VRAM[i][1] = '0'+(i%10);
	};
for (uint16_t i =0 ; i< TextVGA_COLUMNS;i++) {
	VRAM[0][i] = '0'+(i/10);
	VRAM[1][i] = '0'+(i%10);
	};
	VRAM[23][2] = '0'+(TextVGA_LINES/10);
	VRAM[23][3] = '0'+(TextVGA_LINES%10);
VGA_set_cursor_XY(0,2);
char ver[] = "*** ver." VERSION_STRING " (" VERSION_MESSAGE ") ***";
for (uint8_t i=0; i<strlen(ver); i++) VGA_write_char(ver[i]);

// while (1){;};
	sei();
	/*
	VGA0_WriteHex24(xpC_U32(&f_docol));	// vyjde to stejne obema zpusoby
	VGA0_WriteHex24(val_of_f_docol);
	*/
}
// ========================^^^^ setup ^^^^========================================= }}}

TEXT void loop(void) {	// {{{
	uint16_t ch = RX0_Read();
	if (ch >> 8) { // Pokud r25 != 0
		VGA0_Write((char)(ch & 0xFF)); // Blokuje dokud není volno
		if ((ch & 0xFF)==13)
			VGA0_Write(10); // Blokuje dokud není volno
	};
//	for (int i=0;i<256;i++) ch=PORTF;
//	__asm__ __volatile__ ("jmp NEXT \n\t");
//	NEXT();
}	// }}}
static inline P16 u16_to_p16(uint16_t v)	// {{{
{
    P16 p;
    p.lo  = (uint8_t)(v & 0xFF);
    p.hi  = (uint8_t)((v >> 8) & 0xFF);
    return p;
}	// }}}
static inline uint16_t p16_to_u16(P16 p)	// {{{
{
    return  ((uint16_t)p.lo) |
            ((uint16_t)p.hi  << 8);
}	// }}}
// static
P24 WL_all;
P24 WL_all_2;
P24 WL_all_3;
P24 WL_all_4;
// input_stack_t input_stack_serial; get_STK
Virtual_Table VT_test;
// ========================vvvv main vvvv========================================== {{{
TEXT int main(void) {
	setup();
	PS2_init();
//	C_words();
	VGA0_Write('\r');
	VGA0_Write('\n');
	VGA0_Write('#');
	VGA0_Write('>');
	
//	VT_test.write_char=;
	VT_test.read_char.ptr = (__memx const void *)(uintptr_t)			ps2_getc;
	VT_test.write_char.ptr = (__memx const void *)(uintptr_t)			VGA_write_char;
	VT_test.cls.ptr = (__memx const void *)(uintptr_t)				VGA_cls;
	VT_test.set_cursor_visible.ptr = (__memx const void *)(uintptr_t)		VGA_set_cursor_visible;
	VT_test.set_cursor_char.ptr = (__memx const void *)(uintptr_t)			VGA_set_cursor_char;
	VT_test.set_cursor_X.ptr = (__memx const void *)(uintptr_t)			VGA_set_cursor_X;
	VT_test.set_cursor_Y.ptr = (__memx const void *)(uintptr_t)			VGA_set_cursor_Y;
	VT_test.set_cursor_XY.ptr = (__memx const void *)(uintptr_t)			VGA_set_cursor_XY;
	VT_test.put_char_XY.ptr = (__memx const void *)(uintptr_t)			VGA_put_char_XY;
	VT_test.set_def_color.ptr = (__memx const void *)(uintptr_t)			VGA_set_def_color;
	VT_test.set_row_color.ptr = (__memx const void *)(uintptr_t)			VGA_set_row_color;
	VT_test.set_row_color_Y.ptr = (__memx const void *)(uintptr_t)			VGA_set_row_color_Y;
	VT_test.char_at_XY.ptr = (__memx const void *)(uintptr_t)			VGA_char_at_XY;
	VT_test.MAX_LINES.ptr = (__memx const void *)(uintptr_t)			VGA_MAX_LINES;
	VT_test.MAX_COLUMNS.ptr = (__memx const void *)(uintptr_t)			VGA_MAX_COLUMNS;
	VT_test.wait.ptr = (__memx const void *)(uintptr_t)				wait;
	VT_test.cr.ptr = (__memx const void *)(uintptr_t)				VGA_cr;
	VT_test.HEADLESS.ptr = (__memx const void *)(uintptr_t)				VGA_HEADLESS;
	VT_test.HEADMORE.ptr = (__memx const void *)(uintptr_t)				VGA_HEADMORE;
	
	C_getc_init(&get_STK);
	add_getc(&get_STK, serial_getc, NULL);
	WL_all	.ptr = &w_zzz_eol_1;
	WL_all_2.ptr = &ww_zzz_eol_2;
	WL_all_3.ptr = &ww_zzz_eol_3;
	WL_all_4.ptr = &FORTH_WORDS_START;
	TCB_test.	TCB_cur 	.ptr	= & TCB_test;
	TCB_test.	DataStackFirst	.ptr	= & TCB_test.DataStack		[0];
	TCB_test.	DataStackLast	.ptr	= & TCB_test.DataStack		[DST_SIZE];
	TCB_test.	ReturnStackFirst.ptr	= & TCB_test.ReturnStack	[0];
	TCB_test.	ReturnStackLast	.ptr	= & TCB_test.ReturnStack	[RST_SIZE];
	TCB_test.	LStackFirst	.ptr	= & TCB_test.LStack		[0];
	TCB_test.	LStackLast	.ptr	= & TCB_test.LStack		[LST_SIZE];	// just AFTER range, first "st -Z, \a_hlo" will write last byte of array
	
	/*
	for (uint8_t i=0; i<DST_SIZE;++i)	TCB_test.DataStack[i] 	= u32_to_p24(P24_Canary);
	for (uint8_t i=0; i<RST_SIZE;++i)	TCB_test.ReturnStack[i]	= u32_to_p24(P24_Canary);
	for (uint8_t i=0; i<TIB_SIZE;++i)	TCB_test.TIB[i]	= 'T';
	for (uint8_t i=0; i<AIB_SIZE;++i)	TCB_test.AIB[i]	= 'A';
	for (uint8_t i=0; i<ORDER_SIZE;++i)	TCB_test.WL_ORDER[i]	= u32_to_p24(P24_Canary);
	*/
	
	for (uint8_t i=0;  i<DST_SIZE;++i)	TCB_test.DataStack[i] 	= u32_to_p24(0x444444); // 'DDD'
	for (uint8_t i=0;  i<RST_SIZE;++i)	TCB_test.ReturnStack[i]	= u32_to_p24(0x525252); // 'RRR'
	for (uint8_t i=0;  i<LST_SIZE;++i)	TCB_test.LStack[i]	= u32_to_p24(0x4C4C4C); // 'LLL'
	for (uint8_t i=0;  i<TIB_SIZE;++i)	TCB_test.TIB[i]	= 'T';
	for (uint8_t i=0;  i<AIB_SIZE;++i)	TCB_test.AIB[i]	= 'A';
	for (uint8_t i=0;  i<ORDER_SIZE;++i)	TCB_test.WL_ORDER[i]	= u32_to_p24(0x4f4f4f); // 'OOO'
	for (uint16_t i=0; i<HERE_SIZE;++i)	HERE1[i]	= 'H';
	
	// For now, just echo serial input
	TCB_test.	STATE			= F_INTERPRETING ;
	TCB_test.	BASE			= 10 ;
	TCB_test.	HERE		.ptr	= & HERE1;
	TCB_test.	TIB_len		.u16	= 0 ;
	TCB_test.	TIB_cur		.u16	= 0 ;
	TCB_test.	TIB_max		.u16	= TIB_SIZE ;
	TCB_test.	AIB_len		.u16	= 0 ;
	TCB_test.	AIB_max		.u16	= AIB_SIZE ;
	TCB_test.	AIB_cur		.u16	= 1 ;
	TCB_test.	WL_ORDER_len		= 4 ;
	TCB_test.	WL_ORDER[0]	.ptr	= & WL_all;
	TCB_test.	WL_ORDER[1]	.ptr	= & WL_all_2;
	TCB_test.	WL_ORDER[2]	.ptr	= & WL_all_3;
	TCB_test.	WL_ORDER[3]	.ptr	= & WL_all_4;
	TCB_test.	WL_CURRENT	.ptr	= & WL_all_4;
	TCB_test.	getc_ctx	.ptr	= & get_STK;
	// Set this to your word
	TCB_test.	IP		.ptr	= & w_TEST_cw;
	TCB_test.	DST			= TCB_test.DataStackLast;
	TCB_test.	RST			= TCB_test.ReturnStackLast;
	TCB_test.	LST			= TCB_test.LStackLast;
	TCB_test.	TOS			=   u32_to_p24( P24_Canary );
	TCB_test.	DT			=   u32_to_p24( P24_Canary );
	TCB_test.	VT			= & VT_test;
/*
	C2FORTH(&TCB_test, (uint32_t)(uintptr_t)&run_in_FORTH_xt_in_IP);
	VGA0_WriteHex24(p24_to_u32(TCB_test.TOS));
	VGA0_Write('\r');
	VGA0_Write('\n');
	VGA0_Write('#');
	VGA0_Write('>');
*/
	TCB_test.	IP		.ptr	= & w_QUIT_cw;
/**/	
	C2FORTH(&TCB_test, (uint32_t)(uintptr_t)&run_in_FORTH_xt_in_IP);
	VGA0_Write('\r');
	VGA0_Write('\n');
	VGA0_Write('=');
	VGA0_WriteHex24(p24_to_u32(TCB_test.TOS));
	VGA0_Write('\r');
	VGA0_Write('\n');
	VGA0_Write('$');
	VGA0_Write('>');

	/*
	TCB_test.IP=u32_to_p24((uint32_t)(uintptr_t)&w_QUIT_cw);
	C2FORTH(&TCB_test, (uint32_t)(uintptr_t)&run_in_FORTH_xt_in_IP);
	VGA0_Write('\r');
	VGA0_Write('\n');
	VGA0_Write('#');
	VGA0_Write('>');
	*/
	while (1) {
		loop();
	}
}
// ========================^^^^ main ^^^^========================================== }}}

/*	// {{{ __data_start & spol
VGA0_WriteStr("__data_start ");
VGA0_WriteHex16((uint16_t)&__data_start);
VGA0_Write('+');
VGA0_WriteHex24(&__data_end - &__data_start);
VGA0_Write('\r'); TX0_Write('\n');

VGA0_WriteStr("&__highram_start ");
VGA0_WriteHex16((uint16_t)&__highram_start);
VGA0_Write('+');
VGA0_WriteHex16(&__highram_end - &__highram_start);
VGA0_Write('\r'); TX0_Write('\n');

VGA0_WriteStr("&__bss_start ");
VGA0_WriteHex16((uint16_t)&__bss_start);
VGA0_Write('+');
VGA0_WriteHex16(&__bss_end - &__bss_start);
VGA0_Write('\r'); TX0_Write('\n');

VGA0_WriteStr("&__noinit_start ");
VGA0_WriteHex16((uint16_t)&__noinit_start);
VGA0_Write('+');
VGA0_WriteHex16(&__noinit_end - &__noinit_start);
VGA0_Write('\r'); TX0_Write('\n');

VGA0_WriteStr("&__heap_start ");
VGA0_WriteHex16((uint16_t)&__heap_start);
VGA0_Write('\r'); TX0_Write('\n');
*/	// }}}
