.. vim: ft=rst showbreak=--»\  noexpandtab fileencoding=utf-8 nomodified   wrap textwidth=0 foldmethod=marker foldmarker={{{,}}} foldcolumn=4 ruler showcmd lcs=tab\:|- list tabstop=8 noexpandtab nosmarttab softtabstop=0 shiftwidth=0 linebreak  


:date: 2026.05.22 22:23:29
:_modified: 1970.01.01 00:00:00
:tags: HMF,CPLD
:authors: Gilhad
:summary: CPLD_kecy
:title: CPLD_kecy
:nice_title: |logo| %title% |logo|

%HEADER%

CPLD_kecy
--------------------------------------------------------------------------------

Problem: kod pro CLPD ATF1504AS-10AU100

Mam projekt pro retropocitac zalozeny na HD6309 procesoru a pridavnych kartach, pripojenych prez neco, co nazyvam "SysBus" (jsou to konektory 2x32 = 64 pinu, ktere maji patici a dlouhe piny, takze se daji neomezene stosovat na sebe - prakticky budou tak asi 4: 1 CPU + 2 MHF + 1 I/O). 

SysBus obsahuje napajeni +5V (piny 1,2) a zem GND (63,64), datovou sbernici D[0..7] (piny 3..10), adresovou sbernici A[0..15] (piny 11..26), systemove signaly E, R/W , NMI,IRQ,FIRQ (piny 53,54,55,56,57), MasterReset(62) a vyber zarizeni Dev_[3..6] (58..61)

Tohle je zatim celkem klasicky setup.

Dale obsahuje dve stejne desky MHF nazvane A a B (v podstate graficka karta, PS/2, SD a "shared RAM" ovladane atmega2560) ktere maji na Sysbus vyhrazene signaly 27..52, licha cisla pro desku A, suda pro desku B.

Signaly jsou po rade S_16, HALT, READ, SHARE_DIRTY, SHARE_GRANTED, SHARE_REQUEST, S_SELECT, S_READ, S_WRITE, G_ENABLE, G_A_DIR, G_D_DIR, SHARE_SELECT, kazdy s prefixem A\_ pro liche piny a MHF_A a B\_ pro sude piny a MHF_B .

Ty MHF desky uz mam vyrobene a ozivene (vice k nim napisu niz).

Ted navrhuju zakladni desku pro CPU HD6309, na ktere bude i RAM (128 kB, ale procesor bude "videt" jen cast), VIA, ACIA, a ridici logika (zvana GLUE) slozena ze dvou ATF1504AS (64 cell kazde, 100 pinu na chipu), protoze potrebuju vic pinu pro signaly.

Prvni ATF (ATF1) dekoduje adresy, na vstupu ma adresovou sbernici od CPU (CA[0..15]) a vsechny jeho signaly (pouziva E, R/W, Reset, HALT), na vystupu generuje signaly pro SysBus (Dev_3..Dev_6), systemovou RAM+VIA+ACIA+2Dev na desce (Read, Write, Dev_0, Dev_1, Dev_2, Dev_6, Dev_7 (enable)) a MR[0..3] (Memory Region) pro druhe ATF.

Druhe ATF (ATF2) ma na vstupu data D[0..7], MR[0..3], cast adresove sbernice CA[12..15]a signaly CPU (pouziva E, R/W, Reset, HALT), generuje GA[12..16] (pro systemovou a sdilenou RAM), Dev_0 (pro EMS okna)  a MHF_A a MHF_B signaly.

