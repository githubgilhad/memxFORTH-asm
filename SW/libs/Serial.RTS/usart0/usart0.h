#ifndef USART0_H
#define USART0_H
void usart0_setup();
uint16_t RX0_Read();		// r24 = character (or 0), r25 = 0 if no char available, buf_used+1 otherwise
uint8_t TX0_Write(char c);	// c=char to write, r24=buf_used. BLOCKS if buffer full
uint8_t RX0_Available();	// available chars in RX buffer
uint8_t TX0_Used();		// used space in TX buffer
uint8_t TX0_Free();		// available space in TX buffer

// not needed here, gcc automagically links __vector_xx on the right places (starting with __vector_00 for RESET)
void __vector_26();
void USART0_RX_ISR();
void __vector_27();
void USART0_UDRE_ISR();

#endif
