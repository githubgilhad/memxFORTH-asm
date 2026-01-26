.. vim: ft=rst showbreak=--»\  noexpandtab fileencoding=utf-8 nomodified   wrap textwidth=0 foldmethod=marker foldmarker={{{,}}} foldcolumn=4 ruler showcmd lcs=tab\:|- list tabstop=8 noexpandtab nosmarttab softtabstop=0 shiftwidth=0 linebreak  


:date: 2026.01.25 23:26:58
:_modified: 1970.01.01 00:00:00
:tags: FORTH,AI
:authors: Gilhad
:summary: bios-cursor
:title: bios-cursor
:nice_title: |logo| %title% |logo|

%HEADER%

bios-cursor
--------------------------------------------------------------------------------


You said:
pisu si vlastni FORTH a jako jedno z rozsireni bude mit vystup na obrazovku, kde budou ruzne funkce jako zapnuti/vypnuti kurzoru, jeho premisteni na dane souradnice, vystup znaku na pozici kurzoru (s tim, ze se posune - klasicky teletype), smazani obrazovky, vystup retezce na dane souradnice (s tim, ze se kurzor neposune - napriklad hodiny v pravo nahore), nacteni souradnic kurzoru.
Kdyz jsem to mel v C, tak se o podobne veci staral objekt nazvany Bios, ktery na to mel sve metody.
Tady premyslim, jakou zavest jmennou konvenci pro FORTH, aby to pripadalo srozumitelne i pripadnym ctenarum
ChatGPT said:

To je hezký problém 🙂 a přesně ten typ věci, kde se ve FORTHu láme „čistota“ jazyka vs. čitelnost pro lidi z C/OO světa.

Pár principů FORTH světa, o které se můžeš opřít:

    slova jsou krátká, akční a bez zbytečné omáčky

    jmenné prostory se řeší buď:

        prefixy (CURSOR-ON)

        vocabularies / wordlisty (SCREEN CURSOR-ON)

    pomlčka je standard, podtržítka skoro nikdo nepoužívá

    pořadí slov často odpovídá stack efektu, ne gramatice věty

Varianta 1: Prefixová konvence (nejjednodušší, nejčastější)

Tohle je asi nejčitelnější a nejvíc „FORTH-friendly“ řešení.
Příklad jmen

SCREEN-CLEAR
CURSOR-ON
CURSOR-OFF
CURSOR-AT      ( x y -- )
CURSOR-GET     ( -- x y )
EMIT           ( c -- )        \ klasický teletype
EMIT-AT        ( c x y -- )    \ kurzor se nehýbe
TYPE-AT        ( addr len x y -- )

Proč je to dobré

    čte se to skoro jako API

    nehádá se to s tradičními FORTH slovy (EMIT, TYPE)

    prefix hned říká kam to patří

    žádné OO předstírání, ale pořád přehled

👉 Pokud chceš být ještě konzistentnější, můžeš dát SCREEN- všemu, co se týká obrazovky:

SCREEN-CLEAR
SCREEN-EMIT
SCREEN-EMIT-AT
SCREEN-CURSOR-ON
SCREEN-CURSOR-OFF
SCREEN-CURSOR-AT
SCREEN-CURSOR-GET

Trochu delší, ale hodně čitelné.
Varianta 2: Vocabulary / wordlist (nejčistší FORTH řešení)

Jestli chceš něco, co se blíží tvému Bios objektu, ale bez OO, tak vocabularies jsou přesně ono.

VOCABULARY SCREEN
SCREEN DEFINITIONS

: CLEAR   ... ;
: EMIT    ... ;
: EMIT-AT ... ;
: CURSOR-ON  ... ;
: CURSOR-OFF ... ;
: CURSOR-AT  ... ;
: CURSOR-GET ... ;

PREVIOUS

Použití:

SCREEN CLEAR
SCREEN CURSOR-AT
SCREEN EMIT

Výhody

    extrémně přehledné

    žádné dlouhé názvy

    čtenář hned chápe „tohle patří ke SCREEN“

Nevýhody

    ne každý FORTHista vocabularies miluje

    trochu víc magie pro nováčky

👉 Pokud cílíš i na čtenáře zvenku (C, ASM, Pascal), tohle je paradoxně hodně srozumitelné.
Varianta 3: „BIOS-like“, ale FORTHovsky

Jestli se chceš lehce odkazovat na původní koncept:

BIOS-CLEAR
BIOS-EMIT
BIOS-EMIT-AT
BIOS-CURSOR-ON
BIOS-CURSOR-OFF
BIOS-CURSOR-AT
BIOS-CURSOR-GET

Funguje, ale:

    trochu to smrdí „přeneseným OO myšlením“

    FORTH komunita to má ráda spíš ploché

Použil bych to jen pokud máš víc subsystémů (BIOS, KERNEL, FS…).
Drobná stylistická doporučení

    stavové věci: CURSOR-ON / CURSOR-OFF (ne ENABLE/DISABLE)

    pozice: AT je ve FORTHu skoro idiom

    čtení hodnot: GET nebo jen název (CURSOR@ je taky klasika!)

Např.:

CURSOR@   ( -- x y )
CURSOR!   ( x y -- )

Tohle je hodně „pravý FORTH“ a krásně krátké.
Moje osobní doporučení 🎯

Kdybych to psal já a chtěl:

    čitelnost

    FORTH ducha

    rozumný přechod z C

