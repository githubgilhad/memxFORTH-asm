; .. vim: ft=asm showbreak=--»\  noexpandtab fileencoding=utf-8 nomodified   wrap textwidth=0 foldmethod=marker foldmarker={{{,}}} foldcolumn=4 ruler showcmd lcs=tab\:|- list tabstop=8 noexpandtab nosmarttab softtabstop=0 shiftwidth=0 linebreak  

DEFTCBVAR "HERE",TCB_HERE		; first free byte in RAM

; FORTH2012: https://forth-standard.org/standard/core/HERE

; 6.1.1650 HERE CORE
; ( -- addr )
; 
; addr is the data-space pointer.
; 
; See:
; 3.3.3.2 Contiguous regions.
; 
; Testing:
; See F.6.1.0150 ,, F.6.1.0710 ALLOT, F.6.1.0860 C,. 
