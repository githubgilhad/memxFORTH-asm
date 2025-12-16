#include <avr/io.h>
#include <avr/interrupt.h>
#include <stdbool.h>
#include "Serial.RTS/usart0/usart0.h"
#include "DebugLEDs/DebugLEDs/DebugLEDs.h"
// test
//#include "bios/bios/bios.h"
// LIBS: Serial.RTS/usart0 DebugLEDs/DebugLEDs 
// bios/VGA bios/bios
/*
*/

volatile uint32_t vline;
ISR(TIMER3_OVF_vect) {
//	if ( BIOS::current_output == BIOS_VGA) {	// {{{ timer3 overflow interrupt resets vline counter at HSYNC
		vline = 0;
//		BIOS::frames++;
//		memchck();
//	} 						// }}}

}
ISR(TIMER1_OVF_vect) {
if (vline++ <200) return;
if (vline >400) return;
PORTF=0x5A;
asm volatile(
	"lds r20, 0x0084 \n\t"
	"andi r20, 0x07 \n\t"
	"cpi r20, 0x07 \n\t"
	"brcs .+0 \n\t"
	"cpi r20, 0x06 \n\t"
	"brcs .+0 \n\t"
	"cpi r20, 0x05 \n\t"
	"brcs .+0 \n\t"
	"cpi r20, 0x04 \n\t"
	"brcs .+0 \n\t"
	"cpi r20, 0x03 \n\t"
	"brcs .+0 \n\t"
	"cpi r20, 0x02 \n\t"
	"brcs .+0 \n\t"
	"cpi r20, 0x01 \n\t"
	"brcs .+0 \n\t"

);
uint32_t x;
for (uint32_t i=0;i<15;i++) x=PINH;
		DDRD |= _BV(2);
		PORTD &= ~ _BV(2);	// VGA Enable (active low)
/*
PORTB &= ~ _BV(7); // load data 
PORTF=0x5A;
PORTB |= _BV(7); // shift data
*/
#define show \
PORTB &= ~ _BV(7); \
PORTF=0x5A;\
PORTB |= _BV(7);\
PORTF=0x5A;\
PORTF=0x5A;\
PORTF=0x5A;\
PORTF=0x5A;\
PORTF=0x5A;\
PORTF=0x5A;\
PORTF=0x5A;\
PORTF=0x5A;

PORTF=0xA5;
PORTH=0xf0;
show
PORTH=0x10;
show;
PORTH=0x20;
show;
PORTH=0x40;
show;
PORTH=0x80;
show;
PORTH=0x11;
show;
PORTH=0x22;
show;
PORTH=0x44;
show;
PORTH=0x88;
show;
PORTH=0x01;
show;
PORTH=0x02;
show;
PORTH=0x04;
show;
PORTH=0x08;
show;
PORTH=x;
PORTH=0;
PORTF=0;
		DDRD |= _BV(2);
		PORTD |=  _BV(2);	// VGA Enable (active low)
};


