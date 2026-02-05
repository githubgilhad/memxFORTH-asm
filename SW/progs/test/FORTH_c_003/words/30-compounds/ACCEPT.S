; .. vim: ft=asm showbreak=--»\  noexpandtab fileencoding=utf-8 nomodified   wrap textwidth=0 foldmethod=marker foldmarker={{{,}}} foldcolumn=4 ruler showcmd lcs=tab\:|- list tabstop=8 noexpandtab nosmarttab softtabstop=0 shiftwidth=0 linebreak  


DEFWORD w_ACCEPT,		0,		"ACCEPT",		f_docol, yes	; ( c-addr max -- n ) (  --  ) move INPUT to addr, limited to max chars, return actual number TODO [0695]
; {{{

	P24 var_TCB_AIB_max_cw
	P24 w_word_store_cw
	
	P24 var_PROMPT_X_cw
	P24 w_char_at_cw
	P24 var_PROMPT_Y_cw
	P24 w_char_at_cw
	P24 w_CURSOR_XY_cw
	
	P24 w_AIB_CLEAR_cw
;;	P24 w_DRAW_AIB_cw
	
;	P24 w_BEGIN_cw
2:
	P24 w_KEY_cw
	P24 w_qDUP_cw
;	P24 w_IF_cw	; 3: key
	P24 w_0BRANCH_cw
	P24 3f - .
;	P24 w_CASE_cw	; 4: ENDCASE
	P24 const_K_ENTER_cw
;	P24 w_OF_cw	; OF
	P24 w_OVER_cw
	P24 w_equals_cw
	P24 w_0BRANCH_cw
	P24 5f - .
	P24 w_DROP_cw	; ..OF
;	P24 w_LEAVE_cw			; ===================================== LEAVE tady nefunguje
					P24 w_BRANCH_cw
					P24 9f - .
;	P24 w_ENDOF_cw	; ENDOF
	P24 w_BRANCH_cw
	P24 4f - .
5:
	P24 const_K_LEFT_cw
;	P24 w_OF_cw	; OF
	P24 w_OVER_cw
	P24 w_equals_cw
	P24 w_0BRANCH_cw
	P24 5f - .
	P24 w_DROP_cw	; ..OF
	P24 w_CURSOR_LEFT_cw
;	P24 w_ENDOF_cw	; ENDOF
	P24 w_BRANCH_cw
	P24 4f - .
5:
	P24 const_K_RIGHT_cw
;	P24 w_OF_cw	; OF
	P24 w_OVER_cw
	P24 w_equals_cw
	P24 w_0BRANCH_cw
	P24 5f - .
	P24 w_DROP_cw	; ..OF
	P24 w_CURSOR_RIGHT_cw
;	P24 w_ENDOF_cw	; ENDOF
	P24 w_BRANCH_cw
	P24 4f - .
5:
	P24 const_K_BACKSPACE_cw
;	P24 w_OF_cw	; OF
	P24 w_OVER_cw
	P24 w_equals_cw
	P24 w_0BRANCH_cw
	P24 5f - .
	P24 w_DROP_cw	; ..OF
	P24 w_AIB_BACKSPACE_cw
;	P24 w_ENDOF_cw	; ENDOF
	P24 w_BRANCH_cw
	P24 4f - .
5:
	P24 const_K_DEL_cw
;	P24 w_OF_cw	; OF
	P24 w_OVER_cw
	P24 w_equals_cw
	P24 w_0BRANCH_cw
	P24 5f - .
	P24 w_DROP_cw	; ..OF
	P24 w_AIB_DELETE_cw
;	P24 w_ENDOF_cw	; ENDOF
	P24 w_BRANCH_cw
	P24 4f - .
5:
	P24 const_K_ESC_cw
;	P24 w_OF_cw	; OF
	P24 w_OVER_cw
	P24 w_equals_cw
	P24 w_0BRANCH_cw
	P24 5f - .
	P24 w_DROP_cw	; ..OF
	P24 w_AIB_CLEAR_cw
;	P24 w_ENDOF_cw	; ENDOF
	P24 w_BRANCH_cw
	P24 4f - .
5:
	P24 w_DUP_cw
	P24 w_AIB_INSERT_cw
;	P24 w_ENDCASE_cw
	P24 w_DROP_cw
4:			; ENDCASE
	P24 w_DRAW_AIB_cw
;	P24 w_THEN_cw	; 3: key
3:
;	P24 w_AGAIN_cw
	P24 w_BRANCH_cw
	P24 2b -.
9:
	P24 var_TCB_AIB_cw
	P24 w_SWAP_cw
	P24 var_TCB_AIB_len_cw
	P24 w_word_at_cw
	P24 w_RAM_MOVE_cw
	P24 var_TCB_AIB_len_cw
	P24 w_word_at_cw
	
	P24 w_LIT1_cw
	.byte '\r'
	P24 w_EMIT_cw
	
	P24 w_LIT1_cw
	.byte '\n'
	P24 w_EMIT_cw
	
	P24 w_exit_cw
; }}}
; : ACCEPT ( addr max -- n ) {{{
;    TCB_AIB_max !
;    PROMPT_X C@ PROMPT_Y C@ CURSOR_XY
;    AIB-CLEAR
;    DRAW-AIB
; 
;    BEGIN
;       KEY ?DUP IF
;          CASE
;             K_ENTER      OF LEAVE ENDOF
;;;					;	P24 w_LEAVE_cw			; ===================================== LEAVE tady nefunguje
;;;										P24 w_BRANCH_cw
;;;										P24 9f - .
;             K_LEFT       OF CURSOR-LEFT ENDOF
;             K_RIGHT      OF CURSOR-RIGHT ENDOF
;             K_BACKSPACE  OF AIB-BACKSPACE ENDOF
;             K_DEL        OF AIB-DELETE ENDOF
;             K_ESC        OF AIB-CLEAR ENDOF
;             \ default: normalni znak
;             DUP AIB-INSERT
;          ENDCASE
;          DRAW-AIB
;       THEN
;    AGAIN
; 
;    \ kopirovani do cilove adresy
;     AIB SWAP TCB_AIB_len W@ RAM-MOVE
;    TCB_AIB_len W@ ;
;    \ EMIT(\r\n) for test
;  }}}

