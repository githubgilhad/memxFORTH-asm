/* vim: ft=cpp showbreak=--»\  noexpandtab fileencoding=utf-8 nomodified wrap textwidth=0 foldmethod=marker foldmarker={{{,}}} foldcolumn=4 ruler showcmd lcs=tab\:|- list: tabstop=8 linebreak tags=./tags;,tags; 
 * */
// ,,g = gcc, exactly one space after "set"
//
#pragma once

// use as TIMER1_COMPA_vect_handler=C_function;		// but NO registers are saved (except needed minimum =  ZL,ZH,SREG), the C_function must protect everything needed

typedef void (*isr_handler)(void);
extern isr_handler	TIMER1_COMPA_vect_handler;
extern isr_handler	TIMER3_COMPA_vect_handler;
extern isr_handler	TIMER3_COMPC_vect_handler;

