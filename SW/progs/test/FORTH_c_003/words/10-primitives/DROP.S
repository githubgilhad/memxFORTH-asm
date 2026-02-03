; .. vim: ft=asm showbreak=--»\  noexpandtab fileencoding=utf-8 nomodified   wrap textwidth=0 foldmethod=marker foldmarker={{{,}}} foldcolumn=4 ruler showcmd lcs=tab\:|- list tabstop=8 noexpandtab nosmarttab softtabstop=0 shiftwidth=0 linebreak  

DEFWORD w_DROP,			0,		"DROP",			f_DROP			; ( a -- ) DROP top of stack
DEFWORD w_2DROP,		0,		"2DROP",		f_2DROP			; ( a a -- ) 2DROP top of stack
DEFWORD w_NDROP,		0,		"NDROP",		f_NDROP			; ( xn .. x1 n -- ) DROP N items from top of stack
DEFWORD w_DROPat,		0,		"DROP@",		f_DROPat		; ( xn .. x1 n -- xn-1 .. x1) DROP item at place n (n>2) (1=DROP, 2=NIP)
DEFWORD w_NIP,			0,		"NIP",			f_NIP			; ( a b -- b ) DROP second item in stack

.section CURRENT_TEXT_SECTION,"ax",@progbits
gfunc f_DROP	; {{{ #
	PopST TOS
	rjmp NEXT
	; }}}
gfunc f_2DROP	; {{{ #
	PopST TOS
	PopST TOS
	rjmp NEXT
	; }}}
gfunc f_NDROP	; {{{ #
	Set3  Parsx, TOS
	ldi   Temp,1
	breq3 Parsx, 1f
2:
	PopST TOS
	Sub31 Parsx,Temp
	brne 2b
1:
	rjmp NEXT
	; }}}
gfunc f_DROPat	; {{{ #

			; ( xn .. x1 n -- xn-1 .. x1) drops item at place n (n>2) 
			; Priklad  ( x5 x4 x3 x2 x1  3 -- x5 x4 x2 x1 ) je potreba vyhodit x3
			; 3 je v TOS (a spotrebujeme ho)
			; DST (DataSTack) ukazuje na spodek x1
			; potrebuju ukazatel na vrsek x3 jako cile a vrsek x2 jako zdroje, pak presunout 2 prvky (=6 byte)
; A - nastavim dest registr X na DST + (TOS * 3 -1) tedy vrsek x3
	Set2  Parsx2, TOS2
	Add2 Parsx2, TOS2
	Add2 Parsx2, TOS2 ; TOS*3
	ldi Temp,1
	Sub21 Parsx2,Temp ; -1
	Add2 Parsx2, DST ; + DST
	Set2 XL,XH,Parsx2 ; do X
	
; B - nastavim source registr Z na DST + ((TOS-1) * 3 -1) tedy vrsek x2
	ldi Temp, 3
	Sub21 Parsx2,Temp ; -3
	Set2 Zx2,Parsx2  ; do Z
	
; C - budu kopirovat (TOS-1) = 2 prvky, tedy 6 byte (x2 a x1) pomoci lds Temp,Z+; sts X+,Temp
	ldi Temp, 1
.f_DROPat.loop: 
	Sub21 TOS2, Temp ; decrement TOS
	breq2 TOS2, .f_DROPat.end ; jump to end, if TOS==0
	
	ld r0,Z+
	st X+,r0
	
	ld r0,Z+
	st X+,r0
	
	ld r0,Z+
	st X+,r0
	
	rjmp .f_DROPat.loop
	
.f_DROPat.end: ; all items moved
	
; D - pak upravim DST (zvysim o CELL, tedy 3) a nactu TOS (tedy x1, DST se pritom taky zvysi)
	ldi Temp, 3
	Add21 DST, Temp ; move DST up
	
	PopST TOS ; get new TOS, move DST up again
	
	rjmp NEXT
	; }}}
gfunc f_NIP	; {{{ #
	PopST Parsx
	rjmp NEXT
	; }}}


/*
Pouziju DROP@.
potrebuju vymyslet, jak ten DROP@ udelat

Pisu si svoji verzi  FORTH2012 v asembleru
HW je atmega2560, takze zarovnavat neni potreba (cokoli jde cist odkudkoli)
CELL je 3 byte = 24 bitu = P24
Top of Stack je v registrech TOS
Registry DST ukazuji na spodek dalsi CELL
Registry Parsx jsou volne
Registr Y se nesmi zmenit, registry X a Z jdou pouzit

 ( xn .. x1 n -- xn-1 .. x1) drops item at place n (n>2) 
Priklad  ( x5 x4 x3 x2 x1  3 -- x5 x4 x2 x1 ) je potreba vyhodit x3
3 je v TOS (a spotrebujeme ho)
DST (DataSTack) ukazuje na spodek x1
potrebuju ukazatel na vrsek x3 jako cile a vrsek x2 jako zdroje, pak presunout 2 prvky (=6 byte)
A - nastavim dest registr X na DST + (TOS * 3 -1) tedy vrsek x3
B - nastavim source registr Z na DST + ((TOS-1) * 3 -1) tedy vrsek x2
C - budu kopirovat (TOS-1) = 2 prvky, tedy 6 byte (x2 a x1) pomoci lds Temp,Z+; sts X+,Temp
D - pak upravim DST (zvysim o CELL, tedy 3) a nactu TOS (tedy x1, DST se pritom taky zvysi)

A - 
Set3  Parsx, TOS
Add3 Parsx, TOS
Add3 Parsx, TOS ; TOS*3
ldi Temp,1
Sub31 Parsx,Temp ; -1
Add3 Parsx, DST ; + DST
Set3 X,Parsx ; do X

B -
ldi Temp, 3
Sub31 Parsx,Temp ; -3
Set3 Z,Parsx ; do Z

C -
ldi Temp, 1
loop: 
Sub31 TOS, Temp ; decrement TOS
breq3 TOS, end ; jump to end, if TOS==0

lds Temp2,Z+
sts X+,Temp2

lds Temp2,Z+
sts X+,Temp2

lds Temp2,Z+
sts X+,Temp2

rjmp loop

end: ; all items moved

D -
ldi Temp, 3
Add31 DST, Temp ; move DST up

PopST TOS ; get new TOS, move DST up again




===================================


TOS na zacatku obsahuje n, ktere potrebuji k vypocitani adres a pak jako citac pruchodu smyckou - tedy pri pruchodu smyckou uz muzu jeho hodnotu menit, po skonceni pruchodu uz TOS "neobsahuje nic platneho"
po skonceni smycky a inkrementaci DST se TOS znova naplni nactenim x1 ze zasobniku (x1 bude vrsek zasobniku)
DST se musi v dusledku zvednout o 2, protoze ze zasobniku odstranuju jednak x3 a jednak n (poradi toho odstranovaneho prvku)

Chyba 1: špatný počet iterací - ve skutecnosti spravny
pro TOS =3 delam 2 iterace
pro TOS=2 bych delal jednu
pro TOS=1 bych nedelal zadnou (zahodilo by se x1, a x2 bych nacetl do TOS)



Chyba 2: TOS už nebude použitelné
Po smyčce:
    TOS = 0
    ale v kroku D ho ještě implicitně používáš (mentálně)

Ve skutecnosti ho v kroku D pouze nactu, tedy priradim do nej novou hodnotu
*/