; https://forth-standard.org/standard/core/ACCEPT
; 
; 6.1.0695 ACCEPT CORE
; ( c-addr +n1 -- +n2 )
; 
; Receive a string of at most +n1 characters. An ambiguous condition exists if +n1 is zero or greater than 32,767. Display graphic characters as they are received. A program that depends on the presence or absence of non-graphic characters in the string has an environmental dependency. The editing functions, if any, that the system performs in order to construct the string are implementation-defined.
; 
; Input terminates when an implementation-defined line terminator is received. When input terminates, nothing is appended to the string, and the display is maintained in an implementation-defined way.
; 
; +n2 is the length of the string stored at c-addr.
; 
; See:
; A.6.1.0695 ACCEPT.
; 
; Rationale:
; Specification of a non-zero, positive integer count (+n1) for ACCEPT allows some implementors to continue their practice of using a zero or negative value as a flag to trigger special behavior. Insofar as such behavior is outside the standard, Standard Programs cannot depend upon it, but the committee doesn't wish to preclude it unnecessarily. Because actual values are almost always small integers, no functionality is impaired by this restriction.
; 
; It is recommended that all non-graphic characters be reserved for editing or control functions and not be stored in the input string.
; 
; Because external system hardware and software may perform the ACCEPT function, when a line terminator is received the action of the cursor, and therefore the display, is implementation-defined. It is recommended that the cursor remain immediately following the entered text after a line terminator is received. 
; 

DEFWORD w_BEEP,			0,		"BEEP",			f_docol, yes	; ( -- ) BEEP
	P24 w_LIT1_cw
	.byte 0x07	; '\a'
	P24 w_EMIT_cw
	P24 w_exit_cw

; Práce s kurzorem

DEFWORD w_PLACE_CURSOR,		0,		"PLACE_CURSOR",		f_docol, yes	; ( -- ) set cursor pos

	P24 var_TCB_AIB_cur_cw
	P24 w_word_at_cw
	P24 var_PROMPT_X_cw
	P24 w_char_at_cw
	P24 w_plus_cw
	P24 var_PROMPT_Y_cw
	P24 w_char_at_cw
	P24 w_CURSOR_XY_cw
	P24 w_exit_cw
; {{{
;   TCB_AIB_cur W@ PROMPT_X C@ + PROMPT_Y C@
;   CURSOR_XY ;
; }}}


; Překreslení řádku