➡️ Vocabulary SCREEN + krátká slova uvnitř

Je to nejčistší a nejhezčí kompromis.

Pokud chceš, klidně mi napiš:

    na jakém FORTHu to běží

    jestli míříš víc na „retro HW“ nebo „moderní VM“

a můžeme doladit konvenci úplně na míru (včetně stack komentářů a idiomů).
You said:
u kurzoru budu mit souradnice (x, y), stav (on, off) , znak pro blikani (char (napriklad blok nebo podtrzitko) - stridave se pise znak z obrazovky a znak kurzoru) s rychlost blikani (time on, time off) a na vsechno tohle se budu chtit moct ptat a moct to nastavovat. Jak tohle nejak prehledne zorganizovat
ChatGPT said:

Jo, tohle už je „plnohodnotné zařízení“, ne jen pár slov 🙂
Dobrá zpráva: FORTH na to má přirozené idiomy, jen je potřeba je držet konzistentně, aby se z toho nestala změť setterů/getterů.

Zkusím ti dát jasnou strukturu, ne jen seznam jmen.
Základní myšlenka: kurzor jako stavový objekt, ale FORTHovsky

Ve FORTHu se tohle typicky řeší jako:

    jednoznačně pojmenovaný subsystém (CURSOR)

    všechny vlastnosti mají @ a !

    akce jsou slovesa

Tohle je čitelné i bez OO a zároveň velmi silné.
1️⃣ Reprezentace stavu (interně)

Interně si klidně drž strukturu / proměnné:

VARIABLE CURSOR-X
VARIABLE CURSOR-Y
VARIABLE CURSOR-STATE      \ 0 = off, 1 = on
VARIABLE CURSOR-CHAR
VARIABLE CURSOR-ON-TIME
VARIABLE CURSOR-OFF-TIME

Tohle je čistě implementační detail – ven se to nesmí provalit.
2️⃣ Jednotná konvence: @ = dotaz, ! = nastavení

Tohle je extrémně důležité pro přehlednost.
Poloha

CURSOR@      ( -- x y )
CURSOR!      ( x y -- )

CURSOR-X@    ( -- x )
CURSOR-X!    ( x -- )

CURSOR-Y@    ( -- y )
CURSOR-Y!    ( y -- )

👉 CURSOR@ / CURSOR! je pohodlné, jemnější nastavení jde přes osy.
3️⃣ Stav zapnuto / vypnuto

Tady nedělej proměnnou navenek. Použij slova:

CURSOR-ON
CURSOR-OFF
CURSOR-ON?   ( -- flag )

Tohle se čte krásně:

CURSOR-ON? IF ... THEN

4️⃣ Blikací znak

Tady se nabízí klasická dvojice:

CURSOR-CHAR@   ( -- char )
CURSOR-CHAR!   ( char -- )

Pokud chceš i pohodlné presety:

CURSOR-BLOCK
CURSOR-UNDERLINE
CURSOR-BAR

Tohle je strašně příjemné při čtení kódu.
5️⃣ Rychlost blikání (on/off čas)

Tady je důležité nezamotat se do pojmenování.
Jednoduchá varianta

CURSOR-ON-TIME@    ( -- t )
CURSOR-ON-TIME!    ( t -- )

CURSOR-OFF-TIME@   ( -- t )
CURSOR-OFF-TIME!   ( t -- )

Použití:

500 CURSOR-ON-TIME!
500 CURSOR-OFF-TIME!

Komfortní API (doporučeno)

Navíc přidej:

CURSOR-BLINK@   ( -- on off )
CURSOR-BLINK!   ( on off -- )

To je luxusní rozhraní:

300 300 CURSOR-BLINK!

6️⃣ Aktualizace kurzoru (časová logika)

Blikání nebude „magické“, někde musíš říct teď se o kurzor postarej.

CURSOR-TICK   ( -- )

Volané:

    z hlavní smyčky

    z timer ISR

    nebo při každém EMITu

Tohle slovo odděluje politiku od mechanismu – velmi FORTHové.
7️⃣ Kompletní mentální model (jak to čte cizí člověk)

Ukázkový kód:

SCREEN CLEAR

10 5 CURSOR!
CURSOR-ON
CURSOR-BLOCK
400 400 CURSOR-BLINK!

BEGIN
  CURSOR-TICK
  KEY? IF KEY EMIT THEN
AGAIN

Tohle:

    je čitelné

    nevyžaduje znalost implementace

    nepůsobí jako C přepsané do FORTHu

8️⃣ Pokud chceš ještě vyšší úroveň elegance

Použij VOCABULARY CURSOR:

CURSOR @
CURSOR !
CURSOR ON
CURSOR OFF
CURSOR CHAR@
CURSOR CHAR!
CURSOR BLINK!

Čte se to skoro jako DSL:

CURSOR ON
CURSOR BLOCK
300 300 CURSOR BLINK!

Tohle už je skoro „malý jazyk v jazyce“.
Shrnutí (tvůj checklist)

✔ stav → skrytý
✔ dotazy → @
✔ nastavení → !
✔ akce → slovesa
✔ subsystém → prefix nebo vocabulary
✔ žádné OO simulace, ale jasná struktura

Jestli chceš, příště můžeme:

    navrhnout konkrétní datovou strukturu

    řešit race conditions mezi EMIT a blikáním

    nebo udělat ASCII diagram API