.. {{{ HD6309 Memory Regions

HD6309 Memory Regions
--------------------------------------------------------------------------------

Memory Regions vypadaji takto:

.. code::

	 +-----------------------------------------------------------------------+
	 |   HD6309 Memory Regions                                               |
	 +---------------+---------------+---------------------------------------+
	 |   TYP	 | RANGE	 | CONTENT                               |
	 +---------------+---------------+---------------------------------------+
	 |   0000	 | 0000..7FFF	 | Native RAM 32K                        |
	 +---------------+---------------+---------------------------------------+
	 |   0001	 | 8000..8FFF	 | EMS1 4K                               |
	 +---------------+---------------+---------------------------------------+
	 |   0010	 | 9000..9FFF	 | EMS2 4K                               |
	 +---------------+---------------+---------------------------------------+
	 |   01xx	 | A000..A005	 | 6 GLUE registers                      |
	 +---------------+---------------+---------------------------------------+
	 |   01xx	 | A006..A01F	 | 6 GLUE registers mirrored /reserved   |
	 +---------------+---------------+---------------------------------------+
	 |   1000	 | A020..A0FF	 | Memory mapped devices [1..7] x 32 B   |
	 +---------------+---------------+---------------------------------------+
	 |   0000	 | A100..FFFF	 | Native RAM ~ ROM 23.75K               |
	 +---------------+---------------+---------------------------------------+

Typ se predava druhemu ATF, aby nepotrebovalo CA[0..15] pro detekci.

* Typ 0000 je obycejne namapovana dolni cast systemove RAM na prirozenych adresach. (Horni cast, ~ROM, naplni MHF pri startu daty, ale asi pujde normalne prepsat (nebo ATF1 pro ni proste nenastavi Write+Enable).)
* Typ 1000 jsou klasicky namapovane devices - nastavi se Read, Write a prislusny Dev_0 .. Dev_7 se stahne dolu, cili se povoli dana device.
	* Dev_0 je formalne system RAM (v mapovani devices se nepouziva a lezi tem GLUE registry)
	* Dev_1 je onboard VIA
	* Dev_2 je onboard ACIA
	* Dev_3 .. Dev_6 jsou nekde na SysBus (normalni pridavne karty)
	* Dev_7 neni zatim pouzita, ale mohlo by to byt neco na CPU desce
* Typy 0001 a 0010 jsou okna, kam je neco namapovaneho (coz urcuje ATF2 podle svych registru). ATF1 pro ne negeneruje zadny Dev_x signal, to si ridi ATF2. Namapovano muze byt
	* libovolny kus system RAM (tedy zejmena cast nad 10000, ale i oblast ROM, nebo kus pod devices, nebo i dolni RAM) - nehrozi riziko pri nasobnem mapovani, protoze se jde naraz vzdy jen jeden pozadavek na jednu z adres.
	* Shared RAM z MHF_A
	* Shared RAM z MHF_B
* Typ 01xx je vyhrazen pro GLUE registry, ktere urcuji co se ma mapovat do EMS1 a EMS2 a v jakem je to stavu a v jakem stavu jsou MHF desky
	* zatim potrebuju jen 6, ale vyhradil jsem na ne celych 32 byte, aby nasledujici zarizeni licovaly (a mozna casem bude tech registru i vic, uvidime)

.. }}}

.. {{{ Prenos dat mezi CPU a MHF

Prenos dat mezi CPU a MHF
--------------------------------------------------------------------------------


Protoze ATmega2560 pristupuje k I/O zcela jinak nez HD6309 ke sbernici, a bezi na jine frekvenci, rozhodl jsem se resit predavani dat pomoci 128 kB velke, sdilene "shared RAM" umistene na MHF desce.

Pomoci signalu na SysBus se prevadi "vlastnictvi" teto RAM mezi CPU a MHF. Kdo ji zrovna ma, muze do ni zapisovat pozadavky a cist odpovedi, s tim, ze format dat bude znam jak CPU, tak MHF a bude definovan pozdeji.

(Typicky CPU pozada o vypis STD_out, nebo VideoRAM na obrazovku a o nacteni klaves, pripadne souboru. Odpoji Shared RAM a MHF zobrazi pozadovane, vrati PS/2 buffer a nacte soubor z SD a odhlasi se. CPU zjisti, ze je RAM volna, tak si ji namapuje a zpracuje vysledky. A tak porad dokola.)

Shared RAM je da MHF desce, k SysBus je pripojena prez brany 74HC245 - jedna pro data, dve pro adresy ( G_enable aktive vsechny 3, G_A_DIR nastavuje smer pro adresy (2chipy), G_D_DIR pro data (1chip)), 16. bit se prenasi prez x_S_16 signal, ovlada se prez x_SELECT, x_s_READ a x_S_WRITE (tedy ji vlastne ovlada plne druhe ATF)

Pokud ji zrovna vlastni ATmega, jsou brany odpojeny, pozada  si ATF o spravne nastaveni signalu, zatimco data D[0..7], adresy A[0..15] a S_16 si nastavi prev vlastni GPIO piny lokalne. ATmega ji ovlada klasicky "tahanim za piny" jako ostatni zarizeni.

Pokud ji vlastni CPU, ma ATmega piny v HiZ stavu (INPUT) a o jejich hodnoty se nestara. Brany jsou otevreny a ATF manipuluje adresove signaluy GA[12..16], takze se jevi v jednom ci obou EMS oknech.

Vysledkem je, ze CPU pristupuje k shared pameti svym prirozenym zpusobem.

Vysledny mechanizmus umoznuje prenaset az 128 kB dat naraz - prepnutim vlastnictvi shared RAM - rychlost je pak dana tim, jak rychle to jedna strana zvladne generovat a druha cist. Zatimco jedna strana generuje data, druha muze volne pracovat. Pro cteni to plati podobne.

.. }}}