DEFWORD w_DRAW_AIB,		0,		"DRAW_AIB",		f_docol, yes	; ( -- ) draw current data
; {{{
	P24 var_PROMPT_X_cw
	P24 w_char_at_cw
	P24 var_PROMPT_Y_cw
	P24 w_char_at_cw
	P24 w_CURSOR_XY_cw

	P24 var_TCB_AIB_cw
	P24 var_TCB_AIB_len_cw
	P24 w_word_at_cw
	P24 w_zero_cw
	
;;	P24 w_2DUP_cw	; ?DO (3)
;;	P24 w_greater_cw
;;	P24 w_0BRANCH_cw
;;	P24 3f - .
;	P24 w_?DO_cw	; 2
	P24 w_2toR_cw
2:

	P24 w_DUP_cw
	P24 w_I_cw
	P24 w_plus_cw
	P24 w_char_at_cw
	P24 w_EMIT_cw

	P24 w_LOOP_cw
	P24 2b - .

;; 3:			; 3: ?DO

	P24 w_DROP_cw

	P24 var_TCB_AIB_max_cw
	P24 w_word_at_cw
	P24 var_TCB_AIB_len_cw
	P24 w_word_at_cw
	
;	P24 w_2DUP_cw	; ?DO (3)
;	P24 w_greater_cw
;	P24 w_0BRANCH_cw
;	P24 3f - .
;	P24 w_?DO_cw	; 2
	P24 w_2toR_cw
2:

	P24 const_BL_cw
	P24 w_EMIT_cw

	P24 w_LOOP_cw
	P24 2b - .

;; 3:			; 3: ?DO


	P24 w_PLACE_CURSOR_cw
	P24 w_exit_cw
; }}}
; {{{  : DRAW-AIB ( -- )
;    PROMPT_X C@ PROMPT_Y C@ CURSOR_XY
;    AIB TCB_AIB_len @ 0 ?DO
;       DUP I + C@ EMIT
;    LOOP
;    DROP
;    \ vymazat zbytek po konci (pokud se mazalo)
;    TCB_AIB_max @ TCB_AIB_len @ ?DO
;       BL EMIT
;    LOOP
;    PLACE-CURSOR ;
; }}}

; Vkládání znaku

DEFWORD w_AIB_INSERT,		0,		"AIB_INSERT",		f_docol, yes	; ( c -- ) insert char
; {{{

	P24 var_TCB_AIB_len_cw
	P24 w_word_at_cw
	P24 var_TCB_AIB_max_cw
	P24 w_word_at_cw
	P24 w_equals_cw
;	P24 w_IF_cw	; 2
	P24 w_0BRANCH_cw
	P24 2f - .

	P24 w_DROP_cw
	P24 w_BEEP_cw
	P24 w_EXIT_cw

;	P24 w_THEN_cw
2:

	P24 w_DUP_cw
	P24 w_LIT1_cw
	.byte 32
	P24 w_less_cw
	
;	P24 w_IF_cw	; 2
	P24 w_0BRANCH_cw
	P24 2f - .

	P24 w_DROP_cw
	P24 w_LIT1_cw
	.byte 32

;	P24 w_THEN_cw
2:

	P24 var_TCB_AIB_cw
	P24 var_TCB_AIB_cur_cw
	P24 w_word_at_cw
	P24 w_plus_cw

	P24 var_TCB_AIB_cw
	P24 var_TCB_AIB_cur_cw
	P24 w_word_at_cw
	P24 w_plus_cw
	P24 w_one_plus_cw

	P24 var_TCB_AIB_len_cw
	P24 w_word_at_cw
	P24 var_TCB_AIB_cur_cw
	P24 w_word_at_cw
	P24 w_minus_cw

	P24 w_RAM_MOVE_cw

	P24 var_TCB_AIB_cw
	P24 var_TCB_AIB_cur_cw
	P24 w_word_at_cw
	P24 w_plus_cw
	P24 w_char_store_cw

	P24 w_one_cw
	P24 var_TCB_AIB_cur_cw
	P24 w_plus_word_store_cw

	P24 w_one_cw
	P24 var_TCB_AIB_len_cw
	P24 w_plus_word_store_cw
	P24 w_exit_cw
 ; }}}
; {{{ : AIB-INSERT ( c -- )
;    TCB_AIB_len W@ TCB_AIB_max W@ = IF
;       DROP BEEP EXIT
;    THEN
;    DUP 32 < IF DROP $20 THEN       \ spec chars as spaces
;    \ posun doprava
;    TCB_AIB TCB_AIB_cur W@ +        \ src
;    TCB_AIB TCB_AIB_cur W@ + 1+     \ dst
;    TCB_AIB_len W@ TCB_AIB_cur W@ -  \ count
;    RAM-MOVE
;    \ vloz znak
;    TCB_AIB TCB_AIB_cur W@ + C!
;    1 TCB_AIB_cur +W!
;    1 TCB_AIB_len +W! ;
; }}}

; Backspace

