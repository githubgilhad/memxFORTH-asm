#pragma once

#ifdef __ASSEMBLER__

	/* ===================== */
	/* assembler (.S) část   */
	/* ===================== */

	.extern StdTextCharDef;

#else /* C nebo C++ */

#ifdef __cplusplus
	extern "C" {
#endif

	/* ===================== */
	/* C / C++ část          */
	/* ===================== */
		#include <inttypes.h>
		#include <avr/pgmspace.h>
// extern const uint8_t block1[0x7FFF] PROGMEM ;
// extern const uint8_t block2[0x7FFF] PROGMEM ;
// extern const uint8_t block3[0x7FFF] PROGMEM ;
// extern const uint8_t block4[0x7FFF] PROGMEM ;
// extern const uint8_t block5[0x7FFF] PROGMEM ;
// extern const uint8_t block6[0x7FFF] PROGMEM ;
// extern const uint8_t block7[0x7FFF] PROGMEM ;
// extern const uint8_t block8[0x7FFF] PROGMEM ;
		extern	 const uint8_t StdTextCharDef[9][256] PROGMEM;	// VGA just 8 top lines, RCA all 9

#ifdef __cplusplus
}
#endif

#endif /* __ASSEMBLER__ else part*/
