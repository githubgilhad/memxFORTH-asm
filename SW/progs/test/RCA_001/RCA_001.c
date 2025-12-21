#include <avr/io.h>
#include <avr/interrupt.h>
#include <stdbool.h>
#include "Serial.RTS/usart0/usart0.h"
#include "DebugLEDs/DebugLEDs/DebugLEDs.h"
// #include "bios/TextRCA/TextRCA.h"
#include "bios/StdTextCharDef/StdTextCharDef.h"
// test
//#include "bios/bios/bios.h"
// LIBS: Serial.RTS/usart0 DebugLEDs/DebugLEDs  bios/StdTextCharDef
//  bios/TextRCA 
/*
*/


isr_handler TIMER1_OVF_vect_handler;
ISR(TIMER1_OVF_vect) { if (TIMER1_OVF_vect_handler) TIMER1_OVF_vect_handler(); }

// RCA VSync:
isr_handler TIMER3_OVF_vect_handler;
ISR(TIMER3_OVF_vect) { if (TIMER3_OVF_vect_handler) TIMER3_OVF_vect_handler(); }
// if (vline++ <200) return;
// if (vline >400) return;



// volatile uint32_t vline;
//	if ( BIOS::current_output == BIOS_RCA) {	// {{{ timer3 overflow interrupt resets vline counter at HSYNC
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

T_TextRCA_VRAM VRAM;

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
TextRCA_VRAM = &VRAM;
TextRCA_CharDef = pgm_get_far_address(StdTextCharDef);
TIMER1_OVF_vect_handler=TextRCA_TIMER1_OVF_vect_handler;
TIMER3_OVF_vect_handler=TextRCA_TIMER3_OVF_vect_handler;
TextRCA_VerticalBlank=VB_handler;
TextRCA_begin();
/*
		DDRD |= _BV(2);
		PORTD &= ~ _BV(2);	// RCA Enable (active low)
		DDRD |= _BV(2);
		PORTD |=  _BV(2);	// RCA Disable (active low)
*/
char *pt=&VRAM[0][0];
for (uint16_t i =0;i<TextRCA_ROWS*TextRCA_LINES;i++) *pt++ = i & 0xff;
//VRAM[2][0]='A';
//VRAM[2][1]='A';
//VRAM[2][2]='A';
//VRAM[2][3]='B';
//VRAM[2][4]='B';
//VRAM[2][5]='B';
//for (uint8_t j =0;j<4;j++) 
//		VRAM[0][j]=j;
// TextRCA_end();

	TX0_WriteStr("\r\nInitilizing RCA\r\n.....");
//	while (! RX0_Available()){};
	TX0_WriteStr("\r\n GO\r\n");
////////////////////////////////////////////////////////////////////////////////
DDRD |= _BV(0);
PORTD &= ~ _BV(0);  // I2C led on
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

