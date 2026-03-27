#pragma once

uint8_t VGA0_Write(char c);	// c=char to write, r24=buf_used. BLOCKS if buffer full
uint8_t VGA0_WriteA(char c);	// c=char to write, r24=buf_used. BLOCKS if buffer full, writes only ASCII
uint8_t VGA0_Used();		// used space in TX buffer
uint8_t VGA0_Free();		// available space in TX buffer
//
uint8_t VGA0_WriteStr(char *c);	// Cstring, r24=buf_used. BLOCKS if buffer full
uint8_t VGA0_WriteBin8(uint8_t h);	//  101010101010, r24=buf_used. BLOCKS if buffer full
uint8_t VGA0_WriteHex8(uint8_t h);	//       0A, r24=buf_used. BLOCKS if buffer full
uint8_t VGA0_WriteHex16(uint16_t h);	//     0A0D , r24=buf_used. BLOCKS if buffer full
uint8_t VGA0_WriteHex24(uint32_t h);	//   0A0D0C , r24=buf_used. BLOCKS if buffer full
uint8_t VGA0_WriteHex32(uint32_t h);	// 0A0D0C0D , r24=buf_used. BLOCKS if buffer full

