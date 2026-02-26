pokus o MHF-002 FORTH - tentokrat jsem uz dost daleko a vypada to celkem dobre

use speed 115200

uint8_t slow_var __attribute__((section(".highram")));

.section .highmem, "aw", @nobits
asm_high:
    .byte 0


.highram i .highmem jdou nad 8.5kB do AVR EXTMEM