DEFWORD w_AIB_BACKSPACE,	0,		"AIB_BACKSPACE",	f_docol, yes	; (  -- ) backspace

	P24 var_TCB_AIB_cur_cw
	P24 w_word_at_cw
	P24 w_zero_equals_cw
;	P24 w_IF_cw	; 2
	P24 w_0BRANCH_cw
	P24 2f - .

	P24 w_BEEP_cw
	P24 w_EXIT_cw

;	P24 w_THEN_cw
2:

	P24 w_one_cw
	P24 var_TCB_AIB_cur_cw
	P24 w_minus_word_store_cw

	P24 w_AIB_DELETE_cw
	P24 w_exit_cw

; {{{ : AIB-BACKSPACE ( -- )
;    TCB_AIB_cur W@ 0= IF
;       BEEP EXIT
;    THEN
;    1 TCB_AIB_cur -W!
;    AIB-DELETE ;
; }}}
; Delete

DEFWORD w_AIB_DELETE,		0,		"AIB_DELETE",		f_docol, yes	; (  -- ) delete char

	P24 var_TCB_AIB_cur_cw
	P24 w_word_at_cw
	P24 var_TCB_AIB_len_cw
	P24 w_word_at_cw
	P24 w_equals_cw
;	P24 w_IF_cw	; 2
	P24 w_0BRANCH_cw
	P24 2f - .

	P24 w_BEEP_cw
	P24 w_EXIT_cw

;	P24 w_THEN_cw
2:

	P24 var_TCB_AIB_cw
	P24 var_TCB_AIB_cur_cw
	P24 w_word_at_cw
	P24 w_plus_cw
	P24 w_one_plus_cw

	P24 var_TCB_AIB_cw
	P24 var_TCB_AIB_cur_cw
	P24 w_word_at_cw
	P24 w_plus_cw

	P24 var_TCB_AIB_len_cw
	P24 w_word_at_cw
	P24 var_TCB_AIB_cur_cw
	P24 w_word_at_cw
	P24 w_minus_cw
	P24 w_one_minus_cw

	P24 w_RAM_MOVE_cw

	P24 w_one_cw
	P24 var_TCB_AIB_len_cw
	P24 w_minus_word_store_cw
	P24 w_exit_cw

; {{{ : AIB-DELETE ( -- )
;    TCB_AIB_cur W@ TCB_AIB_len W@ = IF
;       BEEP EXIT
;    THEN
;    TCB_AIB TCB_AIB_cur W@ + 1+     \ src
;    TCB_AIB TCB_AIB_cur W@ +        \ dst
;    TCB_AIB_len W@ TCB_AIB_cur W@ - 1-  \ count
;    RAM-MOVE
;    1 TCB_AIB_len -W! ;
; }}}
; Pohyb kurzoru

DEFWORD w_CURSOR_LEFT,		0,		"CURSOR_LEFT",		f_docol, yes	; ( -- ) 


	P24 var_TCB_AIB_cur_cw
	P24 w_word_at_cw
	P24 w_zero_equals_cw
;	P24 w_IF_cw		; 2
	P24 w_0BRANCH_cw
	P24 2f - .

	P24 w_BEEP_cw
;	P24 w_ELSE_cw
	P24 w_BRANCH_cw
	P24 3f - .
2:
	P24 w_one_cw
	P24 var_TCB_AIB_cur_cw
	P24 w_minus_word_store_cw
;	P24 w_THEN_cw
3:
	P24 w_exit_cw

; {{{ : CURSOR-LEFT ( -- )
;   TCB_AIB_cur W@ 0= IF BEEP ELSE 1 TCB_AIB_cur -W! THEN ;
; }}}

DEFWORD w_CURSOR_RIGHT,		0,		"CURSOR_RIGHT",		f_docol, yes	; ( -- ) 

	P24 var_TCB_AIB_cur_cw
	P24 w_word_at_cw
	P24 var_TCB_AIB_len_cw
	P24 w_word_at_cw
	P24 w_equals_cw
;	P24 w_IF_cw
	P24 w_0BRANCH_cw
	P24 2f - .

	P24 w_BEEP_cw
;	P24 w_ELSE_cw
	P24 w_BRANCH_cw
	P24 3f - .
2:
	P24 w_one_cw
	P24 var_TCB_AIB_cur_cw
	P24 w_plus_word_store_cw
;	P24 w_THEN_cw
3:
	P24 w_exit_cw
; {{{ : CURSOR-RIGHT ( -- )
;   TCB_AIB_cur W@ TCB_AIB_len W@ = IF BEEP ELSE 1 TCB_AIB_cur +W! THEN ;
; }}}

