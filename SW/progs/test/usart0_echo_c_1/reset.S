#include <avr/io.h>
.section .init0
.global RESET
RESET:
    ldi r16, hi8(RAMEND)
    out _SFR_IO_ADDR(SPH), r16
    ldi r16, lo8(RAMEND)
    out _SFR_IO_ADDR(SPL), r16
    clr r1
    out _SFR_IO_ADDR(SREG), r1
    out _SFR_IO_ADDR(EIND), r1
    out _SFR_IO_ADDR(RAMPZ), r1
    rjmp main
