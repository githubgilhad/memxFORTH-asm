; .. vim: ft=asm showbreak=--»\  noexpandtab fileencoding=utf-8 nomodified   wrap textwidth=0 foldmethod=marker foldmarker={{{,}}} foldcolumn=4 ruler showcmd lcs=tab\:|- list tabstop=8 noexpandtab nosmarttab softtabstop=0 shiftwidth=0 linebreak  


; : CREATE HERE GET-CURRENT @ , GET-CURRENT ! WORD (compile in len+chars here) ` do_create , ; TODO
;


; https://forth-standard.org/standard/core/CREATE
; 
; 6.1.1000 CREATE CORE
; ( "<spaces>name" -- )
; 
; Skip leading space delimiters. Parse name delimited by a space. Create a definition for name with the execution semantics defined below. If the data-space pointer is not aligned, reserve enough data space to align it. The new data-space pointer defines name's data field. CREATE does not allocate data space in name's data field.
; 
; name Execution:
; ( -- a-addr )
; 
; a-addr is the address of name's data field. The execution semantics of name may be extended by using DOES>.
; 
; See:
; 3.3.3 Data space, 6.1.1250 DOES>, A.6.1.1000 CREATE.
; 
; R_ationale:
; The data-field address of a word defined by CREATE is given by the data-space pointer immediately following the execution of CREATE.
; 
; Reservation of data field space is typically done with ALLOT.
; 
; Typical use: ... CREATE SOMETHING ... 
