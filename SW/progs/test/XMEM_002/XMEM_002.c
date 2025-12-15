#include <avr/io.h>
#include <avr/interrupt.h>
#include <stdbool.h>
#include "Serial.RTS/usart0/usart0.h"
#include "DebugLEDs/DebugLEDs/DebugLEDs.h"
// LIBS: Serial.RTS/usart0 DebugLEDs/DebugLEDs
/*
*/

void XAA16(bool active){
	// XAA16
	DDRG|=_BV(3);
	if (active) { 
		PORTG|=_BV(3); 
	} else {
		PORTG&= ~_BV(3); 
	};
};
void init_XMEM(){
	XAA16(true);
	XMCRA=1 << SRE;	// automatic memory management SRE and nothing else
	XMCRB=0;
};

uint8_t res;
#define loops 0xffff
#define mem_start  0x2200L
#define mem_end   0x10000L
#define mem_size (mem_end - mem_start)
uint8_t (*mem)[] = (uint8_t (*)[]) 0;
void setup(void) {
	init_XMEM(); //init
	usart0_setup();
	sei();
	TX0_Write('*');
	TX0_Write('*');
	TX0_Write('*');
	DebugLEDs_init();
	DebugLEDs_setRGB(0,0x0,0x0,0x1);
	DebugLEDs_setRGB(1,0x0,0x1,0x0);
	DebugLEDs_setRGB(2,0x1,0x0,0x0);
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
		for (uint32_t i=mem_start; i<mem_end-5;i++ ) {
			(*mem)[i]= (i+diff) &0xff;
		};
		for (uint32_t i=mem_start; i<mem_end-5;i++ ) {
			res=(*mem)[i];
			if (((i+diff) & 0xff) != (res &0xff) ) {
				TX0_WriteStr("\r\n mismatch at ");
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

