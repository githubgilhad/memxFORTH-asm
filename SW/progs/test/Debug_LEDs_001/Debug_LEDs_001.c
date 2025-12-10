#include <avr/io.h>
#include <avr/interrupt.h>
#include "Serial.RTS/usart0/usart0.h"
#include "DebugLEDs/DebugLEDs/DebugLEDs.h"
// LIBS: Serial.RTS/usart0 DebugLEDs/DebugLEDs
/*
char dta[100]="1234567890asdfghjkl";
int dc=20;
*/

uint16_t mr,mt;
uint16_t zz;
uint16_t count=0;
void setup(void) {
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
}
char hexa[]="0123456789ABCDEFG";
void loop(void) {
	uint8_t rx_avail = RX0_Available();

	uint8_t tx_used = TX0_Used();
	if (mt<tx_used) mt=tx_used;
	if (mr<rx_avail)mr=rx_avail;
	/*
	if (rx_avail) dta[dc++] = RX0_Read() & 0xFF;
	if (dc>10) {
		for (int i=0;i<dc;i++) TX0_Write(dta[i]);
		dc=0;
		};
	*/
	uint16_t ch = RX0_Read();
	if (ch >> 8) { // Pokud r25 != 0
		TX0_Write((char)(ch & 0xFF)); // Blokuje dokud není volno
		if ((ch & 0xFF)==10)
			TX0_Write(13); // Blokuje dokud není volno
		if ((ch & 0xFF)==13)
			TX0_Write(10); // Blokuje dokud není volno
		
//		TX0_Write(' ');
//		TX0_Write((ch & 0xFF));
//		TX0_Write('<');
//		TX0_Write('1');
//		TX0_Write('>');
		if ( ! ( (count++) &0xFF) ) {
			if (rx_avail) rx_avail--;
			DebugLEDs_setRGB(0,1,1,tx_used);
			DebugLEDs_setRGB(1,1,rx_avail,1);
			DebugLEDs_show();
		};
		if ( ! count){
			TX0_Write('(');
			TX0_Write(hexa[ (mr >>12) &0xf]);
			TX0_Write(hexa[ (mr >>8) &0xf]);
			TX0_Write(hexa[ (mr >>4) &0xf]);
			TX0_Write(hexa[ (mr ) &0xf]);
			TX0_Write('/');
			TX0_Write(hexa[ (mt >>12) &0xf]);
			TX0_Write(hexa[ (mt >>8) &0xf]);
			TX0_Write(hexa[ (mt >>4) &0xf]);
			TX0_Write(hexa[ (mt ) &0xf]);
			TX0_Write(')');
		};
	};
//	for (int i=0;i<8*256;i++) zz+=PORTF;

}

int main(void) {
	setup();
	while (1) {
		loop();
	}
}

