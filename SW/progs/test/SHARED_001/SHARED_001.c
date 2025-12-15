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

void CS(bool enabled) { 
	DDRG |= _BV(5);
	if (enabled) {
		PORTG &= ~ _BV(5);
	} else {
		PORTG |=_BV(5);
	};
};
void OE(bool enabled) { 
	DDRD |= _BV(7);
	if (enabled) {
		PORTD &= ~ _BV(7);
	} else {
		PORTD |=_BV(7);
	};
};
void WE(bool enabled){
	// Write Enable
	DDRE|=_BV(5);
	if (enabled) {
		PORTE &= ~ _BV(5); // write enabled
	} else {
		PORTE |= _BV(5); //disabled
	};
};
void A16(bool active){
	// A16
	DDRE|=_BV(3);
	if (active) { 
		PORTE|=_BV(3); 
	} else {
		PORTE&= ~_BV(3); 
	};
};

void write_shared(bool s16, uint16_t addr, uint8_t dta) {
	DDRL=0;
	OE(false); // not read
	WE(false);
	A16(s16);
	// address
	DDRK=0xff;
	DDRJ=0xff;
	PORTJ = addr & 0xff;
	PORTK = addr >> 8;
	// select
	CS(true);
	DDRL=0xFF;
	PORTL=dta;
	WE(true);
	PORTL=dta;
	WE(false);
	DDRL=0;
	CS(false);
};
uint8_t read_shared(bool s16, uint16_t addr) {
	uint8_t retval;
	DDRL=0;
	OE(false); // not read
	WE(false);
	A16(s16);
	// address
	DDRK=0xff;
	DDRJ=0xff;
	PORTJ = addr & 0xff;
	PORTK = addr >> 8;
	// select
	CS(true);
	OE(true);
	retval=PINL;
	OE(false);
	CS(false);
	return retval;
};
	
uint16_t mr,mt;
uint16_t zz;
uint16_t count=0;
uint8_t res;
#define loops 0xffff
void setup(void) {
	read_shared(0,0); //init
	usart0_setup();
	sei();
	TX0_Write('*');
	TX0_Write('*');
	TX0_Write('*');
	DebugLEDs_init();
	DebugLEDs_setRGB(0,0x1,0x1,0x1);
	DebugLEDs_setRGB(1,0x1,0x1,0x1);
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
				write_shared(s16,i,(i+diff) &0xff);
			};
			for (uint32_t i=0; i<=loops;i++ ) {
				res=read_shared(s16,i);
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

