#ifndef USART0_H
#define USART0_H
void usart0_setup();
uint16_t RX0_Read();		// r24 = character (or 0), r25 = 0 if no char available, buf_used+1 otherwise
uint8_t TX0_Write(char c);	// c=char to write, r24=buf_used. BLOCKS if buffer full
uint8_t RX0_available();	// available chars in RX buffer
uint8_t TX0_used();		// used space in TX buffer
uint8_t TX0_free();		// available space in TX buffer
void USART0_RX_ISR();
void USART0_UDRE_ISR();

#endif
