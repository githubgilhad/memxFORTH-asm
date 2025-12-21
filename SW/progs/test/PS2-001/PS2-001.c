#include <avr/io.h>
#include <avr/interrupt.h>
#include <stdbool.h>
#include "Serial.RTS/usart0/usart0.h"
#include "DebugLEDs/DebugLEDs/DebugLEDs.h"
#include "bios/TextVGA/TextVGA.h"
#include "bios/StdTextCharDef/StdTextCharDef.h"
// test
//#include "bios/bios/bios.h"
// LIBS: Serial.RTS/usart0 DebugLEDs/DebugLEDs bios/TextVGA bios/StdTextCharDef
/*
*/

bool inside, oldinside;
/*
pg.111
EICRB – External Interrupt Control Register B
• Bits 7:0 – ISC71, ISC70 - ISC41, ISC40: External Interrupt 7 - 4 Sense Control Bits
The External Interrupts 7 - 4 are activated by the external pins INT7:4 if the SREG I-flag and the corresponding
interrupt mask in the EIMSK is set. The level and edges on the external pins that activate the interrupts are defined
in Table 15-3. The value on the INT7:4 pins are sampled before detecting edges. If edge or toggle interrupt is
selected, pulses that last longer than one clock period will generate an interrupt. Shorter pulses are not guaranteed
to generate an interrupt. Observe that CPU clock frequency can be lower than the XTAL frequency if the XTAL
divider is enabled. If low level interrupt is selected, the low level must be held until the completion of the currently
executing instruction to generate an interrupt. If enabled, a level triggered interrupt will generate an interrupt
request as long as the pin is held low.
Table 15-3.
ISCn? Description
 1 0
 0 0 The low level of INTn generates an interrupt request
 0 1 Any logical change on INTn generates an interrupt request
 1 0 The falling edge between two samples of INTn generates an interrupt request
 1 1 The rising edge between two samples of INTn generates an interrupt request
Note:
15.2.3
Interrupt Sense Control(1)
1. n = 7, 6, 5 or 4.
When changing the ISCn1/ISCn0 bits, the interrupt must be disabled by clearing its Interrupt Enable bit in the
EIMSK Register. Otherwise an interrupt can occur when the bits are changed.
EIMSK – External Interrupt Mask Register
EIMSK
• Bits 7:0 – INT7:0: External Interrupt Request 7 - 0 Enable
When an INT7:0 bit is written to one and the I-bit in the Status Register (SREG) is set (one), the corresponding
external pin interrupt is enabled. The Interrupt Sense Control bits in the External Interrupt Control Registers –
EICRA and EICRB – defines whether the external interrupt is activated on rising or falling edge or level sensed.
Activity on any of these pins will trigger an interrupt request even if the pin is enabled as an output. This provides a
way of generating a software interrupt.
*/



void PS2_init(void)
{
    // PE6 as INPUT
    DDRE &= ~(1 << DDE6);

    // maybe with pullup 
    PORTE |= (1 << PORTE6);

    // disable  INT6 
    EIMSK &= ~ (1 << INT6);
    // INT6: falling edge
    EICRB &= ~((1 << ISC60));   // ISC60 = 0
    EICRB |=  (1 << ISC61);    // ISC61 = 1

    // clear eventual pending flag */
    EIFR |= (1 << INTF6);

    // enable INT6
    EIMSK |= (1 << INT6);

    // enable interrupt when convenient
    sei();
}



ISR(INT6_vect)
{
   DDRF=0;
   // PS2-OE = PE2 - enable output, read, disable
   DDRE |= _BV(2);
   PORTE &= ~ _BV(2); // LOW
   // nop
   uint8_t key;
    key=PINF;
    key=PINF;
    key=PINF;	// with 1k  resistors it seems, that we need 2clocks to stabilise and we can read in 3. clock stable value.
   PORTE |= _BV(2); //high
   DDRF=0xff;
   PORTF=~key;
   
   TX0_WriteStr(" [0x");
   TX0_WriteHex8(key);
   TX0_WriteStr("] ");
   

}


isr_handler TIMER1_OVF_vect_handler;
ISR(TIMER1_OVF_vect) { if (TIMER1_OVF_vect_handler) TIMER1_OVF_vect_handler(); }

// VGA VSync:
isr_handler TIMER3_OVF_vect_handler;
ISR(TIMER3_OVF_vect) { if (TIMER3_OVF_vect_handler) TIMER3_OVF_vect_handler(); }
// if (vline++ <200) return;
// if (vline >400) return;



// volatile uint32_t vline;
//	if ( BIOS::current_output == BIOS_VGA) {	// {{{ timer3 overflow interrupt resets vline counter at HSYNC
//		vline = 0;
//		BIOS::frames++;
//		memchck();
//	} 						// }}}

volatile uint32_t frames;	// increase after frame displayed
volatile bool VB_flag;		// set on start of each Vertical Blank
void VB_handler(){
	frames++;
	VB_flag=true;
}

T_TextVGA_VRAM VRAM;
T_TextVGA_CRAM CRAM={0xf0, 0x0f, 0x24,0x42,0x9f,0xf9,0xf1,0xf2,0xf3,0xf4,0xf5,0xf6,0xf6,0xf7,0xf8,0xf9,0xfa,0xfb,0xfc,0xfd,0xfe,0xff,0xf0,0xf0,0xf0,};

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
//	while (! RX0_Available()){};
	TX0_WriteStr("\r\n PS/2 keyboard test\r\n");
	PS2_init();
////////////////////////////////////////////////////////////////////////////////
DDRD |= _BV(0);
PORTD &= ~ _BV(0);  // I2C led on
//	TX0_WriteStr("\r\n Test end \r\n");
}



void loop(void) {

}

int main(void) {
	setup();
	while (1) {
		loop();
	}
}

