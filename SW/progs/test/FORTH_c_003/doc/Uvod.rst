.. vim: ft=rst showbreak=--»\  noexpandtab fileencoding=utf-8 nomodified   wrap textwidth=0 foldmethod=marker foldmarker={{{,}}} foldcolumn=4 ruler showcmd lcs=tab\:|- list tabstop=8 noexpandtab nosmarttab softtabstop=0 shiftwidth=0 linebreak  


:date: 2026.01.25 20:43:51
:_modified: 1970.01.01 00:00:00
:tags: FORTH
:authors: Gilhad
:summary: Uvod
:title: Uvod
:nice_title: |logo| %title% |logo|

%HEADER%

Uvod
--------------------------------------------------------------------------------

Píšu si FORTH pro ATmega2560 (s připojenou PS/2, VGA monitorem a SD kartou), který bude používaný jako SBC (single board computer), výkonově vychazí odhadem hodně zhruba jako ekvivalent ZX81.

Hardware
================================================================================

viz `MHF-002 <https://github.com/githubgilhad/MegaHomeFORTH>`__

* ATmega2560 8kB RAM, 256kB FLASH, 4kB EEPROM, 16 MHz
	* RAM read/write, nonexecutable (nazývám ji "rychlá RAM")
	* FLASH read only, executable
* External RAM - 128kB RAM
	* umožňuje rozšířit interní paměť ATmega2560 na 64kB (za cenu pomalejšího přístupu: +1 takt za každou operaci) (nazývám ji "pomalá RAM")
		* pro rozšíření se použije horních 55.5 kB, takže zbytek je souvislá oblast od adresy 0 0000 0000
	* Přístup do celého rozsahu pomocí následující sekvence (pomalé)
		* vypnout EXTMEM
		* zakázat OE a WR (nastavit obojí na 1), 
		* nastavit ALE na 1, nastavit DDRA=FF, na portA dolnich 8 bitů adresy, ALE=0
		* DDRA podle operace (r/w), nastavit XAA16 a portC na horních 9 bitů adresy, portA jsou data (bud je vystavit pro zápis, nebo přepnout na vstup pro čtení)
		* nastavit buď 
			* DDRA=00, OE=0 (pro čtení), načíst pinA, OE=1
			* DDRA=FF, WR=0 (pro zápis), zapsat portA, WR=1
		* nastavit XAA16=1
		* zapnout EXTMEM
* Shared RAM - 128kB RAM
	* umožňuje přenášet data mezi ATmega2560 a RetroPočítačem (pokud je připojen)
	* ovládá se skrze GLUE, nebo přez SBC propojky
	* Přístup do celého rozsahu
		* chip select=1, read=1, write=1
		* nastavit XS_16, PortJ a PortK na adresu
		* chipselect=0
		* podle operace
			* DDRL=00, read=0 (pro čtení), načíst pinL, read=1
			* DDRL=FF, write=0 (pro zápis), zapsat portL, write=1
		* chipselect=1
* Přímé používání External RAM a Shared RAM k běhu FORTH je silně nevýhodné kvůli času
* VGA 
	* je ošetřena v přerušení, které vykresluje řádky a zabírá asi 90% času - tedy na cokoli jiného zbývá jen asi 10%.
	* používá "textovou videoram" 40x25 znaků, kam programy prostě zapisují písmena a ty se pak zobrazí
	* pro jednotlivé řádky jde nastavit barva popředí a pozadí v "color videoram", jemnější rozlišení barev se už nestíhá
	* videoram zabírá zhruba 1kB rychlé RAM
	* časem bude víc režimů, včetně grafiky z pomalé RAM, což zabere zhruba 8kB?
* PS/2
	* je ošetřena v přerušení, plní kruhový buffer, který pak programy mohou prostě číst
* Serial
	* je ošetřen v přerušení, plní kruhový buffer, který pak programy mohou prostě číst, poskytuje kruhový buffer pro zápis
* SD karta
	* připojena pomocí SPI
	* ovládání asi pomocí `FatFs <https://elm-chan.org/fsw/ff/>`__
	* SD karta potřebuje 512 B buffer pro přenosy dat, plus něco dalšího pro FAT systém
	* předpokládá se přenos dat na PC a zpět, tedy kompatibilní FS (FAT)
	* starý způsob s číslovanými bloky asi na začátku nepoužiju (a možná časem namapuju do souborů)

Software
================================================================================

* Výhledově chci provozovat kooperativní multitasking (PS/2 + VGA, Serial, případně systémové věci), bez ochrany paměti.
* Výhledově chci mít přerušení, které bude spouštět nastavená slova (interrupt nastaví příznak, nejbližší NEXT ponechá IP a skočí do zadaného slova (zero-time interrupt) )
* Videoram a buffery zabírají dost místa, takže bych rád co nejvíc FORTHu umístil do FLASH, aby na nová slova a data zbylo co nejvic RAM.
* Pouzivam ITC - je mi sympatický a umožňuje mít slova v RAM, kde ATmega2560 nemůže spouštět kód
* CELL má velikost 24 bitů (3 byte), používá se jak pro čísla, tak pro ukazatele
	* 24 bit ukazatel může adresovat jak RAM, tak FLASH (a výhledově i (výrazně pomaleji) External RAM a Shared RAM) stejným způsobem, FORTH nerozlišuje na co ukazuje (ale do FLASH nelze zapsat)
* TOS (Top Of Stack) je uložen přímo v registrech
* Názvy
	* `primitivum` je slovo zapsané ve strojovém kódu
	* `složené slovo` je slovo vytvořené dvojtečkovou definicí
	* `fráze` je zkratka pro více slov zapsaná ve strojovém kódu
		* používá se pro urychlení provádění, protože odstraní některé mezilehlé NEXT a případně operace se zásobníkem
		* například `: 1+ 1 + ;` jde zapsat rovnou jako inkrementace TOS dvěma strojovými instrukcemi (+ následný NEXT) bez použití datového ani návratového stacku
		* ve FORTHu se běžně používají obdobná zkratková slova (zapsaná jako složená slova) pro usnadnění zápisu (refaktorizace)
* NEXT mi vychází asi na 45 instrukcí (podle toho, co je v RAM a co ve FLASH), tak bych rád pouzival co nejvic "frazi"
* Tedy to, co by se v systému s větší RAM načetlo a přeložilo pri startu, umísťuju do FLASH v přeložené podobě

FORTH složená slova můžu zakompilovat do kódu takto (P24 je makro, ktere uloží 24bit adresu do 3 byte):


.. code::

	DEFWORD w_test,		0,	"test",		f_docol, yes		// hexa : test 21 DUP + ;
		P24 w_lit_cw
		.byte 0x21,0,0
		P24 w_dup_cw
		P24 w_plus_cw
		P24 w_exit_cw

ale jakmile obsahuji definice nejake IMMEDIATE slovo (IF, smycky a podobne) tak do tech .byte to uz  rozpisuju ve tvaru po provedeni toho slova. Neni na to nejaky lepsi postup?
	TL;DR; napsat vlastni interpret, ktery bude emitovat assembler source, nebo dumpnout definici z RAM a rucne ji upravit (~export)

Rozhodnul jsem se cílit na FORTH 2012 co se jmen a vlastností týče, ale nejspíš nenaimplementuju ani základní CORE v plném rozsahu.
