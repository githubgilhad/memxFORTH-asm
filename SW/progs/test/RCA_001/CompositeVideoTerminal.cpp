#include <avr/interrupt.h>
#include "MHF-002/MHF-002/MHF-002.h"
// LIBS: MHF-002/MHF-002

/*
 * UnoCompositeVideo.cpp
 *
 * Created: 13/12/2020 12:16:54
 * Author : ceptimus
 */ 

#include "CompositeVideoTerminal.h"
#include "font.h"

#define PIN_A 3
#define PIN_B 4
#define PIN_SUPPRESS 5
#define PIN_SYNC 9

extern "C" { void outputChars(uint8_t *pScreenRam, const uint8_t *fontSlice, uint16_t tcnt, uint16_t minTCNT); }

uint8_t screenRam[BYTES_PER_RASTER * CHARACTER_ROWS + 1] = // the + 1 is for the terminating /0 of the string, but isn't used
"     ceptimus Arduino UNO video terminal.     "
"                                              "
"       First working in December 2020         "
"                                              "
"Ozi Teknoloji asked about this on YouTube,    " 
"so I thought I'd make this extra video with a "
"schematic diagram and a brief explanation.    "
"                                              "
" It can display RVS characters besides normal "
" ones.                                        "
"                                              "
" This little monitor in standard settings can "
" display 29 rows with 46 characters per row.  "
" Some monitors, with adjustable overscan, have"
" room for extra rows.                         "
"                                              "
"The sketch uses the serial port to clock out  "
"the pixels, and requires tight code written in"
"assembly language to keep the serial port fed "
"with bytes at the right moments.  The video   "
"sync pulses are easier to produce and mostly  "
"handled by timer 1, without much effort from  "
"the processor.                                "
"                                              "
"It's also best to stop Timer 0, which runs the"
"Arduino millis() timer, for a steadier display"
"but you could still do something similar to   "
"millis() by counting the video frames or      "
"rasters from Timer 1.                         ";

volatile uint16_t scanline = 0; // counts 0 - 311 (312 scan lines per frame)
ISR(TIMER1_OVF_vect) { // TIMER1_OVF vector occurs at the start of each scan line's sync pulse
	if (++scanline == 312) {
		OCR1A = 948; // scan lines 0 - 7 have wide 59.3us sync pulses
		scanline = 0;
		} else if (scanline == 8) {
		OCR1A = 74; // swap to short 4.7us sync pulses for scan lines 8 - 311
		// asm("SBI 3, 5"); // toggle LED_BUILTIN
		// enabling the interrupt generates an immediate 'stored up' interrupt
		// so enable it one scan line early, test and return within interrupt handler to ignore 1st one
		}	else if (scanline == TOP_EDGE) { // scan line 51 is first 'text safe' scan line - will already have been incremented to 52 here
		TIMSK1 |= _BV(OCIE1B);
	}
}

volatile uint16_t minTCNT = 0xFFFF;
volatile uint16_t maxTCNT = 0;

ISR(TIMER1_COMPB_vect) { // occurs at start of 'text safe' area of scan lines 51 - 280
	static uint8_t *pScreenRam;
	static const uint8_t *fontSlice;
	static uint8_t slice;
	
	uint16_t tcnt = TCNT1; // capture timer to allow jitter correction
	
	if (scanline == TOP_EDGE) { // on stored-up 'false trigger' scanline, initialize the pointers
		slice = 0;
		pScreenRam = screenRam; // point to first character (top left) in screenRam
		fontSlice = font; // point to slice before first (top) slice of font pixels (top pixel of each 10 is just RVS cap)
		} else {
		outputChars(pScreenRam, fontSlice, tcnt, minTCNT);
		if (tcnt > maxTCNT) maxTCNT = tcnt;
		if (tcnt < minTCNT) minTCNT = tcnt;

		if (scanline == BOTTOM_EDGE) {
			TIMSK1 &= ~_BV(OCIE1B); // we don't want any more COMPB interrupts this frame
			} else if (++slice == PIXELS_PER_CHARACTER) {
			slice = 0;
			fontSlice = font;
			pScreenRam += BYTES_PER_RASTER;
			} else {
			fontSlice += 128;
		}
	}
}

void setup() {
  for (int i = 8 * BYTES_PER_RASTER; i < 10 * BYTES_PER_RASTER; ++i) {
    screenRam[i] |= 0x80;  // make the characters on rows 8 and 9 RVS field
  }
	Cset_input(RCA_SUPPRESS);
	Cout_lo(RCA_SUPPRESS); // prime pixel suppressor - when Pin is switched to output, it will force BLACK

//	pinMode(PIN_A, INPUT_PULLUP);
//	pinMode(PIN_B, INPUT_PULLUP);
		
	// configure USART as master SPI mode 0, MSB first, 8MHz
	UCSR0A = _BV(U2X0); // double speed
	UCSR0B = _BV(TXEN0);
	UCSR0C = _BV(UMSEL01) | _BV(UMSEL00);
	UBRR0L = UBRR0H = 0x00; // fastest possible baud

	// output pin for sync pulses - low 4.7 us pulses at start of visible scan lines;  longer low pulses for vertical blank
	Cout_hi(RCA_SYNC);
	Cset_output(RCA_SYNC);

	// configure timer/counter 1 to output scanline sync pulses on Pin9 (OC1A)
	// use mode 7 (fast PWM 10-bit count to TOP=1023) at 16MHz fclk - one cycle per 64us scanline
	cli(); // not necessary
	TCCR1A =  _BV(COM1A1) | _BV(COM1A0) | _BV(WGM11) | _BV(WGM10); // set OC1A output on compare match, (mode 3 so far)
	TCCR1B = _BV(WGM12) | _BV(CS10); // now mode 7 at clk/1 (16MHz)
	OCR1A = 948; // 59.3us wide sync pulse for first 8 scan lines
	OCR1B = LEFT_EDGE;
	TIMSK1 = _BV(TOIE1); // _BV(OCIE1A);
	TCNT1 = 0x0000;
	sei(); // necessary
  TIMSK0 &= ~_BV(TOIE0); // disable timer0 - stops millis() working but necessary to stop timer 0 interrupts spoiling display timing
}

uint32_t loopCounter = 0UL; // bump this each loop, and display on the terminal to show that the Arduino still has *some* processing time!
void loop() {
  ++loopCounter;
  uint8_t buffer[11] = "0000000000"; // for displaying current loopCounter value in ASCII (max value 2^32 - 1 = 4294967295)
  uint32_t n = loopCounter;
  uint8_t i = 9;
  while (n) { // format number in ASCII
    buffer[i--] = (n % 10UL) | '0';
    n /= 10UL;
  }
  for (uint8_t i = 0; i < 10; i++) { // copy buffer to last ten positions of screen character RAM
    screenRam[BYTES_PER_RASTER * CHARACTER_ROWS - 10 + i] = buffer[i];
  }
}
int main(void) {
	setup();
	while (1) {
		loop();
	}
}

