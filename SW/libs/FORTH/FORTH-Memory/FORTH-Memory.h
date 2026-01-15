#pragma once

#ifdef __ASSEMBLER__

.global B1at
.global B3at
.global W1at
.global W3at
.global Memory_failed

#else

extern uint8_t  B1at;
extern uint8_t  B3at;
extern uint16_t W1at;
extern uint16_t W3at;
extern uint8_t  Memory_failed;

#endif
