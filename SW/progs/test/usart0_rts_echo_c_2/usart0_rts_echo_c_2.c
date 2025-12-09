#include <avr/io.h>
#include <avr/interrupt.h>
#include "Serial.RTS/usart0/usart0.h"
// LIBS: Serial.RTS/usart0
/*
char dta[100]="1234567890asdfghjkl";
int dc=20;
*/
uint16_t zz;
void setup(void) {
	usart0_setup();
	DDRF = 0xFF;
	DDRK = 0xFF;
	sei();
	TX0_Write('#');
	TX0_Write('#');
	TX0_Write('#');
}

void loop(void) {
	uint8_t rx_avail = RX0_Available();
	PORTK = rx_avail;

	uint8_t tx_used = TX0_Used();
	PORTF = tx_used;
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
	};
//	for (int i=0;i<8*256;i++) zz+=PORTF;

}

int main(void) {
	setup();
	while (1) {
		loop();
	}
}

