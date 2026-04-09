/* vim: ft=cpp showbreak=--»\  noexpandtab fileencoding=utf-8 nomodified wrap textwidth=0 foldmethod=marker foldmarker={{{,}}} foldcolumn=4 ruler showcmd lcs=tab\:|- list: tabstop=8 linebreak tags=./tags;,tags; 
 * */
// ,,g = gcc, exactly one space after "set"
//
#pragma once
#include <avr/io.h>        // SREG
#include <avr/interrupt.h> // cli(), sei()
#include <avr/pgmspace.h>  // uint_farptr_t

#include <stdint.h>
#include "TextVGA.h"
unsigned long millis();


