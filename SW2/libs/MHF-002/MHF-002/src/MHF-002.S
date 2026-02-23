#define __SFR_OFFSET 0x00
#include <avr/io.h>
#include "MHF-002.h"

ldi r24, VGA_LATCH_PIN
set_output(VGA_LATCH)
set_output(VGA_ENABLE)
