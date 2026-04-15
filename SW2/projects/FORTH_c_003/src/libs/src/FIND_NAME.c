/* vim: ft=cpp showbreak=--»\  noexpandtab fileencoding=utf-8 nomodified wrap textwidth=0 foldmethod=marker foldmarker={{{,}}} foldcolumn=4 ruler showcmd lcs=tab\:|- list: tabstop=8 linebreak tags=./tags;,tags; 
 * */
// ,,g = gcc, exactly one space after "set"
//
#include "FIND_NAME.h"
#define TEXT __attribute__((section(".text.C_words")))


// TCB = r24:25, addr = r22:r23, len = r20

TEXT uint32_t find_name_tcb(Thread_Controll_Block *TCB, const char *addr, uint8_t len) {	 // {{{ returns xt+(flag<<24) flag is byte
	uint32_t head, a;
	uint32_t p;
	bool fog;
	uint8_t l,att;
	const char *c;
	bool match;
/*
uint32_t u;
VGA0_WriteStr("\r\nTCB:");VGA0_WriteHex24((uint32_t)TCB);
VGA0_WriteStr(" addr:");VGA0_WriteHex24((uint32_t)addr);
VGA0_WriteStr(" len:");VGA0_WriteHex24(len);
VGA0_WriteStr(" string'");c=addr; for (uint16_t x=0; x<len;x++) VGA0_Write(*c++); VGA0_WriteStr("'  ");
*/
	if (len == 0 ) return 0;
	for (uint8_t i=0;i<TCB->WL_ORDER_len;i++) {
		p=P24_U32(TCB->WL_ORDER[i]);	// wid
		head=C_B3at(p);			// top word
		fog=false;			// word with fog is last visible word
		
		while (head && (!fog)) {	// climb wordlist (to NULL or FOG)
			a=head;
			head = C_B3at(a); a+=3;	// head->

			
			att=C_B1at(a++);	// attributes
			fog = (att & FLG_FOG);	// fog is last
			if (att & FLG_HIDDEN) 
				continue;	// hidden does not match
			
			l=C_B1at(a++);		// len of name
/*
VGA0_WriteStr(" ??'");u=a; for (uint16_t x=0; x<l;x++) VGA0_Write(C_B1at(u++)); VGA0_WriteStr("'  ");
*/
			if (l!=len) continue;	// does not match
			c=addr;			// C is name to compare
			match = true;
			for (uint8_t j=0;j<l;j++)		// for each character
				if (C_B1at(a++) != *c++)	// if not macth
					{match=false;break;};	// go away
			if (! match ) continue;			// go away
								// xt is address of cw (after name)
			return (a | ( (att & FLG_IMMEDIATE)? 0x01000000L: 0xFF000000) );
				// r22:r24 = xt, r25 = flag
		};
	};
	return 0;
}	// }}}
