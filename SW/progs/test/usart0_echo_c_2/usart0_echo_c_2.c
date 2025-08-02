#include <avr/io.h>
#include <avr/interrupt.h>
#include "Serial/usart0/usart0.h"
// LIBS: Serial/usart0


void setup(void) {
	usart0_setup();
	DDRF = 0xFF;
	DDRK = 0xFF;
	sei();
}

void loop(void) {
	uint8_t rx_avail = RX0_Available();
	PORTK = rx_avail;

	uint8_t tx_used = TX0_Used();
	PORTF = tx_used;

	uint16_t ch = RX0_Read();
	if (ch >> 8) { // Pokud r25 != 0
		TX0_Write((char)(ch & 0xFF)); // Blokuje dokud není volno
	}
}

int main(void) {
	setup();
	while (1) {
		loop();
	}
}

