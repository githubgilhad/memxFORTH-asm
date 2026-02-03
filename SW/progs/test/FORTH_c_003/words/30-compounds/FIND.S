; .. vim: ft=asm showbreak=--»\  noexpandtab fileencoding=utf-8 nomodified   wrap textwidth=0 foldmethod=marker foldmarker={{{,}}} foldcolumn=4 ruler showcmd lcs=tab\:|- list tabstop=8 noexpandtab nosmarttab softtabstop=0 shiftwidth=0 linebreak  


;DEFWORD w_FIND,			0,		"FIND",			f_FIND			; FIND ( c-addr -- c-addr 0 | xt 1 | xt -1 ) TODO

.section CURRENT_TEXT_SECTION,"ax",@progbits
;gfunc f_FIND	; {{{ # FIXME
;	rjmp NEXT
; }}}

; WRONG
; : FIND ( c-addr -- c-addr 0 | xt 1 | xt -1 )
;   DUP >R              \ uloz c-addr
;   COUNT               \ c-addr u
;   GET-ORDER           \ c-addr u wid_n ... wid_1 n
;   0 ?DO
;     >R                \ c-addr u | wid
;     2DUP R>           \ c-addr u wid
;     SEARCH-WORDLIST   \ c-addr u 0 | xt f
;     DUP IF            \ nalezeno?
;       NIP NIP         \ zahod c-addr u
;       R> DROP         \ zahod puvodni c-addr
;       UNLOOP EXIT
;     THEN
;     DROP              \ drop 0
;   LOOP
;   2DROP               \ drop u
;   R> 0 ;               \ vrat c-addr 0
