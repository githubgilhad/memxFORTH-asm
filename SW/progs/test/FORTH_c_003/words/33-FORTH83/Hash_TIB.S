; .. vim: ft=asm showbreak=--»\  noexpandtab fileencoding=utf-8 nomodified   wrap textwidth=0 foldmethod=marker foldmarker={{{,}}} foldcolumn=4 ruler showcmd lcs=tab\:|- list tabstop=8 noexpandtab nosmarttab softtabstop=0 shiftwidth=0 linebreak  

DEFTCBVAR "#TIB",	TCB_TIB		; ( -- addr ) address of #TIB, number ot bytes in TIB
;      #TIB         -- addr                       U,83    "number-t-i-b"
;           The address of a variable containing the number of bytes in
;           the text input buffer.  #TIB is accessed by WORD when BLK is
;           zero.  {{0..capacity of TIB}}  See:  "input stream"