Signaly
--------------------------------------------------------------------------------

* ~{A_HALT}	 - Low = MHF pozaduje Halt CPU
* A_READ (~{write}) - High = MHF chce cist ( pri A_HALT systemovou RAM); Low = chce zapisovat (stejne jako CPU R/~{W})
* ~{A_SHARED_SELECT}	Low = sdilet Shared RAM, High = NEsdilet Shared RAM (active low)
* ~{A_G_ENABLE}		Low = Gates Enabled
* A_G_A_DIR		Low = from CPU to MHF, High = from MHF to CPU ( Address lines )
* A_G_D_DIR		Low = from CPU to MHF, High = from MHF to CPU ( Data lines )
* A_SHARED_DIRTY	pullup High, libovolna strana ho muze aktivne tahnout dolu, nebo cist (funguje obousmerne). Po zmene majitele se pusti, jak prejde nahoru, tak se vymaze DIRTY priznak u noveho majitele, jak pote prejde dolu, tak se DIRTY nastavi

* ~{HALT}	- Low = CPU zastavi na konci instrukce  na neomezenou dobu, nastavi BA nahoru na znameni, ze sbernice jsou HiZ, necha dal bezet E a Q (takze hodiny jdou) a reset se latchuje, takze pokud behem HALT bude reset aspon chvilku dole, tak po skonceni HALT se CPU zresetuje.
* BA		High = Bus Acknowlegde - bus je HiZ

Registry
--------------------------------------------------------------------------------

* A000: EMS1.Page Register 
	* Write: aa0bbbbb (zdroj, 4k adresa)
	* Read: aa0bbbbb (zdroj, 4k adresa) - naposledy zapsana data
* A001: EMS1.Status Registr
	* Read: 0000wm0c
	* Write: invalid, zapis se ignoruje
* A002: EMS2.Page Register 
* A003: EMS2.Status Registr
* A004: Chip_A Status Register (abych se mohl ptat na MHF stav, kdyz jeho pamet zrovna nevlastnim)
	* Read: 000dwmac
	* Write: invalid, zapis se ignoruje
* A005: Chip_B Status Register (abych se mohl ptat na MHF stav, kdyz jeho pamet zrovna nevlastnim)
	* Read: 000dwmac
	* Write: invalid, zapis se ignoruje

Page:

* aa0bbbbb
* aa je zdroj:
	* 00 SystemRAM
	* 01 MHF_A
	* 10 MHF_B
	* 11 Error/undefined
* bbbbb je hornich 5 bitu adresy (urcuje 4 kB blok b bbbb xxxx xxxx xxxx kde dolnich 12 bitu x jde z CPU)

Status:
* EMS:
	* 0000w00c
	* c = 1 znamena, ze pocitac tu pamet vlastni (c = 0 ze nevlastni)
	* w = 1 znamena, ze MHF tu pamet chce (A_SHARE_REQUEST = 1)