; Escape (vymazat vše)

DEFWORD w_AIB_CLEAR,		0,		"AIB_CLEAR",		f_docol, yes	; (  -- ) clear buffer

	P24 w_zero_cw
	P24 var_TCB_AIB_len_cw
	P24 w_word_store_cw

	P24 w_zero_cw
	P24 var_TCB_AIB_cur_cw
	P24 w_word_store_cw
	P24 w_exit_cw

; {{{ : AIB-CLEAR ( -- )
;    0 TCB_AIB_len W!
;    0 TCB_AIB_cur W! ;
; }}}

;; /*
;; :date: 2026.01.24 01:18:19
;; :_modified: 1970.01.01 00:00:00
;; :tags: FORTH,AI
;; :authors: Gilhad
;; :summary: ACCEPT_kecy
;; :title: ACCEPT_kecy
;; :nice_title: |logo| %title% |logo|
;; 
;; %HEADER%
;; 
;; ACCEPT_kecy
;; --------------------------------------------------------------------------------
;; 
;; 
;; You said:
;; Chtel bych do FORTHu napsat slovo ACCEPT (address max -- number), ktere
;; - dostane adresu a maximalni pocet znaku, ty nacte pomoci slova KEY s jednoduchou editaci az do delky toho zadaneho max a pak je presune na zadanou adresu a na zasobniku vrati, kolik jich presunulo
;; - editace bude pouzivat klavesy DEL, BACKSPACE, sipky vpravo a vlevo, ESC smaze vse dosud nactene, ENTER to naopak odesle, ostatni znaky se vkladaji na misto kurzoru. Pokud zadavane znaky presahnou hodnotu max, znak se bude ignorovart a zavola se slovo BEEP
;; - bude cist klavesy vstupujici prez KEY ( -- c ) ktere vraci bud nulu (pokud neni zatim dostupny znak), nebo znak 
;; - bude pouzivat buffer AIB (Accept Input Buffer) o delce TCB_AIB_max znaku (ktery je zarucene minimalne tak velky jako pozadovany max)
;; - bude zobrazovat zatim  zadane znaky pomoci slov CURSOR_XY (x y -- ) (presune kurzor na dane souradnice) a EMIT (c -- ) zobrazi znak a posune kurzor
;; - zobrazovani zacina na souradnicich danymi konstantami PROMPT_X PROMPT_Y a pokracuje od toho mista doprava. 
;; - nejspis bude potreba dalsich pomocnych slov, ktera je potreba taky navrhnout
;; Je takoveto zadani dostatecne, nebo potrebuje jeste neco upresnit?
;; ChatGPT said:
;; 
;; Krátká odpověď: zadání je hodně dobré a implementovatelné, ale pár drobností by stálo za to upřesnit, jinak se člověk při psaní ACCEPTu bude muset domýšlet detaily (a v FORTHu to často znamená rozdílné chování).
;; 
;; Půjdu bod po bodu a řeknu, co je jasné a kde jsou mezery.
;; Co je už teď jasné 👍
;; 
;; Tohle je specifikované velmi slušně:
;; 
;;     Stack efekt:
;;     ACCEPT ( addr max -- n ) – jasné, klasické.
;; 
;;     Zdroj vstupu:
;;     KEY ( -- c ), vrací 0 pokud nic není → implicitně polling.
;; 
;;     Editace:
;; 
;;         DEL, BACKSPACE
;; 
;;         ← →
;; 
;;         ESC = smaže celý řádek
;; 
;;         ENTER = potvrzení
;; 
;;         vkládání na pozici kurzoru
;; 
;;     Limit délky:
;; 
;;         při překročení max znak ignorovat + BEEP
;; 
;;     Interní buffer:
;; 
;;         AIB, délka TCB_AIB_max
;; 
;;         garantováno TCB_AIB_max >= max
;; 
;;     Zobrazení:
;; 
;;         výstup přes CURSOR_XY a EMIT
;; 
;;         začátek na (PROMPT_X, PROMPT_Y)
;; 
;;         vykreslování doprava
;; 
;; Tohle všechno je z pohledu návrhu ACCEPTu zcela dostatečné.
;; Co bych ještě upřesnil (jinak budou „implementační domněnky“) ⚠️
;; 1️⃣ Přesné kódy kláves
;; 
;; Tohle je největší díra.
;; 
;;     Jaké hodnoty vrací KEY pro:
;; 
;;         BACKSPACE
;; 
;;         DEL
;; 
;;         ESC
;; 
;;         ENTER
;; 
;;         ← →
;; 
;; Např.:
;; 
;;     BACKSPACE = 8?
;; 
;;     DEL = 127?
;; 
;;     ENTER = 13, 10, nebo obojí?
;; 
;;     Šipky = ANSI sekvence (ESC [ D, ESC [ C), nebo už zjednodušené kódy?
;; 
;; Bez toho:
;; 
;;     buď musí ACCEPT parsovat escape sekvence
;; 
;;     nebo předpokládat „magické konstanty“
;; 
;; 👉 Doporučení:
;; Buď:
;; 
;;     přesně vypsat kódy
;;     nebo
;; 
;;     říct „KEY už vrací normalizované kódy (např. K_LEFT, K_RIGHT…)“
;; 
;; 2️⃣ Chování kurzoru na krajích řádku
;; 
;; Co se má stát když:
;; 
;;     kurzor je na začátku a:
;; 
;;         BACKSPACE?
;; 
;;         ← ?
;; 
;;     kurzor je na konci a:
;; 
;;         → ?
;; 
;;     DEL na posledním znaku?
;; 
;; Ignorovat? BEEP? Nic?
;; 
;; Tohle je drobnost, ale bez rozhodnutí vznikne chaos.
;; 3️⃣ Způsob překreslování řádku
;; 
;; Dvě možnosti:
;; 
;;     plné překreslení celé AIB při každé změně
;; 
;;     inkrementální (posouvání znaků, mazání, dopisování)
;; 
;; Není nutné to přikazovat, ale je dobré říct:
;; 
;;     „ACCEPT je zodpovědný za konzistentní zobrazení řádku“
;; 
;; Jinak není jasné, zda např. po DELETE má:
;; 
;;     ručně smazat znak na obrazovce
;; 
;;     nebo překreslit celý řádek
;; 
;; 4️⃣ Po ENTER – co se stane s kurzorem?
;; 
;; Např.:
;; 
;;     zůstane na konci řádku?
;; 
;;     skočí na nový řádek?
;; 
;;     ACCEPT kurzor vůbec neřeší dál?
;; 
;; Tohle je maličkost, ale v REPLu dost viditelná.
;; 5️⃣ Kopírování z AIB do cílové adresy
;; 
;; Je jasné, že:
;; 
;;     po ENTER se:
;; 
;;         n znaků z AIB přesune na addr
;; 
;;         vrátí se n
;; 
;; Ale:
;; 
;;     kopírují se znaky přesně v pořadí v bufferu? (asi ano)
;; 
;;     bez nulového terminátoru? (asi ano, FORTH-style)
;; 
;; Stačí jednou větou potvrdit.
;; Shrnutí
;; 
;; 👉 Ano, zadání je v zásadě dostatečné a dává smysl.
;; 👉 Na implementaci ACCEPTu včetně editace úplně stačí.
;; 
;; Ale pokud to má být:
;; 
;;     školní úloha
;; 
;;     referenční implementace
;; 
;;     nebo základ pro další systém
;; 
;; pak bych doporučil doplnit hlavně:
;; 
;;     kódy kláves (nebo jejich abstrakci)
;; 
;;     chování na krajích řádku
;; 
;;     co přesně dělat s kurzorem po ENTER
;; 
;; Chceš-li, můžu:
;; 
;;     navrhnout konkrétní pomocná slova (MOVE-CURSOR, INSERT-CHAR, DELETE-CHAR…)
;; 
;;     nebo rovnou navrhnout strukturu AIB a stavového stroje ACCEPTu
;; 
;;     nebo napsat kostru kódu ve FORTHu (čistě logiku, bez vazby na HW)
;; 
;; Stačí říct, kam chceš jít dál 
;; 
;; 
;; You said:
;; 
;; - sipky uz budou zjednodusene kody, ENTER bude jen jeden znak, 
;; - KEY vraci uz normalizovane kody K_DEL, K_ENTER, K_LEFT a podobne, definovane nekde drive (dopisu je az pozdeji, spolu s ostatnim)
;; - kurzor na zacatku a K_BACKSPACE nebo K_LEFT znamena zavolat BEEP a ignorovat pohyb/akci, stejne tak K_RIGHT a K_DEL na konci radku
;; - ACCEPT je zodpovedny za prekreslovani radku, je jedno, zda ho po kazde zmene prekresly cely, nebo jen nezbytnou cast, ale musi nakonec umistit kurzor na spravne misto pomoci CURSOR_XY (na misto, kam se vlozi dalsi normalni znak) Na konci radku (max) bud zustane na poslednim znaku, nebo o jedno pole za nim
;; Po ENTER se ACCEPT o kurzor ani o radek uz nemusi starat, na zacatku ACCEPT zacina s prazdnym radkem/bufferem (cili jen da kurzor na prvni pole)
;; Znaky se kopiruji v poradi v bufferu, bez nuloveho terminatoru (FORTH-style), adresu zna volajici, pocet dostane na zasobniku
;; 
;; Jde o rozsireni mojeho hobby projektu, kdy pisu FORTH pro atmega2560, uz mam vyresene jednotne ukazatele pro RAM i FLESH (a vyhledove i externi uloziste), jednoduche cteni znaku a jejich odesilani (prez Serial) taky chodi, FORTH uz umi radu primitiv a pridavam dalsi (zaklad slovniku je ve FLESH, pridavani slov je do RAM ale diky jednotnym 24bit ukazatelum je celkem jedno co kde je (pokud se nepise do FLASH, samozrejme)), CELL jsou 3 byty (24bitu), takze se do nich vejde ukazatel kamkoli a pro bezne vypocty to staci s rezevou. FORTH mi spravne interpretuje slova jak ve FLASH, tak i v RAM, ale ted potrebuju mit moznost s nim interagovat. Tedy ten ACCEPT, ktery bude davat data pro WORD.
;; 
;; Takze potrebuju slovo ACCEPT, pripadne vsechna dalsi slova, ktera bude pouzivat, pokud mozno ve FORTHu, ale klidne muzu pridat i primitiva na cokoli bude potreba.
;; 
;; 
;; 
;; ChatGPT said:
;; 
;; Tohle už je velmi dobře dočištěné zadání 
;; V téhle podobě je ACCEPT jednoznačně definovatelný a hlavně rozumně implementovatelný i čistě ve FORTHu, s minimem (nebo nulou) nových primitiv.
;; 
;; Níže ti:
;; 
;;     potvrdím, že je zadání kompletní
;; 
;;     navrhnu vnitřní model ACCEPTu (stav, proměnné)
;; 
;;     navrhnu sadu pomocných slov
;; 
;;     naznačím řídicí smyčku ACCEPTu (FORTH-style pseudokód)
;; 
;; 1️⃣ Zadání – verdikt
;; 
;; 👉 Ano, teď už je zadání dostatečné.
;; Dokonce bych řekl „učebnicově čisté“.
;; 
;; Máš:
;; 
;;     normalizované klávesy
;; 
;;     jasné chování na hranách
;; 
;;     jasnou odpovědnost za vykreslování
;; 
;;     jasný životní cyklus kurzoru
;; 
;;     jasný kontrakt vůči WORD
;; 
;; Tohle je přesně ten level, kdy se dá ACCEPT napsat bez improvizace.
;; 2️⃣ Vnitřní model ACCEPTu
;; 
;; Doporučený minimální stav (v RAM):
;; 
;; AIB        \ adresa bufferu
;; TCB_AIB_len    \ aktuální délka textu (0 .. max)
;; TCB_AIB_cur    \ pozice kurzoru (0 .. TCB_AIB_len)
;; TCB_AIB_max    \ maximální povolená délka (parametr ACCEPTu)
;; 
;; Invarianta:
;; 
;; 0 <= TCB_AIB_cur <= TCB_AIB_len <= TCB_AIB_max
;; 
;; Kurzor na obrazovce:
;; 
;; x = PROMPT_X + TCB_AIB_cur
;; y = PROMPT_Y
;; 
;; 3️⃣ Pomocná slova (návrh API)
;; 🔹 Práce s kurzorem
;; 
;; 
;; : PLACE-CURSOR ( -- )
;;    TCB_AIB_cur @ PROMPT_X + PROMPT_Y 
;;    CURSOR_XY ;
;; 
;; 🔹 Překreslení řádku
;; 
;; Doporučuju jednoduché plné překreslení – je to čitelné a na ATmeze to bohatě stačí.
;; 
;; : DRAW-AIB ( -- )
;;    PROMPT_X PROMPT_Y CURSOR_XY
;;    AIB TCB_AIB_len @ 0 ?DO
;;       DUP I + C@ EMIT
;;    LOOP
;;    DROP
;;    \ vymazat zbytek po konci (pokud se mazalo)
;;    TCB_AIB_len @ TCB_AIB_max @ ?DO
;;       BL EMIT
;;    LOOP
;;    PLACE-CURSOR ;
;; 
;; 🔹 Vkládání znaku
;; 
;; : AIB-INSERT ( c -- )
;;    TCB_AIB_len @ TCB_AIB_max @ = IF
;;       DROP BEEP EXIT
;;    THEN
;;    \ posun doprava
;;    AIB TCB_AIB_cur @ +        \ dst
;;    AIB TCB_AIB_cur @ + 1+     \ src
;;    TCB_AIB_len @ TCB_AIB_cur @ -  \ count
;;    MOVE
;;    \ vloz znak
;;    AIB TCB_AIB_cur @ + C!
;;    1 TCB_AIB_cur +!
;;    1 TCB_AIB_len +! ;
;; 
;; 🔹 Backspace
;; 
;; : AIB-BACKSPACE ( -- )
;;    TCB_AIB_cur @ 0= IF
;;       BEEP EXIT
;;    THEN
;;    -1 TCB_AIB_cur +!
;;    AIB-DELETE ;
;; 
;; 🔹 Delete
;; 
;; : AIB-DELETE ( -- )
;;    TCB_AIB_cur @ TCB_AIB_len @ = IF
;;       BEEP EXIT
;;    THEN
;;    AIB TCB_AIB_cur @ + 1+     \ src
;;    AIB TCB_AIB_cur @ +        \ dst
;;    TCB_AIB_len @ TCB_AIB_cur @ - 1-  \ count
;;    MOVE
;;    -1 TCB_AIB_len +! ;
;; 
;; 🔹 Pohyb kurzoru
;; 
;; : CURSOR-LEFT ( -- )
;;    TCB_AIB_cur @ 0= IF BEEP ELSE -1 TCB_AIB_cur +! THEN ;
;; 
;; : CURSOR-RIGHT ( -- )
;;    TCB_AIB_cur @ TCB_AIB_len @ = IF BEEP ELSE 1 TCB_AIB_cur +! THEN ;
;; 
;; 🔹 Escape (vymazat vše)
;; 
;; : AIB-CLEAR ( -- )
;;    0 TCB_AIB_len !
;;    0 TCB_AIB_cur ! ;
;; 
;; 4️⃣ Řídicí smyčka ACCEPTu
;; 
;; Přehledně, bez magie:
;; 
;; : ACCEPT ( addr max -- n )
;;    TCB_AIB_max !
;;    AIB-CLEAR
;;    PROMPT_X PROMPT_Y CURSOR_XY
;; 
;;    BEGIN
;;       KEY ?DUP IF
;;          CASE
;;             K_ENTER      OF LEAVE ENDOF
;;             K_LEFT       OF CURSOR-LEFT ENDOF
;;             K_RIGHT      OF CURSOR-RIGHT ENDOF
;;             K_BACKSPACE  OF AIB-BACKSPACE ENDOF
;;             K_DEL        OF AIB-DELETE ENDOF
;;             K_ESC        OF AIB-CLEAR ENDOF
;;             \ default: normalni znak
;;             DUP AIB-INSERT
;;          ENDCASE
;;          DRAW-AIB
;;       THEN
;;    AGAIN
;; 
;;    \ kopirovani do cilove adresy
;;    DUP                 \ addr
;;     AIB TCB_AIB_len @ MOVE
;;     DROP
;;    TCB_AIB_len @ ;
;; 
;; (Detaily stacku si doladíš podle své konvence, ber to jako strukturu.)
;; 5️⃣ Poznámka k ATmega2560 & 24bit CELL
;; 
;; Upřímně:
;; 👉 CELL = 3 bajty je krásné řešení
;; a jednotné ukazatele RAM/FLASH jsou přesně to, co klasický FORTH nikdy pořádně nevyřešil.
;; 
;; U ACCEPTu to máš výhodu:
;; 
;;     AIB je v RAM
;; 
;;     MOVE / C@ / C! pracují nad jednotným adresním prostorem
;; 
;;     WORD už jen žere data
;; 
;; Nic z toho tě nelimituje.
;; Závěr
;; 
;;     ✅ Zadání je teď kompletní
;; 
;;     ✅ ACCEPT jde napsat převážně ve FORTHu
;; 
;;     ⚠️ Jediné primitivum navíc, které se fakt hodí: MOVE (pokud ho ještě nemáš)
;; 
;; Jestli chceš:
;; 
;;     můžeme to zkonkretizovat do skutečného kódu pro tvůj FORTH
;; 
;;     nebo se podívat rovnou na WORD, ať ACCEPT a WORD do sebe zapadnou bez lepidla
;; 
;;     případně optimalizovat redraw (inkrementální update)
;; 
;; Tenhle projekt zní fakt pěkně nerdovsky 💙
;; 
;; 
;; */
