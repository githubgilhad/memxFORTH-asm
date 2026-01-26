.. vim: ft=rst showbreak=--»\  noexpandtab fileencoding=utf-8 nomodified   wrap textwidth=0 foldmethod=marker foldmarker={{{,}}} foldcolumn=4 ruler showcmd lcs=tab\:|- list tabstop=8 noexpandtab nosmarttab softtabstop=0 shiftwidth=0 linebreak  


:date: 1970.01.01 00:00:00
:_modified: 1970.01.01 00:00:00
:tags: FORTH,AI
:authors: Gilhad
:summary: WORD_kecy
:title: WORD_kecy
:nice_title: |logo| %title% |logo|

%HEADER%

WORD_kecy
--------------------------------------------------------------------------------




Vstup kláves z PS/2 a/nebo Serial
================================================================================

Pisu si FORTH pro atmega2560, převážně v asembleru, trochu v C, a výhledově hlavně ve FORTH samotném. 
V tuto chvíli mám několik prvních slov (jako @ ! + - DUP DROP ...) a engine mi je dokáže provádět, stejně jako když vybuduju složené slovo ( typu DOUBLE, které volá DUP  a + ) Chodí mi komunikace po sériové lince. Chodí mi slovo EMIT (pošle znak na výstup), KEY (vrátí okamžitě další znak nebo nulu, když není dostupný) a WAIT_KEY (vrátí platný znak, s tím, že na něj případně čeká).

Teď potřebuju vymyslet, jak to chci vlastně celé koncipovat. Slovo INTERPRET bude čekat na vstup pomocí slova WORD a pokud půjde o IMMEDIATE slovo, nebo nebude kompilovat, tak slovo provede, jinak pokud půjde o slovo, tak zakompiluje adresu jeho CodeWord, pokud půjde o číslo, tak ho buď dá na zásobník, nebo zkompiluje, a jinak oznámí chybu. To je klasika, s tím problém nemám.

Ale chtel bych tam mít možnost omezené editace řádku před odesláním (v budoucnosti to bude číst HW klávesnici na úrovni PS/2 protokolu (informace o každém stisku, opakování a puštění klávesy), ale mělo by to případně číst i Seriál, nebo soubory - čili neomezeně velká a rychlá (nebo pomalá) data) tedy minimálně odmazání posledního znaku, časem i posun šipkami a vládání/mazání znaků uvnitř, v rámci nějakého bufferu s omezenou velikostí (asi 40/80/128 znaků, uvidím, kolik bude místa v RAM)

(AHA moment: sice chci přístup přez WORD s řádkovým editorem na víc slova zároveň přístup pomocí KEY pro akční hry, ale ono to vlastně nebude nikdy naráz, protože akční hra nebude volat řádkový vstup v akční fázi. Aspoň o jednu starost míň.)

WORD potřebuje nějaký buffer, kam bude ukládat znaky, dokud nedojde k odeslání řádku, potom z toho zpřístupní první slovo a při dalším volání se rozhodne, pokud je poslední znak bufferu enter, tak prostě zpracuje další slovo, jinak posune data na začátek bufferu a donačte zbytek (když třeba bude číst ze souboru a bude v něm dlouhá řádka). Pro načítání z PS/2 klávesnice a Serial bude asi používat nějaký editor řádky, který půjde následně třeba předefinovat, který bude umožňovat editaci řádky a její odeslání dřív, než se řádka začne zpracovávat. 

`chatGPT`

 Terminologie, která se osvědčila (inspirace ANS Forth)

Doporučuji převzít tyhle pojmy (i když implementace může být jiná):

🔹 TIB – Terminal Input Buffer

pevný buffer v RAM (např. 80 nebo 128 bajtů)

obsahuje aktuální řádek, který se zpracovává

🔹 >IN

index do TIB

ukazuje, kde se WORD právě nachází

🔹 #TIB (nebo LEN)

délka platných dat v TIB

Tohle ti umožní extrémně jednoduchý WORD.

3️⃣ Jak by měl fungovat WORD (doporučený model)

WORD nikdy nečte hardware. To je zásadní.

WORD:

bere znaky z TIB

ignoruje whitespace

vrátí:

adresu tokenu

délku tokenu

Pseudokód:


.. code::

	
	while >IN < #TIB and TIB[>IN] is whitespace
	    >IN++

	if >IN == #TIB
	    return 0   (žádné další slovo)

	start = >IN
	while >IN < #TIB and not whitespace
	    >IN++

	length = >IN - start
	return (start, length)


Pokud dojdeš na konec TIB → INTERPRET zavolá REFILL

4️⃣ REFILL – klíčové slovo

Tohle je přesně místo pro:

* řádkový editor
* serial
* soubory
* PS/2 klávesnici

REFILL:

naplní TIB novými daty

nastaví:

>IN = 0

#TIB = délka

vrátí:

TRUE – podařilo se

FALSE – konec vstupu (EOF)


.. code::

	
	: REFILL ( -- flag )
	   read-line-into-TIB
	   0 >IN !
	   len #TIB !
	   true ;


INTERPRET pak vypadá skoro učebnicově:


.. code::

	
	begin
	  WORD ?dup
	while
	  interpret-word
	repeat
	REFILL 0= until

5️⃣ Řádkový editor – jak ho koncipovat chytře

Tady doporučuju oddělit logiku editoru od zdroje znaků.

Editor by měl pracovat s:

vstupem typu „událost“

ne nutně znak

Např.:


.. code::

	
	struct key_event {
	    uint8_t type;   // CHAR, BACKSPACE, LEFT, RIGHT, ENTER…
	    uint8_t value;  // ASCII nebo scancode
	};


Serial:

generuje jen CHAR, BACKSPACE, ENTER

PS/2:

generuje plnou sadu událostí

Editor:

má vlastní buffer (může to být rovnou TIB)

drží:

délku

pozici kurzoru

umí:

vložit znak

smazat

posunout kurzor

při ENTER:

vrátí hotový řádek

Výhoda:
Později můžeš editor:

nahradit

vypnout

přesměrovat na soubor

6️⃣ Proč je dobré, aby WORD neposouval buffer

To, co popisuješ (posouvání dat na začátek bufferu), funguje, ale:

je to drahé (memmove v AVR 😬)

komplikuje logiku

Lepší je:

nikdy TIB neposouvat

jen řídit >IN

pokud dojdeš na konec → REFILL

U dlouhých řádků:

buď je ořízneš

nebo REFILL vrátí „pokračování“ (volitelné)

7️⃣ IMMEDIATE, kompilace, čísla – máš to správně

Tohle, co píšeš:

pokud IMMEDIATE → provést
pokud kompilace → zkompilovat CodeWord
pokud číslo → buď push, nebo LITERAL

je přesně správně.

Jediná rada:

nech WORD vracet (addr, len), ne nulou ukončený string

parsování čísla pak může být:

BASE-aware

bez kopírování

8️⃣ Shrnutí architektonického doporučení

✔ KEY je nízkoúrovňový proud
✔ Editor řádky sedí nad KEY
✔ REFILL plní TIB
✔ WORD čte jen z TIB
✔ INTERPRET nikdy neřeší hardware
✔ Žádné posouvání bufferů
✔ >IN je král



