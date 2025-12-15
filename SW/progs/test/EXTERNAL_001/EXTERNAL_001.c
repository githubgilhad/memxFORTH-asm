#include <avr/io.h>
#include <avr/interrupt.h>
#include <stdbool.h>
#include "Serial.RTS/usart0/usart0.h"
#include "DebugLEDs/DebugLEDs/DebugLEDs.h"
// LIBS: Serial.RTS/usart0 DebugLEDs/DebugLEDs
/*
char dta[100]="1234567890asdfghjkl";
int dc=20;
*/

void OE(bool enabled) { 
	DDRG |= _BV(1);
	if (enabled) {
		PORTG &= ~ _BV(1);
	} else {
		PORTG |=_BV(1);
	};
};
void WE(bool enabled){
	// Write Enable
	DDRG|=_BV(0);
	if (enabled) {
		PORTG &= ~ _BV(0); // write enabled
	} else {
		PORTG |= _BV(0); //disabled
	};
};
void A16(bool active){
	// A16
	DDRG|=_BV(3);
	if (active) { 
		PORTG|=_BV(3); 
	} else {
		PORTG&= ~_BV(3); 
	};
};
void LATCH(){
	// Latch address - pulse HIGH (to get new data) then stay LOW (keep data)
	DDRG|=_BV(2);
	PORTG|=_BV(2); 
	PORTG&= ~_BV(2); 
};
void init_external(){
	DDRA=0;
	DDRC=0xff;
	OE(false);
	WE(false);
	A16(false);
	XMCRA=0;	// no automatic memory management
	XMCRB=0;
};
void write_external(bool s16, uint16_t addr, uint8_t dta) {
	DDRA=0;
	OE(false); // not read
	WE(false);
	A16(s16);
	// address
	DDRA=0xff;
	DDRC=0xff;
	PORTA = addr & 0xff;
	PORTC = addr >> 8;
	LATCH();
	// select
	PORTA = dta;
	WE(true);
	WE(false);
	DDRA = 0;
};
uint8_t read_external(bool s16, uint16_t addr) {
	uint8_t retval;
	DDRA=0;
	OE(false); // not read
	WE(false);
	A16(s16);
	// address
	DDRA=0xff;
	DDRC=0xff;
	PORTA = addr & 0xff;
	PORTC = addr >> 8;
	LATCH();
	// select
	DDRA = 0;
	OE(true);
	retval = PINA;
	OE(false);
	DDRA = 0;
	return retval;
};
	
uint16_t mr,mt;
uint16_t zz;
uint16_t count=0;
uint8_t res;
#define loops 0xffff
void setup(void) {
	init_external(); //init
	usart0_setup();
	sei();
	TX0_Write('*');
	TX0_Write('*');
	TX0_Write('*');
	DebugLEDs_init();
	DebugLEDs_setRGB(0,0x1,0x0,0x0);
	DebugLEDs_setRGB(1,0x0,0x1,0x0);
	DebugLEDs_setRGB(2,0x0,0x0,0x1);
	DebugLEDs_setRGB(3,0x0,0x1,0x1);
	DebugLEDs_setRGB(4,0x1,0x0,0x1);
	DebugLEDs_setRGB(5,0x1,0x1,0x0);
	DebugLEDs_show();
	TX0_Write('#');
	TX0_Write('#');
	TX0_Write('#');
	for (uint8_t diff=0; diff<0xFF;diff ++) {
		TX0_WriteStr("\r\n DIFF: ");
		TX0_WriteHex8(diff);
		for (uint8_t s16=0;s16<2;s16++) {
			if (s16) TX0_Write('H'); else TX0_Write('L');
			for (uint32_t i=0; i<=loops;i++ ) {
				write_external(s16,i,(i+diff) &0xff);
			};
			for (uint32_t i=0; i<=loops;i++ ) {
				res=read_external(s16,i);
				if (((i+diff) & 0xff) != (res &0xff) ) {
					TX0_WriteStr("\r\n mismatch at ");
					if (s16) TX0_Write('H'); else TX0_Write('L');
					TX0_WriteHex16(i);
					TX0_WriteStr(" ( ");
					TX0_WriteBin8(i >>8);
					TX0_WriteBin8(i &0xff);
					TX0_WriteStr(" ) was ");
					TX0_WriteHex8(i+diff);
					TX0_WriteStr(" ( ");
					TX0_WriteBin8(i+diff);
					TX0_WriteStr(") is ");
					TX0_WriteHex8(res);
					TX0_WriteStr(" ( ");
					TX0_WriteBin8(res);
					TX0_WriteStr(" ) ");
					TX0_WriteBin8(res ^ (i+diff));
					TX0_WriteStr(" - ");
					TX0_WriteBin8((res-diff) ^ (i));
				};
			};
		};
	};
	TX0_WriteStr("\r\n Test end \r\n");
}
void loop(void) {

}

int main(void) {
	setup();
	while (1) {
		loop();
	}
}

