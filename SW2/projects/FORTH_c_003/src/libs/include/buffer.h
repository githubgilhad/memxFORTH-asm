/* vim: ft=cpp showbreak=--»\  noexpandtab fileencoding=utf-8 nomodified wrap textwidth=0 foldmethod=marker foldmarker={{{,}}} foldcolumn=4 ruler showcmd lcs=tab\:|- list: tabstop=8 linebreak tags=./tags;,tags; 
 * */
// ,,g = gcc, exactly one space after "set"
//
#pragma once

uint16_t BUF_Read_C(uint8_t *Buff);
uint8_t BUF_Free_C(uint8_t *Buff);
uint8_t BUF_Used_C(uint8_t *Buff);
uint16_t BUF_Write_C(uint8_t *Buff,uint8_t c);
