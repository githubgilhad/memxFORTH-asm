.. vim: set ft=rst noexpandtab fileencoding=utf-8 nomodified   wrap textwidth=0 foldmethod=marker foldmarker={{{,}}} foldcolumn=4 ruler showcmd lcs=tab\:|- list tabstop=8 noexpandtab nosmarttab softtabstop=0 shiftwidth=0 linebreak showbreak=»\

.. |Ohm| raw:: html

	Ω

.. |kOhm| raw:: html

	kΩ


.. image:: MemxFORTHChipandColorfulStack.png
	:width: 250
	:target: MemxFORTHChipandColorfulStack.png

memxFORTH-asm
=============

This project builds memxFORTH directly from assembler and try to be memory-effective

Target is ATmega2560 at MegaHomeFORTH board

* Normal state is:
	* 8kB RAM used for FORTH Stack and Return Stack, also for System Stack (so these are accessible anytime)
	* Extended Memory is mapped on high part of 128kB and active (so paged RAM is lower 72kB = 64+8)
	* Shared Memory is not accessible
* All pointers should be 3-bytes/24-bits long, also CELL size is 3-bytes, so there is no size mismatch between address and value
	* Extra-byte (bits 16..23) is 0x80 for RAM, 00..03 for FLASH (and maybe something else for paged RAM and Shared Ram)
		* bits:
			* bit 7:  1=RAM; 0=other (special read)
			* bits 76: 00,11 = NOT pointer (=large negative/small positive value), 10, 01 =probabely pointer somewhere, translating it to FORTH may make sense :)
				* this is for SHOW heuristicks to distinquish normal values from FORTH words addresses 
			* all FORTH functions for FLASH address should set bit 22 high
			* bits 5..3: reserved (zero now)
			* bit 2: 1= 128kB chips
			* bits 1,0: bank for FLASH, for RAM 0x=external RAM, 1x=Shared RAM
		* 80 -    Normal RAM (64 kB) ( `ld r24,Z+` style) (last 56kB is top of Extended memory too)
		* 40  - Normal flash (0-64kB)( `lpm r24,Z+` style)
		* 41..43 - Normal flash (64-256kB) ( `out RAMPZ,??; elpm r24,Z+` style) probably better for 40 too (just 1 clock more) (&46=40)
		* 44..45 - Extended memory (128kB) last 56kB is top of System RAM too (&46=44)
		* 46..47 - Shared memory (128kB) (&46=46)

	* all memory acceess should be via system calls: THIS and THAT (and maintain Normal state)
		* the access MAY fail if given bad pointer, then it returns (**FLAG**) and data are (**UNDEFINED**) (or it jumps to Bad Memory Handler ???)
			* namely it immediatelly fails when Shared Memory is asked and not allowed by GLUE
		* extra memory access is via other system calls
* reserved/assigned registers are this, every primitive is requered to protect and update them responsibly (just idea):
	* X+r0 - contain DT after NEXT, discartable
	* Y+r2 - IP (preserved in C)
	* Z - free to use (ELPM, EIJMP ...)
	* SP - ASM RETURN stack
	* r0 (DT)
	* r1 ZERO
	* r2 IP
	* r3..5 TOS - Top Of Stack
	* r6..7 S - Stack (in RAM 0)
	* r8..9 RS - Return Stack (in RAM 0)
	* r10..r17 Free to assign (or preserve before use)
	* r18..r27 Free to use (discartable) (including X=r26..27)
	* r26..27 X - filled with DT in NEXT, discartable
	* r28..29 Y - IP (preserved by C, used by FORTH)
	* r30..31 Z - discartable
* special registers:
	* Z - EIJMP, ELPM, Z+displacement
	* Y - Y+displacement
	* X - normal ( each can predecrement and postincrement)
* RAMPZ - not preserved by subroutines, set it everytime


.. code::

	#define JMP_ADDR(addr16)                   \
		do {                               \
			__asm__ __volatile__ (     \
				".word 0x940C\n\t" \
				".word %0\n\t"     \
				: : "i" (addr16)   \
			);                         \
	    } while (0)

.. code::

	register uint8_t counter asm("r2");  // r2 is the counter
	__attribute__((naked, noreturn)) void function_A(void) { ... ;EIJMP; }


.. code::

	__attribute__((naked, noreturn))
	void jump_to(uint32_t addr) {
		__asm__ __volatile__ (
			"mov r30, r22\n\t"
			"mov r31, r23\n\t"
			"out %[_RAMPZ], r24\n\t"
			"eijmp\n\t"
			:
			: [_RAMPZ] "I" (_SFR_IO_ADDR(RAMPZ))
		);
	}


License
-------
GPL 2 or GPL 3 - choose the one that suits your needs.

Author
------
Gilhad - 2025