* Chip
	* 000dwmac
	* c = 1 znamena, ze pocitac tu pamet vlastni (c = 0 ze nevlastni)
	* a = 1 znamena, ze MHF tu pamet vlastni (a = 0 ze nevlastni) ac=00 jeden se vzdal a druhy zatim nestihnul zareagovat
	* w = 1 znamena, ze MHF tu pamet chce (A_SHARE_REQUEST = 1) - typicky jako reakce na to, ze jsem zapsal, nebo prisla nova data
	* d = 1 znamena, ze je pamet DIRTY ( tedy do ni MHF cosi zapsalo) (nebo si ji aspon pripojilo) - pokud dam pozadavek, nechci pamet zpet driv, nez do ni MHF aspon nahledne

Hodnoty oznacene 0 (napr. bit 5 page registru) nejsou pouzite, tedy je neni nutno ukladat.

Start systemu
--------------------------------------------------------------------------------

Ve zkratce: Po zapnuti/resetu MHF_A naplni do systemRAM obsah "ROM" casti, zatimco drzi CPU v HALT stavu. Kdyz je systemRAM naplnena, uvolni HALT a CPU se rozebehne a bezi dal normalne.

.. {{{ Hardware

Hardware
================================================================================


Zde je zapojeni HALT systemu na CPU desce:

.. code::

	
	 +5V ------ 3k3 --------------------+--> Halt HD6309
	                                    |
	                                    +-----------------< Halt ATF2

Halt CPU je plne rizen ATF2, pullup 3k3 je spis jen formalni. (Pokud by v budoucnu mel byt HALT rizen i jinak, ATF2 muze pin prepnout do 3-state)

Reset logika:

.. code::

	+5V ------ 10k --+------+------+-- Reset HD6309
	                 |      |      |
	                 |      |      +-- Reset CPLD
	                 |      |      |
	                1µF   RESET    +-- MasterReset ----/----+------------- Reset MHF_A
	                 |    BUTTON                            |
	                 |      |                               +------------- Reset MHF_B
	                 |      |
	GND -------------+------+

Pri startu, nebo stisknuti RESET tlacitka jde reset dolu (aktivni) a po chvili se zvedne na neaktivni hodnotu.

ATF1 a ATF2 ho maji jen jako informaci a pro vymazani registru, takze HALT drzi aktivni.

MHF_x se restartuji a postupne nabehnou.

Zapojeni pro komunikaci ATF2 a MHF_A ohledne HALT stavu:


.. code::

	+5V -----------+
	               |
	              100k
	               |
	CPLD A_Halt <--+--/--------+-----< A_Halt MHF_A
	                           |
	                          3k3
	                           |                  
	GND --------------/--------+------ GND MHF_A


Na CPU desce je pullup 100 |kOhm|, ktery drzi A_HALT nahore (neaktivni), pokud neni nic pripojeno.

Pokud je pripojeno MHF_A, tak to na na sve desce pulldown 3k3, ktery s pullupem z CPU desky vytvori delic a A_HALT je defaultne dole (aktivni, CPU stoji). MHF_A ma pri statu piny v HiZ stavu, dokud je nenastavi jinak.

Po zapnuti napajeni tedy bude CPU stat a cekat, dokud MHF_A nerekne jinak.

MHF_A se rozebehne, nastavi si vse potrebne a prevezme rizeni - nastavi A_HALT na OUTPUT a na nulu a od te chvile ho ridi.

.. }}}

