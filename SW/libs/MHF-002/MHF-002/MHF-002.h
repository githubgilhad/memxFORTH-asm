#pragma once

// #pragma message("MHF-002.h included")

#define CAT(a,b) a##b
#define XCAT(a,b) CAT(a,b)

#define VGA_LATCH_PORT B
#define VGA_LATCH_PIN 7

#define VGA_ENABLE_PORT D
#define VGA_ENABLE_PIN 2

#define VGA_VSYNC_PORT E
#define VGA_VSYNC_PIN 4

#define VGA_HSYNC_PORT B
#define VGA_HSYNC_PIN 6

#define do_port_pin__(instr, fun, port,pin) instr XCAT(fun,port), pin

#define set_output(name) 	do_port_pin__( SBI, DDR, name##_PORT, name##_PIN)
#define set_input(name) 	do_port_pin__( CBI, DDR, name##_PORT, name##_PIN)
#define out_hi(name) 		do_port_pin__( SBI, PORT, name##_PORT, name##_PIN)
#define out_lo(name) 		do_port_pin__( CBI, PORT, name##_PORT, name##_PIN)


#define Cdo_port_pin__(instr, fun, port,pin) XCAT(fun,port) instr _BV( pin )
#define Cset_output(name) 	Cdo_port_pin__( |=, DDR, name##_PORT, name##_PIN)
#define Cset_input(name) 	Cdo_port_pin__( &= ~, DDR, name##_PORT, name##_PIN)
#define Cout_hi(name) 		Cdo_port_pin__( |=, PORT, name##_PORT, name##_PIN)
#define Cout_lo(name) 		Cdo_port_pin__( &= ~, PORT, name##_PORT, name##_PIN)

#define VGA_DATA_PORT F
#define VGA_COLOR_PORT H

#ifdef __ASSEMBLER__

.macro do_reg_port__ reg, val, instr, funport
	ldi  \reg, \val
	\instr \funport, \reg 
.endm
#endif

#define set_output_all(name, instr)	do_reg_port__ r24, 0xFF, instr, XCAT(DDR, name##_PORT)
#define set_input_all(name, instr)	do_reg_port__ r24, 0x00, instr, XCAT(DDR, name##_PORT)


#define RCA_SIGNAL_PORT D
#define RCA_SIGNAL_PIN 3

#define RCA_SYNC_PORT E
#define RCA_SYNC_PIN 4

#define RCA_SUPPRESS_PORT B
#define RCA_SUPPRESS_PIN 6
