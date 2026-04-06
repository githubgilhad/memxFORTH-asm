// vim: ft=cpp showbreak=--»\  noexpandtab fileencoding=utf-8 nomodified wrap textwidth=0 foldmethod=marker foldmarker={{{,}}} foldcolumn=4 ruler showcmd lcs=tab\:|- list: tabstop=8 linebreak
// ,,g = gcc, exactly one space after "set"

#pragma once

// #define TextVGA_LINES 59
// #define TextVGA_COLUMNS 50
#define TextVGA_LINES 58
#define TextVGA_COLUMNS 49
#define TextVGA_SUBLINES 8
#define TextVGA_FIRST_SCAN_LINE 38
#define TextVGA_ACTIVE_SCAN_LINES TextVGA_SUBLINES*TextVGA_LINES
#define TextVGA_LAST_SCAN_LINE (TextVGA_FIRST_SCAN_LINE + TextVGA_ACTIVE_SCAN_LINES)


#define	VGA_BLACK	( 0b0000 <<4 )
#define	VGA_DKGRAY	( 0b0001 <<4 )
#define	VGA_DKRED	( 0b1000 <<4 )
#define	VGA_DKGREEN	( 0b0100 <<4 )
#define	VGA_DKYELLOW	( 0b1100 <<4 )
#define	VGA_DKBLUE	( 0b0010 <<4 )
#define	VGA_DKMAGENTA	( 0b1010 <<4 )
#define	VGA_DKCYAN	( 0b0110 <<4 )
#define	VGA_RED		( 0b1001 <<4 )
#define	VGA_GREEN	( 0b0101 <<4 )
#define	VGA_YELLOW	( 0b1101 <<4 )
#define	VGA_BLUE	( 0b0011 <<4 )
#define	VGA_MAGENTA	( 0b1011 <<4 )
#define	VGA_CYAN	( 0b0111 <<4 )
#define	VGA_GRAY	( 0b1110 <<4 )
#define	VGA_WHITE	( 0b1111 <<4 )
#define	VGA_B_BLACK	( 0b0000 )
#define	VGA_B_DKGRAY	( 0b0001 )
#define	VGA_B_DKRED	( 0b1000 )
#define	VGA_B_DKGREEN	( 0b0100 )
#define	VGA_B_DKYELLOW	( 0b1100 )
#define	VGA_B_DKBLUE	( 0b0010 )
#define	VGA_B_DKMAGENTA	( 0b1010 )
#define	VGA_B_DKCYAN	( 0b0110 )
#define	VGA_B_RED	( 0b1001 )
#define	VGA_B_GREEN	( 0b0101 )
#define	VGA_B_YELLOW	( 0b1101 )
#define	VGA_B_BLUE	( 0b0011 )
#define	VGA_B_MAGENTA	( 0b1011 )
#define	VGA_B_CYAN	( 0b0111 )
#define	VGA_B_GRAY	( 0b1110 )
#define	VGA_B_WHITE	( 0b1111 )
#define	VGA_none	( 0xF0 )
