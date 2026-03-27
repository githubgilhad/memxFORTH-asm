#pragma once

#ifdef __ASSEMBLER__

	/* ===================== */
	/* assembler (.S) část   */
	/* ===================== */

	.extern SnakeCharDef2;

#else /* C nebo C++ */

#ifdef __cplusplus
	extern "C" {
#endif

	/* ===================== */
	/* C / C++ část          */
	/* ===================== */
		#include <inttypes.h>
		#include <avr/pgmspace.h>
		extern	 const uint8_t SnakeCharDef2[9][256] PROGMEM;	// VGA just 8 top lines, RCA all 9

#ifdef __cplusplus
}
#endif

#endif /* __ASSEMBLER__ else part*/
