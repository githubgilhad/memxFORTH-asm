; .. vim: ft=asm showbreak=--»\  noexpandtab fileencoding=utf-8 nomodified   wrap textwidth=0 foldmethod=marker foldmarker={{{,}}} foldcolumn=4 ruler showcmd lcs=tab\:|- list tabstop=8 noexpandtab nosmarttab softtabstop=0 shiftwidth=0 linebreak  


#undef CURRENT_TEXT_SECTION
#undef CURRENT_DATA_SECTION
#define CURRENT_TEXT_SECTION .text.FORTH.words.bios
#define CURRENT_DATA_SECTION .FORTH_data.headers
.section CURRENT_TEXT_SECTION,"ax",@progbits
.balign 2