uint8_t res;
#define loops 0xffff
#define mem_start  0x2200L
#define mem_end   0x10000L
#define mem_size (mem_end - mem_start)
uint8_t (*mem)[] = (uint8_t (*)[]) 0;
void setup(void) {
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
	TX0_WriteStr("\r\nInitilizing VGA\r\n.....");
//	while (! RX0_Available()){};
	TX0_WriteStr("\r\n GO\r\n");
	TX0_WriteStr("\r\n GO\r\n");
	TX0_WriteStr("\r\n GO\r\n");
	TX0_WriteStr("\r\n GO\r\n");
	TX0_WriteStr("\r\n GO\r\n");
	TX0_WriteStr("\r\n GO\r\n");
	TX0_WriteStr("\r\n GO\r\n");
	TX0_WriteStr("\r\n GO\r\n");
	TX0_WriteStr("\r\n GO\r\n");
	TX0_WriteStr("\r\n GO\r\n");
	TX0_WriteStr("\r\n GO\r\n");
	TX0_WriteStr("\r\n GO\r\n");
	TX0_WriteStr("\r\n GO\r\n");
	TX0_WriteStr("\r\n GO\r\n");
	TX0_WriteStr("\r\n GO\r\n");
	TX0_WriteStr("\r\n GO\r\n");
// bios.setup();
	cli();	// disable interrupts before messing around with timer registers
		DDRE |= _BV(7) | _BV(4) |_BV(2) ;	// 16MHz | Vsync | ! INSIDE | PS2-OE
//		DDRE = 0xff ;	// test, everything
		PORTE |=  _BV(2); // PS2-OE not enabled by default
		DDRB |= _BV(6) | _BV(7) ;		// Hsync | Latch 
		DDRF	= 0xFF;		// PF[0..7] for data out
			PORTF=0;
		DDRH	= 0xFF;		// PH[0..7] for colors out
			PORTH=0;
		DDRD |= _BV(2);
		PORTD &= ~ _BV(2);	// VGA Enable (active low)
		// timers
		GTCCR= (1<<TSM) | (1<<PSRASY) | (1 <<PSRSYNC); // stop Timers 0,1,3,4,5 for synchronisation pg. 166:
			/* Bit 7 - TSM: Timer/Counter Synchronization Mode
			Writing the TSM bit to one activates the Timer/Counter Synchronization mode. In this mode, the value that is writ-
			ten to the PSRASY and PSRSYNC bits is kept, hence keeping the corresponding prescaler reset signals asserted.
			This ensures that the corresponding Timer/Counters are halted and can be configured to the same value without
			the risk of one of them advancing during configuration. When the TSM bit is written to zero, the PSRASY and
			PSRSYNC bits are cleared by hardware, and the Timer/Counters start counting simultaneously.
			
			Bit 0  PSRSYNC: Prescaler Reset for Synchronous Timer/Counters
			When this bit is one, Timer/Counter0, Timer/Counter1, Timer/Counter3, Timer/Counter4 and Timer/Counter5 pres-
			caler will be Reset. This bit is normally cleared immediately by hardware, except if the TSM bit is set. Note that
			Timer/Counter0, Timer/Counter1, Timer/Counter3, Timer/Counter4 and Timer/Counter5 share the same prescaler
			and a reset of this prescaler will affect all timers.
			*/

		// *****************************
		// ***** Timer1: VGA HSYNC ***** PB[6] D12
		// *****************************
// Nastavit timer do režimu Fast PWM s TOP = ICR1
TCNT1=0;
TCCR1A = (1 << COM1B1) | (1 << COM1B0) | (1 << WGM11); // COM1B = 0b11, WGM11=1
TCCR1B = (1 << WGM13) | (1 << WGM12) | (1 << CS10);     // WGM13:2 = 1110 => Fast PWM ICR1 top, prescaler 1

ICR1 = 511;     // perioda = 512 ticků (32 µs)
// OCR1B = 15;     // výstup LOW prvních 1 µs
OCR1B = 60;   // 61 ticků LOW ≈ 3.8 µs

// Povolení přerušení na konci periody
TIMSK1 = (1 << TOIE1); 
// F_CPU  16 MHz - 1 tick = 62,5 ns
//
// For period 32 µs potřebu
// 32 μs / 62,5 ns = 512 ticks
// 61 ticks LOW ≈ 3.8 µs


// ISR timer overflow
// ISR(TIMER1_OVF_vect) {}
// Tady se vykoná obsluha po každých 32 µs

		// *****************************
		// ***** Timer3: VGA VSYNC ***** PE[4] D2
		// *****************************
//	// Mode: Fast PWM, TOP=ICR3, Set on Compare, Clear on Bottom
	TCCR3A = (1 << COM3B1) | (1 << COM3B0) | (1 << WGM31); 
	TCCR3B = (1 << WGM33) | (1 << WGM32) | (1 << CS32) | (1 << CS30); // prescaler 1024


	ICR3 = 259;   // period = 130 ticks	// // 60cols (24MHz): 389, 40cols (16MHz): 259, compare match register A (TOP) -> 16.64ms
	OCR3B = 0;    // LOW = 1 tick = 64 µs

	TIMSK3 = (1 << TOIE3);	// enable timer overflow interrupt setting vlines = 0

// Fast PWM mode 14: TOP = ICR3, Clear on BOTTOM, Set on Compare Match
//	TCNT3=0;
//	TCCR3A = (1 << COM3B1) | (1 << COM3B0) | (1 << WGM31); 
//	TCCR3B = (1 << WGM33) | (1 << WGM32) | (1 << CS32);  // prescaler = 256
//	
//	ICR3 = 1039;  // perioda = 16640 µs
//	OCR3B = 3;   // LOW = 4 ticks = 64 µs

		GTCCR = 0;	// clear TSM => all timers start synchronously
		UCSR1B = 0;	// brute-force the USART1 off just in case... ??

		sei();
////////////////////////////////////////////////////////////////////////////////
DDRD |= _BV(0);
PORTD &= ~ _BV(0);  // I2C led on
	/*
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
	*/
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

