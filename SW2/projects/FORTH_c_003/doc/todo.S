TODO funkce Read a Write jako TCB promenne
TODO konverze ESC sekveni, nebo PS/2 scan kodu na pismena/K_xxx konstanty

v ASM.S na atmega2560 bych potreboval udelat kus kodu, ktery secte dve hodnoty a pokud vysledek prekroci treti hodnotu, tak provede jeden kus kodu, zatimco pokud neprekroci, tak jiny kus kodu. Prekrocenim je mysleno jak prekroceni smerem nahoru, tak prekroceni smerem dolu. 
pracuju s 3 bytovymi signed hodnotami a potrebuju detekovat jak pripad kdy plati A<limit && A+B>=limit, tak pripad kdy A>limit && A+B<= limit




You said:
v ASM.S na atmega2560 bych potreboval udelat kus kodu, ktery secte dve hodnoty a pokud vysledek prekroci treti hodnotu, tak provede jeden kus kodu, zatimco pokud neprekroci, tak jiny kus kodu. Prekrocenim je mysleno jak prekroceni smerem nahoru, tak prekroceni smerem dolu. 
pracuju s 3 bytovymi signed hodnotami a potrebuju detekovat jak pripad kdy plati A<limit && A+B>=limit, tak pripad kdy A>limit && A+B<= limit

ChatGPT said:

Jasně – řešíš detekci překročení hranice (limit) při sčítání signed 24bit hodnot.
Tj. chceš zachytit oba případy:

    🔼 přechod nahoru: A < limit a zároveň A+B >= limit

    🔽 přechod dolů: A > limit a zároveň A+B <= limit

Hodnoty jsou 3-bytové signed (24 bit, dvojkový doplněk).
Princip řešení

Nejjednodušší a přehledné řešení:

    Spočítat S = A + B

    Porovnat:

        nejdřív A vs limit

        pak S vs limit

    Podle kombinace větví rozhodnout

Nepoužijeme overflow flag, protože neřešíš přetečení rozsahu typu, ale překročení konkrétní hranice.
Příklad rozložení registrů

A      = r16:r17:r18   ; r16 = LSB
B      = r19:r20:r21
LIMIT  = r22:r23:r24
S      = r25:r26:r27

(LSB v nižším registru, MSB nejvyšší)
1️⃣ S = A + B (24bit signed)

; S = A
mov r25, r16
mov r26, r17
mov r27, r18

; S += B
add r25, r19
adc r26, r20
adc r27, r21

2️⃣ Porovnání 24bit signed

AVR nemá 24bit compare, musí se ručně od MSB.

Signed porovnání funguje přes CP / CPC + větvení:

    BRLT → menší (signed)

    BRGE → větší nebo rovno (signed)

    BRGT

    BRLE

Makro porovnání A vs LIMIT

; compare A with LIMIT
cp   r18, r24
cpc  r17, r23
cpc  r16, r22

Totéž pro S vs LIMIT:

cp   r27, r24
cpc  r26, r23
cpc  r25, r22

3️⃣ Kompletní logika překročení

; ===============================
; Nejprve zjistíme, jestli A < LIMIT
; ===============================

cp   r18, r24
cpc  r17, r23
cpc  r16, r22
brlt A_less
brgt A_greater
rjmp NoCross        ; A == LIMIT → nemůže dojít k překročení

; ===============================
A_less:
; pokud A < LIMIT, kontrolujeme jestli S >= LIMIT

cp   r27, r24
cpc  r26, r23
cpc  r25, r22
brge Cross          ; překročeno nahoru
rjmp NoCross

; ===============================
A_greater:
; pokud A > LIMIT, kontrolujeme jestli S <= LIMIT

cp   r27, r24
cpc  r26, r23
cpc  r25, r22
brle Cross          ; překročeno dolu
rjmp NoCross

; ===============================
Cross:
; ====== KÓD PRO PŘEKROČENÍ ======
; sem vlož svůj kód
rjmp End

; ===============================
NoCross:
; ====== KÓD BEZ PŘEKROČENÍ ======
; sem jiný kód

End:

Co to dělá
Stav	Větev
A < L a S < L	NoCross
A < L a S ≥ L	Cross 🔼
A > L a S > L	NoCross
A > L a S ≤ L	Cross 🔽
A == L	NoCross
Alternativa (rychlejší varianta)

Dá se to zjednodušit matematicky:

Překročení nastane když:

(A - L) a (S - L) mají opačné znaménko

To je rychlejší varianta bez dvou větví – pokud chceš, můžu ti napsat i tu optimalizovanou verzi (méně skoků, rychlejší běh).

Pokud mi řekneš:

    jestli jsou hodnoty v registrech nebo v SRAM

    jestli je priorita rychlost nebo čitelnost

můžu ti to upravit přímo na míru pro ATmega2560.