.. {{{ Zapis ROM

Zapis ROM
================================================================================

* ~{HALT} je aktivni
* MHF_A nabootuje, 
	* stahne ~{A_HALT} aktivne dolu a nasledne ho ridi
		* ATF2: ~{HALT} = 0
		* HD6309: BA = 1 a pusti sbernice
	* ceka minimalne 80 taktu na HD6309 az pusti sbernici (coz nepozna, proto ceka maximum) (nejspis uz je davno dole, diky bootu a delici)
	* nastavi A_READ = 1 (cte se)
	* stahne ~{A_SHARED_SELECT} dolu (nechce shared RAM)
		* ATF2: A_SELECT = A_SHARED_SELECT
		* ATF2: !A_HALT & BA & A_SHARED_SELECT => nastavi gates od MHF do CPU ( A_G_ENABLE = 1, A_G_A_DIR = 1, A_G_D_DIR = !A_READ) (mimo HALT tento smer nelze)
		* ATF2: ~{Read} = !(E & A_READ) , ~{Write} = !(E & !A_READ) (nastavuje System RAM signaly dle MHF)
		* ATF2: GA16 = A_S_A_16 ( rozsirena adresa podle MHF )
	* Nyni muze MHF psat do SystemRAM takto:
		* ma nastaveno A_READ = 1 (cte se)
		* nastavi A_S_A_16 a A[0..15] na pozadovanou adresu (SharedAddress piny OUTPUT, na datech se objevi hodnota, kterou ignoruje)
		* nastavi A_READ = 0 (zapisuje se) (cosi, kdo vi)
			* (ATF2: dle predchoziho nastaveni se meni A_G_D_DIR, ~{Read}, ~{Write}, GA16 )
		* nastavi SharedData piny na OUTPUT a zapise hodnotu => na D[0..7] se objevi nova hodnota => zapise se do System RAM pri nejblizsim E
		* pocka, az urcite E dobehne (odpocita si svoje takty, rychlost CPU zna)
		* nastavi A_READ = 1 ( cte se)  datech se objevi prave zapsana hodnota z obou stran a neni konflikt
		* nastavi SharedData piny na INPUT/HiZ (a nemuze vzniknout konflikt)
		* pocka az E spolehlive dobehne
		* pokracuje dalsi hodnotou, az do zapsani cele ROM casti
		* nastavi SharedAddress piny na INPUT/HiZ (ctou se nahodna data a nikdo se nezajima)
	* nastavi  ~{A_HALT} aktivne nahoru a uz ho tak necha naporad
		* AFT2: A_G_ENABLE = 0 
		* HD6039: skoncil HALT, byl Reset, tedy zacne startovat, nacte FFFE a FFFF a skoci na tu adresu

.. }}}

.. {{{ Poznamka pod carou

Poznamka pod carou
================================================================================

Datasheet rika, ze pokud se stahne HALT dolu, tak HD6309 se po skonceni instrukce zastavi na neomezenou dobu, nastavi BA nahoru na znameni, ze sbernice jsou HiZ, necha dal bezet E a Q (takze hodiny jdou) a reset se latchuje, takze pokud behem HALT bude reset aspon chvilku dole, tak po skonceni HALT se CPU zresetuje. 

ATF tady reset maji jako obycejny IO pro informaci, reset je dole chvili drzeny kondenzatorem, zatimco ATF uz jede a prvni co udela je HALT, protoze A_HALT je drzeny dole napetovym delicem. 

Reset skonci az se kondenzator nabije o chvilku pozdeji.

BA budu brat jako hlavni ukazatel, zda uz bylo dosazeno HALT a driv nepujde pokracovat v zapisu. 

ATF ma jak informaci z BA, tak urcuje smer a otevreni gates, takze muze snadno zabranit tomu, aby naraz CPU bylo aktivni (BA=0) a MHF melo otevrenou branu pro adresy smerem k CPU, stejne tak jako zabranit ze CPU je aktivni a chce zapisovat a MHF ma branu pro data otevrenou a smerem k CPU. 

TODO ( tohle blokovani A_G_ENABLE pridam do podminek).

A nebude potreba oddelovat CPU pomoci 245. 

Vysledkem by melo byt, ze system nabootuje, ROM cast se zaplni a nadale jede HD6309 po svem, ale nesmi pracovat s EMSx (protoze to jeste neni dozadane)

.. }}}

Normalni beh - RAM, ROM
--------------------------------------------------------------------------------


* ~{HALT} je neaktivni = High (protoze ~{A_HALT} je neaktivni)
* AFT2: A_G_ENABLE = 0
* ATF2: ~{Read} = !(E & R/~{W}) , ~{Write} = !(E & !R/~{W}) (nastavuje System RAM signaly dle CPU)

CPU chce Shared RAM
--------------------------------------------------------------------------------

* CPU  zapise do EMSx.Page Registru pozadovanou hodnotu (CA[0..15]=registr, R/~{W} = 0, E = 1, D[0..7] = value)
	* ATF2: ulozi hodnotu do registru
	* ATF2:


