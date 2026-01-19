#include <stdint.h>
#include <stddef.h>

typedef struct __attribute__((packed)) { uint8_t lo, hi, hlo; } P24;
typedef struct __attribute__((packed)) { uint8_t lo, hi; } P16;
typedef struct __attribute__((packed)) {
	// FORTH state
	P24 IP;
	P16 DST;
	P16 RST;
	P24 TOS;
	P24 DT; 	// probably not used, we will return to yield() before NEXT
	// C state
	P24 C_SP;
	// something_else
	uint32_t something_else;
} User;

/* export offsets for ASM */

/* This generate text, that we will extract later. Not necessery valid code. */
#define GEN(sym, val) \
	asm volatile (".equ " #sym ", %0" :: "i"(val))


void gen_offsets(void)		// this is envelope for our generated text, it will NOT be compiled, just macro expanded.
{
	// FORTH state
	GEN(USER_IP,		offsetof(User, IP));
	GEN(USER_DST,		offsetof(User, DST));
	GEN(USER_RST,		offsetof(User, RST));
	GEN(USER_TOS,		offsetof(User, TOS));
	GEN(USER_DT,		offsetof(User, DT));
	// C state
	GEN(USER_C_SP,		offsetof(User, C_SP));
	// something_else
	GEN(USER_SOMETHING,	offsetof(User, something_else));
	// total size
	GEN(USER_SIZE,		sizeof(User));
};
