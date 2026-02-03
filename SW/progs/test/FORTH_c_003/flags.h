/* vim: set ft=cpp noexpandtab fileencoding=utf-8 nomodified wrap textwidth=0 foldmethod=marker foldmarker={{{,}}} foldcolumn=4 ruler showcmd lcs=tab\:|- list: tabstop=8 linebreak showbreak=»\  */
// ,,g = gcc, exactly one space after "set"
#pragma once

#define FLG_IMMEDIATE	0x80		// run in st_executing STATE
#define FLG_HIDDEN	0x40		// do not show this
#define FLG_FOG		0x20		// stop here in WORDS and FIND
#define FLG_ARG_1	0x01		// if next 1 byte (byte)   is argument, not next entry
#define FLG_ARG_2	0x02		// if next 2 bytes (word)  is argument, not next entry
#define FLG_ARG_3	0x03		// if next 3 bytes (PTR_t) is argument, not next entry
#define FLG_PSTRING	0x04		// PSTRING follows (LITSTRING)
// #define FLG_NOFLAG	~(FLG_IMMEDIATE | FLG_HIDDEN)
#define F_TRUE	0x1	// or -1?
#define F_FALSE	0x0
