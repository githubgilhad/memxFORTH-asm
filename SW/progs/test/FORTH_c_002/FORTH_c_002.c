#include <avr/io.h>
#include <avr/interrupt.h>
// LIBS: Serial.RTS/usart0 FORTH/FORTH-Engine FORTH/FORTH-Memory

#include "Serial.RTS/usart0/usart0.h"
#include "FORTH/FORTH-Engine/FORTH-Engine.h"

#define TEXT __attribute__((section(".text")))

TEXT void setup(void) {
	usart0_setup();
	DDRF = 0xFF;
	DDRK = 0xFF;
	sei();
}

TEXT void loop(void) {
	uint8_t rx_avail = RX0_Available();
	PORTK = rx_avail;

	uint8_t tx_used = TX0_Used();
	PORTF = tx_used;

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

TEXT int main(void) {
	setup();
	while (1) {
		loop();
	}
}

