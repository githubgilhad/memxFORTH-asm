
Get responses tailored to you

Log in to get answers based on saved chats, plus create images and upload files.

Problem: kod pro CLPD ATF1504AS-10AU100

Jsem programator, nikoli navrhar CPLD, takze prevazne myslim seriove, nikoli paralelne a popisuju co chci dosahnout, nikoli jakymi presne cestami. Neco jsem konzultoval v predeslych sedankach a doplnil do popisu. Pripadne potrebne tabulky jsou popsany v textu, zkus je vygenerovat a pokud se mi nebudou libit, tak je opoznamkuju a dovysvetlim.

Mam projekt pro retropocitac zalozeny na HD6309 procesoru a pridavnych kartach, pripojenych prez neco, co nazyvam "SysBus" (jsou to konektory 2x32 = 64 pinu, ktere maji patici a dlouhe piny, takze se daji neomezene stosovat na sebe - prakticky budou tak asi 4: 1 CPU + 2 MHF + 1 I/O). 

SysBus obsahuje napajeni +5V (piny 1,2) a zem GND (63,64), datovou sbernici D[0..7] (piny 3..10), adresovou sbernici A[0..15] (piny 11..26), systemove signaly E, R/W , NMI,IRQ,FIRQ (piny 53,54,55,56,57), MasterReset(62) a vyber zarizeni Dev_[3..6] (58..61)

Tohle je zatim celkem klasicky setup.

Dale obsahuje dve stejne desky MHF nazvane A a B (v podstate graficka karta, PS/2, SD a "shared RAM" ovladane atmega2560) ktere maji na Sysbus vyhrazene signaly 27..52, licha cisla pro desku A, suda pro desku B.

Signaly jsou po rade S_16, HALT, READ, SHARE_DIRTY, SHARE_GRANTED, SHARE_REQUEST, S_SELECT, S_READ, S_WRITE, G_ENABLE, G_A_DIR, G_D_DIR, SHARE_SELECT, kazdy s prefixem A\_ pro liche piny a MHF_A a B\_ pro sude piny a MHF_B .

Ty MHF desky uz mam vyrobene a ozivene (vice k nim napisu niz).

Ted navrhuju zakladni desku pro CPU HD6309, na ktere bude i RAM (128 kB, ale procesor bude "videt" jen cast), VIA, ACIA, a ridici logika (zvana GLUE) slozena ze dvou ATF1504AS (64 cell kazde, 100 pinu na chipu), protoze potrebuju vic pinu pro signaly.

Prvni ATF (ATF1) dekoduje adresy, na vstupu ma adresovou sbernici od CPU (CA[0..15]) a vsechny jeho signaly (pouziva E, R/W, Reset, HALT), na vystupu generuje signaly pro SysBus (Dev_3..Dev_6), systemovou RAM+VIA+ACIA+2Dev na desce (Read, Write, Dev_0, Dev_1, Dev_2, Dev_6, Dev_7 (enable)) a MR[0..3] (Memory Region) pro druhe ATF.

Druhe ATF (ATF2) ma na vstupu data D[0..7], MR[0..3], cast adresove sbernice CA[12..15]a signaly CPU (pouziva E, R/W, Reset, HALT), generuje GA[12..16] (pro systemovou a sdilenou RAM), Dev_0 (pro EMS okna)  a MHF_A a MHF_B signaly.

"Registry" nazyvam 6 adres, ktere CPU muze cist  (A000..A005) a do dvou muze i psat (A000 a A002) (psani do ostatnich se ignoruje). Jsou implementovany v souladu s CPU (tedy cteni/zapis jen kdyz je E = 1 a smer urcuje R/~{W}) a presne casovani neni az tak kriticke (musi uspokojit CPU, kdy presne nastane zmena v ramci E=1 neni kriticke)

Registry nazyvam z pohledu CPU 6 adres, ktere se daji cist (a 2 z nich se daji zapisovat). Uvnitr ATF2 se uchovavaji jen pojmenovane bity (setreni macrocellami), ty zapisovane musi byt latchovane (EMSx.Page.AA a EMSx.Page.BBBBB), protoze nasledne urcuji mapovani. Ty pouze ctene muzou byt nejak generovane, ale nektere obsahuji historii (napriklad D dirty), naopak  EMSx.Status.C muze byt pocitany nejakou formuli.

AA urcuji zdroj (pouzity chip/MHF), BBBBB urcuji adresu (a zpracovava se zase jinak (jde na GA[])).

Read only znamena, ze CPU muze jen cist, pokusy o zapis se budou ignorovat. Neco z toho co CPU precte bude ze skutecneho uloziste (napr. dirty), neco muze byt vysledkem vypoctu (treba C)

Logicke rovnice neznam, ty je potreba domyslet ze slovniho zadani (a patrne take silne zredukovat, protoze ve slovnim zadani uvadim spoustu veci pro kontext a mam ho rozdelene na spoustu cest, takze nejspis tam budou nejake spolecne skupiny, ktere pujde zjednodusit)
Chip_A.C se nastavi, pokud je cip volny (!chip_a.A nema ho MHF) a CPU ho chce (aspon jedno EMSx.AA odpovida chipu) . Pokud byl predtim nastaveny, tak se nemusi nastavovat znovu (ale asi to ani neskodi). SHARE_GRANTED je vystupni signal odpovidajici stavu Chip_A.A

registry synchronní nebo asynchronní - jde o AA a BBBBB registry, mely by se vuci CPU chovat nejak rozumne prirozene, tedy nejspis zapis kdyz E high & /Write low, na presnem miste uvnitr hodinoveho cyklu moc nezalezi protoze CPU proste "udela zapis" a jeho nasledky se projevi az v dalsim hodinovem cyklu.


MR regiony jsou souvisle bloky pameti, ze kterych se generuji signaly MR[0..3]. Pokryty je cely rozsah pameti, nektere kombinace MR nejdou vygenerovat (napr 0101). 

Dev_0 je chip select pro SystemRAM. Pro adresy mimo EMS okna ho generuje ATF1 pro normalni praci s pameti, pro EMS okna ho generuje ATF2 v zavislosti na mapovani (Selected pokud je namapovana SystemRAM, NotSelected, pokud je namapovana SharedRAM).
Read/Write pro SystemRAM pri HALT ridi ATF2. Kdyz nad tim premyslim, tak kdyz ho bude ridit i mimo HALT, tak to na obvodech nestoji nic, takze ho bude ridit vsude a ATF1 ho ridit nebude.

Po resetu jsou priznaky vynulovany (nikdo nic nevlastni, nic neni dirty, wanted ..). Pokud by to slo snadno=levne bylo by hezke, aby EMS1 a EMS2 byly namapovany na SystemRAM v odpovidajicich mistech, tedy AA=00 a BBBBB odpovidajici 080000 resp 09000.

.. {{{ HD6309 Memory Regions

HD6309 Memory Regions
--------------------------------------------------------------------------------

Memory Regions generuje ATF1 a vypadaji takto:

.. code::

	 +-------------------------------------------------------------------------+
	 |   HD6309 Memory Regions                                                 |
	 +---------------+---------------+-----------------------------------------+
	 |   TYP	 | RANGE	 | CONTENT                                 |
	 +---------------+---------------+-----------------------------------------+
	 |   0000	 | 0000..7FFF	 | Native RAM 32K                          |
	 +---------------+---------------+-----------------------------------------+
	 |   0001	 | 8000..8FFF	 | EMS1 4K                                 |
	 +---------------+---------------+-----------------------------------------+
	 |   0010	 | 9000..9FFF	 | EMS2 4K                                 |
	 +---------------+---------------+-----------------------------------------+
	 |   1rrr	 | A000..A005	 | 6 GLUE registers ( rrr = regnum )       |
	 +---------------+---------------+-----------------------------------------+
	 |   1000	 | A000      	 | GLUE register 000 EMS1.Page AAxBBBBB    |
	 +---------------+---------------+-----------------------------------------+
	 |   1001	 | A001      	 | GLUE register 001 EMS1.Status xxxxxWxC  |
	 +---------------+---------------+-----------------------------------------+
	 |   1002	 | A002      	 | GLUE register 002 EMS2.Page AAxBBBBB    |
	 +---------------+---------------+-----------------------------------------+
	 |   1003	 | A003      	 | GLUE register 003 EMS2.Status xxxxxWxC  |
	 +---------------+---------------+-----------------------------------------+
	 |   1004	 | A004      	 | GLUE register 004 ChipA.Status xxxxDWAC |
	 +---------------+---------------+-----------------------------------------+
	 |   1005	 | A005      	 | GLUE register 005 ChipB.Status xxxxDWAC |
	 +---------------+---------------+-----------------------------------------+
	 |   1111	 | A006..A01F	 | GLUE registers mirrored /reserved       |
	 +---------------+---------------+-----------------------------------------+
	 |   0100	 | A020..A0FF	 | Memory mapped devices [1..7] x 32 B     |
	 +---------------+---------------+-----------------------------------------+
	 |   0011	 | A100..FFFF	 | Native RAM ~ ROM 23.75K                 |
	 +---------------+---------------+-----------------------------------------+

Typ se predava ATF2, aby nepotrebovalo CA[0..15] pro detekci.

* Typ 0000 je obycejne namapovana dolni cast systemove RAM na prirozenych adresach.
* Typ 0011 je horni cast, ~ROM, naplni MHF pri startu daty, ale asi pujde normalne prepsat (nebo ATF1 pro ni proste nenastavi Write+Enable).
* Typ 0100 jsou klasicky namapovane devices - nastavi se Read, Write a prislusny Dev_0 .. Dev_7 se stahne dolu, cili se povoli dana device.
	* Dev_0 je formalne system RAM (v mapovani devices se nepouziva a lezi tem GLUE registry)
	* Dev_1 je onboard VIA
	* Dev_2 je onboard ACIA
	* Dev_3 .. Dev_6 jsou nekde na SysBus (normalni pridavne karty)
	* Dev_7 neni zatim pouzita, ale mohlo by to byt neco na CPU desce
* Typy 0001 a 0010 jsou okna, kam je neco namapovaneho (coz urcuje ATF2 podle svych registru). ATF1 pro ne negeneruje zadny Dev_x signal, to si ridi ATF2. Namapovano muze byt
	* libovolny kus system RAM (tedy zejmena cast nad 10000, ale i oblast ROM, nebo kus pod devices, nebo i dolni RAM) - nehrozi riziko pri nasobnem mapovani, protoze se jde naraz vzdy jen jeden pozadavek na jednu z adres.
	* Shared RAM z MHF_A
	* Shared RAM z MHF_B
* Typ 1rrr je vyhrazen pro GLUE registry, ktere urcuji co se ma mapovat do EMS1 a EMS2 a v jakem je to stavu a v jakem stavu jsou MHF desky
	* rrr je cislo registru 0..5 (0..7)
	* zatim potrebuju jen 6, ale vyhradil jsem na ne celych 32 byte, aby nasledujici zarizeni licovaly (a mozna casem bude tech registru i vic, uvidime)
* pro EMS1 a EMS2 ATF1 NEgeneruje Dev_0 (generuje ho ATF2, pokud je namapovana SystemRAM)

.. }}}

.. {{{ Zakladni myslenky okolo EMS a SharedRAM

Zakladni myslenky okolo EMS a SharedRAM
--------------------------------------------------------------------------------

Jsou dve EMS oblasti, EMS1 a EMS2, chovaji se stejnym zpusobem, ale kazda ma sve registry a jsou na sobe nezavisle.
* Kazda EMSx muze mit namapovanu bud 
	* SharedRAM z MHF_A
	* SharedRAM z MHF_B
	* SystemRAM
* Kazde toto namapovani je 4 kB oblast urcena adresou zacatku na skutecnem chipu.
* Mapovani pro obe EMSx muze byt stejne, nebo se muze lisit.
* Pristup prez mapovani neni problem, CPU vzdy pristupuje nanejvys na jednu adresu jednim zpusobem takze konflikt vzniknout nemuze.
	* Pokud je do EMSx namapovana oblast "ROM", lze do EMSx normalne zapisovat a zmeny v "ROM" oblasti se projevi hned pri dalsim taktu hodin CPU.
	* Lze namapovat do jedne EMSx SharedRAM z MHF_A a do druhe EMSx SharedRAM z MHF_B a kopirovat data primo mezi nemi.
* MHF_A a MHF_B jsou HW identicke desky ktere se lisi pouze tim, ke kterym vodicum SysBus jsou pripojene. Mohou mit stejny, nebo ruzny firmware, ale predpoklada se, ze zakladni komunikacni cast bude dodrzovat stejny protokol.
	* Co je receno o MHF_A plati i o MHF_B a naopak. Mozne konflikty ohledne bootovani a uvodniho naplneni RAM si resi mezi sebou, takze zadny konflikt nevznikne.
* SystemRAM, SharedRAM na MHF_A a SharedRAM na MHF_B jsou tri samostatne chipy.
	* CPU automaticky vzdy vlastni SystemRAM.
	* SharedRAMx vlastni bud CPU, nebo prislusne MHF, nebo nikdo.
	* "Vlastni" je dano priznaky v registrech a urcuje, jake signaly odkud ovladaji dany chip a zda je pripojen s systemove sbernici, ci nikoli. CPU a MHF pristupuji k chipu ruznymi metodami (CPU nativne, MHF prez bit-banging) a nesmi k nemu pristupovat naraz.
		* GLUE ovlada signaly pro zapis, cteni a vyber chipu, stejne jako brany mezi adresovou a datovou sbernici, takze fakticky rozhoduje o tom, kdo muze s chipem manipulovat.
* Po startu systemu defaultne SharedRAMx nevlastni nikdo, neni dirty ani wanted.
	* po spusteni CPU jeho "BIOS" namapuje do EMSx jim prislusne oblasti SystemRAM, teprve potom se zacnou pouzivat.
* Predavani vlastnictvi
	* Vlastneny je vzdy cely chip, at uz je namapovan do jednoho ci dvou EMSx oken.
	* pro zmenu vlastnictvi novy majitel nejdriv o chip pozada, pak ceka, nez bude uvolnen starym majitelem, pak je mu chip prirazen a od te chvile ho muze pouzivat, dokud se ho sam nevzda.
		* cekani na uvolneni muze byt okamzite (pokud byvaly majitel uz chip nedrzi), ale klidne muze trvat i nekolik sekund (u vetsich prenosu), nebo treba i nekolik dnu, mesicu, let (coz by nastavat uz nemelo, ale v principu muze a muze to byt i spravne v nejakych divnych scenarich)
		* CPU zada o chip zapsanim zdroje do PageRegistru. Nasledne sleduje v cyklu priznak C=1
		* ATF2 sleduje, zda je chip volny a pozadovan CPU a pokud ano, nastavi u nej C=1, (CPU chip vlastni), D=1(CPU melo sanci ho precist a zapsat), a u prislusneho EMSx okna C=1 (pamet vlastni, lze pouzivat)
		* pokud CPU namapuje chip i do druheho okna, tak to probehne okamzite, protoze uz ho vlastni (a nebo obe okna cekaji stejne dlouho)
		* CPU muze sledovat bit W, jestli MHF uz chce chip pro sebe (a zareagovat na to, nebo taky ne)
		* pokud CPU odmapuje chip z okna (namapuje neco jineho), tak status ukaze nove hodnoty.
		* CPU se chipu vzda tim, ze v obou EMSx oknech bude mit namapovano neco jineho.
		* ATF2 situaci detekuje, nastavi chip_x.C=0 (chip_x.C je OR mezi (EMS_1.C & EMS_1.AA = x) a  (EMS_2.C & EMS_2.AA = x) 
		* Pokud CPU cte chip i kdyz jeste neni C=1, dostane proste "nahodne"/nedefinovane vysledky (cokoli se ocitne na sbernici) (chybovy stav, nemel by nikdy nastat)
		* ---
		* MHF o chip zada tim, ze nastavi SHARE_REQUEST
			* ATF2 na zaklade toho nastavi priznak W - wanted
		* MHF ceka, az ATF2 nastavi SHARE_GRANTED (a od te chvile chip vlastni) (ATF2 nastavi u chipu bit A)
		* MHF si nastavuje svou adresovou a datovou sbernici primo, A_16 bit, select, read a write zada na S_16, SHARE_SELECT, READ (1 read, 0 write)
		* MHF chip uvolni tim, ze SHARE_REQUEST uvolni
		* Pokud neni nasteveno SHARE_GRANTED, SHARE_DIRTY znamena, ze CPU si chip nekam namapoval. Pokud je nastaveno SHARE_GRANTED, SHARE_DIRTY znamena, ze CPU o chip zada (nastavilo PageRegister na prislusny source)
		* Pokud neni SHARE_GRANTED nastaveno, AFT2 ignoruje signaly od MHF a nenastavuje mu cteni/zapis/select/A_16 (chybovy stav, nemel by nikdy nastat)
		* MHF nema pristup k hodinam E a bezi podle svych hodin (tedy nastavuje signaly kdykoli se mu zamane). Pro pristup na SharedRAM to nehraje roli, protoze MHF si nastavuje i signaly a potrebne pauzy dodrzuje, protoze tak rychle neni, aby se zvladlo porusit. Pro zapis do SystemRAM/ROM pri HALT proste musi pockat, nez probehne aspon jede3n E-cyklus (~ 4 takty MHF), cili staci pockat 8 taktu MHF a je to v poradku.
		* ATF2 na jeho signaly reaguje "okamzite" podle toho jak stiha.
		* ATF2 udrzuje stav vlastnictvi ve svych regirtrech a rozhoduje o jeho zmenach.
		* DIRTY rika, ze protistrana (teoreticky) mela sanci si precist vsechny relevantni odpovedi a zadat vlastni dotazy (= pripojila se k chipu). Pro MHF taky souzi jako indikace ze CPU chce chip (kdyz je SHARE_GRANTED), protoze uz se nedostavalo signalnich pinu. Jeho casovani neni prakticky dulezite, pokud se zpozdi o nekolik taktu, nic se nestane (pokud bude spravna souslednost a navaznost s SHARE_GRANTED, coz nejspis bude prirozene, protoze je generuje ATF2)
* Obe ATFx maji pristup k cele systemove sbernici CPU (tedy i k BA)
* kde uvadim HiZ, myslim tim, ze tento pin na prislusnem ATFx prejde do stavu vysokeho odporu a k nemu pripojeny signal bude venku nastavovat nekdo jiny.

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

.. {{{ Signaly

Signaly
--------------------------------------------------------------------------------

* ~{A_HALT}	 - Low = MHF pozaduje Halt CPU
* A_READ (~{write}) - High = MHF chce cist ( pri A_HALT systemovou RAM); Low = chce zapisovat (stejne jako CPU R/~{W})
* ~{A_S_READ}		Low = SharedRAM da data na sbernici (cteni)
* ~{A_S_WRITE}		Low = SharedRAM nacte data ze sbernice (zapis)
* ~{A_S_SELECT)		Low = SharedRAM je aktivni/enabled
* ~{A_SHARED_SELECT}	Low = sdilet Shared RAM, High = NEsdilet Shared RAM (active low)
* ~{A_G_ENABLE}		Low = Gates Enabled
* A_G_A_DIR		Low = from CPU to MHF, High = from MHF to CPU ( Address lines )
* A_G_D_DIR		Low = from CPU to MHF, High = from MHF to CPU ( Data lines )
* A_SHARED_DIRTY	pullup High, libovolna strana ho muze aktivne tahnout dolu, nebo cist (funguje obousmerne). Po zmene majitele se pusti, jak prejde nahoru, tak se vymaze DIRTY priznak u noveho majitele, jak pote prejde dolu, tak se DIRTY nastavi

* ~{HALT}	- Low = CPU zastavi na konci instrukce  na neomezenou dobu, nastavi BA nahoru na znameni, ze sbernice jsou HiZ, necha dal bezet E a Q (takze hodiny jdou) a reset se latchuje, takze pokud behem HALT bude reset aspon chvilku dole, tak po skonceni HALT se CPU zresetuje.
* BA		High = Bus Acknowlegde - bus je HiZ

.. }}}

.. {{{ Registry

Registry
--------------------------------------------------------------------------------

* A000: EMS1.Page Register 
	* Write: AAxBBBBB (zdroj, 4k adresa)
	* Read: AAxBBBBB (zdroj, 4k adresa) - naposledy zapsana data
* A001: EMS1.Status Registr
	* Read: xxxxxWxC
	* Write: invalid, zapis se ignoruje
* A002: EMS2.Page Register 
* A003: EMS2.Status Registr
* A004: Chip_A Status Register (abych se mohl ptat na MHF stav, kdyz jeho pamet zrovna nevlastnim)
	* Read: xxxxDWAC
	* Write: invalid, zapis se ignoruje
* A005: Chip_B Status Register (abych se mohl ptat na MHF stav, kdyz jeho pamet zrovna nevlastnim)
	* Read: xxxxDWAC
	* Write: invalid, zapis se ignoruje

Page:

* x = undefined (ignored on Write, random on Read)
* AAxBBBBB
* AA je zdroj:
	* 00 SystemRAM
	* 01 MHF_A
	* 10 MHF_B
	* 11 Error/undefined
* BBBBB je hornich 5 bitu adresy (urcuje 4 kB blok b bbbb xxxx xxxx xxxx kde dolnich 12 bitu x jde z CPU)

Status:
* EMS:
	* xxxxWxxC
	* C = 1 znamena, ze pocitac tu pamet vlastni (C = 0 ze nevlastni)
	* W = 1 znamena, ze MHF tu pamet chce (A_SHARE_REQUEST = 1)
* Chip
	* xxxDWMAC
	* C = 1 znamena, ze pocitac tu pamet vlastni (C = 0 ze nevlastni)
	* A = 1 znamena, ze MHF tu pamet vlastni (A = 0 ze nevlastni) AC=00 jeden se vzdal a druhy zatim nestihnul zareagovat
	* W = 1 znamena, ze MHF tu pamet chce (A_SHARE_REQUEST = 1) - typicky jako reakce na to, ze jsem zapsal, nebo prisla nova data
	* D = 1 znamena, ze je pamet DIRTY ( tedy do ni MHF cosi zapsalo) (nebo si ji aspon pripojilo) - pokud dam pozadavek, nechci pamet zpet driv, nez do ni MHF aspon nahledne

Hodnoty oznacene x (napr. bit 5 page registru) nejsou pouzite, tedy je neni nutno ukladat, cimz se usetri nejake ty CELLs.

.. }}}

.. {{{ Start systemu 
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
		* ATF2: !A_HALT & BA & A_SHARED_SELECT => nastavi gates od MHF do CPU ( ~{A_G_ENABLE} = 0, A_G_A_DIR = 1, A_G_D_DIR = !A_READ) (mimo HALT tento smer nelze)
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
		* AFT2: ~{A_G_ENABLE} = 1 
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

TODO ( tohle blokovani ~{A_G_ENABLE} pridam do podminek).

A nebude potreba oddelovat CPU pomoci 245. 

Vysledkem by melo byt, ze system nabootuje, ROM cast se zaplni a nadale jede HD6309 po svem, ale nesmi pracovat s EMSx (protoze to jeste neni dozadane)

.. }}}

.. }}}

.. {{{ Normalni beh (static status)
Normalni beh - RAM, ROM
--------------------------------------------------------------------------------

* ~{HALT} je neaktivni = High (protoze ~{A_HALT} je neaktivni)
* ATF2: MR = 0000 => (RAM)
	* Dev_0 = HiZ (generovana ATF1)
	* AFT2: ~{A_G_ENABLE} = 1
	* ATF2: ~{Read} = !(E & R/~{W}) , ~{Write} = !(E & !R/~{W}) (nastavuje System RAM signaly dle CPU)
* ATF2: MR = 0011 => (ROM)
	* Dev_0 = HiZ (generovana ATF1)
	* AFT2: ~{A_G_ENABLE} = 1
	* ATF2: ~{Read} = !(E & R/~{W}) , ~{Write} = 1 (not active) (nastavuje System RAM signaly dle CPU, ignoruje Write)

Normalni beh - Devices ()
--------------------------------------------------------------------------------

* ~{HALT} je neaktivni = High (protoze ~{A_HALT} je neaktivni)
* ATF2: MR= 0100 =>
	* Dev_0 = HiZ
	* ~{A_G_ENABLE} = 1
	* ~{Read} = !(E & R/~{W}) , ~{Write} = !(E & !R/~{W}) (nastavuje System RAM signaly dle CPU)
	* GA_bus[12..16] = HiZ/ignored

Normalni beh - EMS1/EMS2=SystemRAM
--------------------------------------------------------------------------------

* ~{HALT} je neaktivni = High (protoze ~{A_HALT} je neaktivni)
* ATF2: MR= 0001 / MR=0010 (EMS1/EMS2.Page Register = AAxBBBBB ) AA=00 =>
	* Dev_0 = 0 (Enabled) (normalne je ATF2:Dev_0 = HiZ)
	* ~{A_G_ENABLE} = 1
	* ~{Read} = !(E & R/~{W}) , ~{Write} = !(E & !R/~{W}) (nastavuje System RAM signaly dle CPU)
	* GA_bus[12..16] = BBBBB

Normalni beh - EMS1/EMS2=MHF_A/B
--------------------------------------------------------------------------------

* ~{HALT} je neaktivni = High (protoze ~{A_HALT} je neaktivni)
* ATF2: MR= 0001 / MR=0010 (EMS1/EMS2.Page Register = AAxBBBBB ) AA=10/01 =>
	* Dev_0 = HiZ
	* Chip_A/B register.C=0
		* chyba, vse HiZ
		* ~{A_G_ENABLE} = 1 (Disabled)
		* Read = nahodna data, Write = zadna akce
	* Chip_A/B register.C=1 (OK)
		* A_G_A_DIR = Low (CPU to MHF)
		* Read Write: 
			* (E & R/~{W}) => Read =>
				* GA[12..16]=BBBBB
				* ~{A_S_SELECT} = Low (active)
				* ~{A_S_READ} = Low (active)
				* ~{A_S_WRITE} = High (NOT active)
				* A_G_D_DIR = High (MHF to CPU)
				* ~{A_G_ENABLE} = 0 (Enabled)
			* (E & !R/~{W}) => Write =>
				* GA[12..16]=BBBBB
				* ~{A_S_SELECT} = Low (active)
				* ~{A_S_READ} = High (NOT active)
				* ~{A_S_WRITE} = Low (active)
				* A_G_D_DIR = Low (CPU to MHF)
				* ~{A_G_ENABLE} = 0 (Enabled)
			* !E => nothing =>
				* ~{A_S_READ} = High (NOT active)
				* ~{A_S_WRITE} = High (NOT active)
				* ~{A_G_ENABLE} = High (NOT active)
				

.. }}}

CPU chce Shared RAM
--------------------------------------------------------------------------------

* CPU  zapise do EMSx.Page Registru pozadovanou hodnotu (CA[0..15]=registr, R/~{W} = 0, E = 1, D[0..7] = value)
	* ATF1: MR[0..3] = 1rrr
	* ATF2: ulozi hodnotu D[0..7] do registru rrr (jen potrebne bity]
	* ATF2: uvolneni vlastnictvi - zkontroluje co CPU drzi - pokud ani jeden EMSx.PageRegister nema AA=01 nastavi se u  Chip_A  C=0. Pro 10 chip_B ditto.
	* ATF2: pokud AA=01 & Chip_A.C=1 nastavi se EMSx.Status.C=1. 10 & Chip_B obdobne. Prubezne.
	* ATF2: 

Prubezne
--------------------------------------------------------------------------------
* EMSx enabled
	* ATF2: pokud AA=01 & Chip_A.C=1 nastavi se EMSx.Status.C=1. 10 & Chip_B obdobne. Prubezne.
	* ATF2: Pokud AA=00 nastavi se EMSx.Status.C=1.


Dalsi konverzace
--------------------------------------------------------------------------------


Dirty je IMHO stavovy registr. 
Jeho pravy vyznam je pro spolupraci, kdy si CPU a MHF navzajem posilaji pozadavky a odpovedi prez SharedRAM a kazdy z nich muze byt lokalne zaneprazdnen necim zcela jinym. 
Takze CPU vznese pozadavek a vzda se vlastnictvi. Pak nejakou dobu neco dela. A pak potrebuje vedet, jestli byl pozadavek splnen, nebo ma jeste cekat. A nevi, co se delo mezitim. Tak si precte DIRTY, jestli se MHF uz tomu nejak venovalo, nebo taky melo jinou praci.
Pokud je nastaveno DIRTY, MHF uz tu pamet pripojilo (a tedy precetlo a zapsalo vysledky a tak a pak se odpojilo), takze CPU o tu pamet pozada a bud ji dostane hned, nebo az se ji MHF vzda.
Pokud DIRTY nastaveno neni, tak s tim HMF jeste nic nezkusilo delat a CPU bud o pamet zadat nebude a pocka si na splneni svych pozadavku, nebo se ji naopak zmocni a sve pozadavky preformuluje, protoze vi, ze MHF je zatim necetlo.
(typicky treba pozadavek 1 CLS, Vypis "Hello world", pozadavek 2: CLS, vypis "Lorem Ipsum", revidovany pozadavek  CLS, vypis "Hello + Lorem Ipsum")
Pokud zrovna MHF chip nedrzi, CPU by bez DIRTY nevedelo, zda se k tomu jeste nedostalo, nebo uz to ma davno hotove.
Druha funkce signalu SHARE_DIRTY je signalizovat MHF, zda nahodou CPU nechce chip. (Cpu da pozadavek - cekej na klavesu a vrat hodnotu, MHF prevezme chip , precte si to a ceka. Pokud clovek zmackne klavesu, zapise ji jako vysledek a vzda se chipu. Pokud to trva dlouho a CPU chce skoncit cekani, pozada o chip, MHF uvidi tuto zadost, zapise dosud nic nezmacknuto a vzda se chipu. CPU zacne vykreslovat screensaver ...)
Znamena to, ze pokud je SHARE_GRANTED, tak se SHARE_DIRTY chova jinak, nez chipx.dirty.


Tohle je dost rozsáhlé zadání, ale myslím, že už se z něj začíná rýsovat podstatně jednodušší model, než jak vypadá při prvním čtení.

První věc, kterou bych udělal, je oddělit:

    mapování EMS oken

    vlastnictví SharedRAM

    signalizaci DIRTY/WANTED

    bus multiplexing při HALT

Protože to jsou v podstatě čtyři téměř nezávislé stroje.
1. Registry, které skutečně musí existovat

Z tvého popisu ATF2 reálně potřebuje držet:
EMS1

EMS1_SRC[1:0]    ; AA
EMS1_PAGE[4:0]   ; BBBBB

7 bitů
EMS2

EMS2_SRC[1:0]
EMS2_PAGE[4:0]

dalších 7 bitů
Chip A

A_CPU_OWN      ; Chip_A.C
A_MHF_OWN      ; Chip_A.A
A_DIRTY

3 bity
Chip B

B_CPU_OWN
B_MHF_OWN
B_DIRTY

3 bity

Celkem:

7+7+3+3 = 20 bitů

To je na ATF1504 úplně v pohodě.
2. Co není potřeba ukládat

Například:

EMSx.Status.W

není registr.

To je přímo:

EMS1_W =
   (EMS1_SRC == MHF_A & A_SHARE_REQUEST)
 | (EMS1_SRC == MHF_B & B_SHARE_REQUEST)

Stejně:

Chip_A.W = A_SHARE_REQUEST
Chip_B.W = B_SHARE_REQUEST

žádný latch.
3. EMSx.Status.C

Tohle je taky ideální kandidát na kombinaci.

Pokud:

EMS1_SRC = SystemRAM

tak

EMS1_C = 1

vždy.

Pokud:

EMS1_SRC = MHF_A

tak

EMS1_C = A_CPU_OWN

Pokud:

EMS1_SRC = MHF_B

tak

EMS1_C = B_CPU_OWN

Tedy:

EMS1_C =
   !EMS1_SRC1 & !EMS1_SRC0
 | (!EMS1_SRC1 & EMS1_SRC0 & A_CPU_OWN)
 | ( EMS1_SRC1 & !EMS1_SRC0 & B_CPU_OWN)

a analogicky EMS2.

Žádné další bity netřeba.
4. Kdo chce který chip

Tohle je důležitá redukce.

Místo přemýšlení nad EMS1 a EMS2 zvlášť si zaveď:

CPU_WANTS_A
CPU_WANTS_B

kombinační signály.

Pro A:

CPU_WANTS_A =
   (EMS1_SRC == MHF_A)
 | (EMS2_SRC == MHF_A)

Pro B:

CPU_WANTS_B =
   (EMS1_SRC == MHF_B)
 | (EMS2_SRC == MHF_B)

Tohle se bude používat úplně všude.
5. Uvolnění vlastnictví CPU

Tohle máš v textu popsané správně.

Jakmile:

CPU_WANTS_A = 0

pak:

A_CPU_OWN := 0

stejně:

CPU_WANTS_B = 0

↓

B_CPU_OWN := 0

To je vlastně automatické vzdání se chipu.
6. Přidělení CPU

Tohle je druhá strana.

Pokud:

CPU_WANTS_A
&
!A_MHF_OWN

pak:

A_CPU_OWN := 1

stejně pro B.

To odpovídá přesně tomu, co popisuješ:

    pokud je chip volný a CPU ho chce, dostane ho

7. SHARE_GRANTED

Tohle je nejhezčí část.

Ve skutečnosti:

SHARE_GRANTED_A = A_MHF_OWN
SHARE_GRANTED_B = B_MHF_OWN

hotovo.

Není potřeba další logika.
8. Přidělení MHF

Pokud:

A_SHARE_REQUEST = 1
&
!A_CPU_OWN

pak:

A_MHF_OWN := 1

Pokud:

A_SHARE_REQUEST = 0

pak:

A_MHF_OWN := 0

To vytvoří přesně handshake:

MHF:

REQUEST=1
čeká
GRANTED=1

ATF:

CPU pustil chip
↓
GRANTED=1

9. DIRTY

Tady bych byl opatrný.

Ve tvém textu DIRTY plní dvě různé role:
role 1

stavový bit

MHF se k paměti dostalo

role 2

signalizace

CPU chce chip zpět

To je zcela legitimní, ale znamená to:

Chip_A.D

není totéž jako

A_SHARE_DIRTY

Já bych uvnitř CPLD držel:

A_DIRTY
B_DIRTY

jako registry.

A pak teprve generoval pin.

Například:

Pokud

A_MHF_OWN=0

pak:

A_SHARE_DIRTY = A_DIRTY

Pokud

A_MHF_OWN=1

pak:

A_SHARE_DIRTY = CPU_WANTS_A

což přesně odpovídá tvému popisu.
10. Největší úspora makrocell

Myslím, že zásadní je uvědomit si:

Ty nepotřebuješ:

EMS1.C
EMS2.C
EMS1.W
EMS2.W
ChipA.W
ChipB.W

ukládat.

To všechno jsou kombinace.

Reálně latchované jsou pouze:

EMS1_SRC[1:0]
EMS1_PAGE[4:0]

EMS2_SRC[1:0]
EMS2_PAGE[4:0]

A_CPU_OWN
A_MHF_OWN
A_DIRTY

B_CPU_OWN
B_MHF_OWN
B_DIRTY

tedy asi 20 bitů stavu.

To je proti původní představě velmi málo.
11. Jedna věc, která mi zatím není úplně jasná

V textu střídáš dva významy bitu C:

Někdy:

Chip_A.C = CPU vlastní chip

což dává smysl.

Jindy:

    Chip_A.C se nastavi, pokud je chip volny a CPU ho chce

To by znamenalo, že je to zároveň:

CPU_OWN

i

CPU_GRANTED

Já bych doporučil držet interpretaci:

Chip_A.C = CPU_OWN
Chip_A.A = MHF_OWN

a nic dalšího.

Pak je celý ownership model velmi čistý:

00 = nikdo
01 = CPU
10 = MHF
11 = zakázaný stav

a všechny ostatní registry se od toho odvozují.

To by se mělo vejít do ATF1504 poměrně komfortně i s celou EMS logikou a HALT multiplexorem.

Mapovani EMS oken a vlastnictvi SharedRAM je dost uzce provazano logicky, protoze o vlastnicvi se zada pokusem namapovat SharedRAM do EMS okna, kdyz vlastnictvi vznikne, je to signalizovano ve stavu EMS okna, ze u je opravdu namapovane. Ale mozna ty rovnice za tim vyjdou nejak jednoduse.
HALT je v podstate kapitola sama pro sebe (CPU nebezi, tedy nepracuje s registry a nic nemapuje)
Ano, Chip_A.D není totéž jako A_SHARE_DIRTY (jen se to podobne jmenuje).
 
 - Chip_A.C = CPU vlastní chip
 - Chip_A.C se nastavi, pokud je chip volny a CPU ho chce
je oboji spravne, pokud CPU chip chce a dostane ho, tak ho vlastni a muze pouzivat.

To by znamenalo, že je to zároveň: CPU_OWN i CPU_GRANTED
Ano, vlastnik se vlastnictvi vzdava dle sveho uvazeni, tedy mezi temi stavy neni rozdil. (projekt se sklada z casti dalsich projektu a vlastni tvorby, takze nektere pojmenovani nejsou zrovna nejstastneji volene.)

Jestli to takto staci, tak zkus vygenerovat soubory pro ATF1 a ATF2, jinak se ptej dal

Ještě ne. Na úrovni architektury už ano, ale na vygenerování funkčního CUPL/JED návrhu pro ATF1504 mi chybí několik kritických detailů. Kdybych to teď napsal, byla by to spíš kostra než něco, co projde syntézou a bude odpovídat HW.

Největší problém není EMS logika. Ta je už skoro jasná. Největší problém je dekódování adres a přesné chování výstupů.
Co potřebuji upřesnit pro ATF1

Z Memory Regions chápu:
Rozsah	MR
0000-7FFF	0000
8000-8FFF	0001
9000-9FFF	0010
A000-A005	1rrr
A020-A0FF	0100
A100-FFFF	0011

Ale není úplně jasné:
1. Jak se generují Dev_1..Dev_7

Předpokládám:

A020-A03F -> Dev_1
A040-A05F -> Dev_2
A060-A07F -> Dev_3
A080-A09F -> Dev_4
A0A0-A0BF -> Dev_5
A0C0-A0DF -> Dev_6
A0E0-A0FF -> Dev_7

je to tak?
2. Dev_0 mimo EMS

Předpokládám:

0000-7FFF
A100-FFFF

↓

Dev_0 aktivní

a

8000-9FFF
A000-A0FF

↓

Dev_0 neaktivní

Je to správně?
3. ROM oblast

Psal jsi:

A100..FFFF = Native RAM ~ ROM

Pak ale později:

Write = 1 (zakázán)

Potřebuji vědět:

Varianta A:

A100-FFFF
fyzicky SystemRAM
ale zápisy blokuje GLUE

nebo

Varianta B:

A100-FFFF
normální RAM
zápisy povoleny

Tohle ovlivňuje ATF2.
Co potřebuji upřesnit pro ATF2

Tady je pár větších nejasností.
1. Jak přesně zapisovat Page Registry

Předpokládám:

A000
D7..D0 = AAxBBBBB

mapování:

D7 D6 = AA
D4..D0 = BBBBB

a

D5 ignorován

Správně?
2. Reset hodnoty

Psal jsi:

    bylo by hezke aby EMS1 a EMS2 byly namapovany na SystemRAM

Potřebuji vědět, zda to je požadavek nebo jen nápad.

Možnosti:
reset

EMS1 AA=00
EMS1 PAGE=01000

EMS2 AA=00
EMS2 PAGE=01001

nebo
reset

vše nula

3. Dirty mechanismus

Tady mám zatím největší otazník.

Psal jsi:

    po zmene majitele se pusti, jak prejde nahoru, tak se vymaze DIRTY u noveho majitele, jak pote prejde dolu, tak se DIRTY nastavi

To je vlastně asynchronní handshake.

Potřebuji vědět:

Máš v plánu přivést A_SHARE_DIRTY přímo do ATF2 jako vstup?

Tedy:

pin = bidirectional

a CPLD skutečně sleduje jeho stav?

Nebo:

DIRTY je pouze interní registr

a SHARE_DIRTY generuje CPLD.

To jsou dvě úplně jiné implementace.
4. Ownership state machine

Tohle je úplně nejdůležitější.

Když:

CPU_WANTS_A = 1
A_MHF_OWN = 0

tak:

A_CPU_OWN := 1

ok.

Ale co když:

CPU_WANTS_A = 1
A_MHF_OWN = 1

a MHF následně pustí REQUEST?

Mám chápat že:

REQUEST=0
↓
A_MHF_OWN=0
↓
A_CPU_OWN=1

automaticky v jednom kroku?

Nebo musí vzniknout mezistav:

00

a teprve další cyklus:

01

Pro CPLD je jednodušší druhá možnost.
5. Které registry mají být skutečně čitelné

Předpokládám:
A000

AAxBBBBB

vrací uloženou hodnotu
A001

xxxxxWxC

kde:

W = request příslušného MHF
C = EMS1_C

A004

xxxxDWAC

kde:

D = dirty
W = request
A = mhf own
C = cpu own

Správně?
Co mě trochu děsí

Tohle:

A_SHARED_DIRTY
pullup High
libovolna strana ho muze aktivne tahnout dolu

je klasický open-collector signál.

ATF1504 to sice umí emulovat přes OE řízení, ale dost to komplikuje návrh.

Já bych skoro doporučil interně úplně oddělit:

Chip_A.D

od

A_SHARED_DIRTY

a brát SHARE_DIRTY pouze jako fyzický synchronizační vodič mezi MHF a CPLD.

Pak bude logika mnohem čistší.

Jakmile odpovíš hlavně na:

    mapování Dev_1..Dev_7,

    ROM write-enable ano/ne,

    reset Page registrů,

    přesný význam SHARE_DIRTY pinu,

    ownership přechody,

tak už bych dokázal napsat první návrh ATF1 v CUPL a současně kostru ATF2 se stavovými registry.

 Jak přesně zapisovat Page Registry - presne takhle
Reset hodnoty - pokud to nestoji bunky navic, tak je to pozadavek
A_SHARE_DIRTY a B_SHARE_DIRTY jsou privedeny do ATF2 na piny
Vlastne to nepotrebuju bidirectional, ATF2 ho ridi plne, MHF ho jen cte

Ownership state machine: mezikrok neni nutny, ale neskodi.

Skutecne citelne maji byt registry A000..A005.
A000, A001 jsou pro EMS1
A002, A003 jsou pro EMS2
A004 je pro chip_A
A005 je pro chip_B

A_SHARED_DIRTY nebude pullup High, bude to obycejny vodic rizeny ATF2


Výborně. Tím se to hodně zjednodušilo.

Největší zjednodušení je toto:

    A_SHARED_DIRTY nebude pullup High, bude to obycejny vodic rizeny ATF2

To znamená, že vůbec nemusíme řešit open-collector, zpětné čtení pinu ani asynchronní přechody. Najednou je z toho normální stavový automat.

Ještě ale pořád chybí dvě věci, bez kterých ATF1 nejde korektně napsat:
1. Dekódování zařízení v A020-A0FF

Potvrď prosím něco ve stylu:

A020-A03F  -> Dev_1 (VIA)
A040-A05F  -> Dev_2 (ACIA)
A060-A07F  -> Dev_3
A080-A09F  -> Dev_4
A0A0-A0BF  -> Dev_5
A0C0-A0DF  -> Dev_6
A0E0-A0FF  -> Dev_7

Případně oprav.

Tohle ATF1 musí znát přesně.
2. ROM oblast

Pořád nevím, zda:

A100-FFFF

je
varianta A

RAM fyzicky, ale write zakázán

nebo
varianta B

RAM fyzicky, write povolen

Z textu jsem našel obě interpretace.

Tohle přímo ovlivňuje generování:

/Read
/Write

v ATF2.
Co už mám za prakticky definitivní

ATF2 bych dnes navrhl asi takto.
Registry
EMS1

EMS1_SRC[1:0]
EMS1_PAGE[4:0]

EMS2

EMS2_SRC[1:0]
EMS2_PAGE[4:0]

Chip A

A_CPU_OWN
A_MHF_OWN
A_DIRTY

Chip B

B_CPU_OWN
B_MHF_OWN
B_DIRTY

Celkem:

20 latch bitů

Kombinační signály

CPU_WANTS_A =
   (EMS1_SRC == MHF_A)
 | (EMS2_SRC == MHF_A)

CPU_WANTS_B =
   (EMS1_SRC == MHF_B)
 | (EMS2_SRC == MHF_B)

Ownership

CPU:

IF CPU_WANTS_A & !A_MHF_OWN
THEN A_CPU_OWN = 1

IF !CPU_WANTS_A
THEN A_CPU_OWN = 0

MHF:

IF A_SHARE_REQUEST & !A_CPU_OWN
THEN A_MHF_OWN = 1

IF !A_SHARE_REQUEST
THEN A_MHF_OWN = 0

Totéž pro B.
EMS status C

Nemusí existovat jako registr.

EMS1_C =
    SRC=SystemRAM
 OR SRC=MHF_A & A_CPU_OWN
 OR SRC=MHF_B & B_CPU_OWN

EMS status W

Také nemusí být registr.

EMS1_W =
   SRC=MHF_A & A_SHARE_REQUEST
 | SRC=MHF_B & B_SHARE_REQUEST

Chip status registr

xxxxDWAC

pak přímo:

D = A_DIRTY
W = A_SHARE_REQUEST
A = A_MHF_OWN
C = A_CPU_OWN

Co mě začíná zajímat kvůli makrocellám

ATF1504AS není malý CPLD.

Ale:

    64 makrocell

    32 produktových členů na makrocellu

přesto může být problém počet termů na výstupech.

Největší žrout podle mě nebude EMS.

Největší žrout bude:

GA[12..16]

protože budou záviset na:

MR
EMS1/EMS2
HALT
ownership
CPU/MHF režimu

a mohou skončit jako poměrně dlouhé rovnice.

Proto bych ještě před psaním CUPL zkusil nakreslit tabulku:

MR=0001
 -> EMS1_PAGE

MR=0010
 -> EMS2_PAGE

HALT&MHF access
 -> MHF_A16

a podívat se, zda některé bity GA nejdou sdílet.

To bývá místo, kde se na ATF1504 ušetří překvapivě hodně buněk.

Takže zbývá potvrdit:

    Dev_1..Dev_7 adresy.

    ROM write-enable ano/ne.

Pak už bych se pustil do konkrétní CUPL kostry ATF1.

Dekódování zařízení v A020-A0FF - potvrzuji

A100-FFFF RAM fyzicky, ale write zakázán (mimo HALT stav)
 (tedy neco jako /Write = E & HALT & !R/W se spravnou polaritou)

GA[] jsou odvozeny bud z CA[], nebo z EMSx.Page.BBBBB nebo pri HALT poskytnuty primo MHF (a ATF je ma jako HiZ a neridi je)

Teď už bych si troufl napsat ATF1 téměř celý. ATF2 ještě ne, protože tam bude potřeba rozhodnout několik implementačních detailů (hlavně jak přesně dělat registry v CUPL a jestli ownership poběží synchronně na E nebo čistě asynchronně).

Ale hlavně jsem si všiml jedné věci:

    A100-FFFF RAM fyzicky, ale write zakázán (mimo HALT stav)

To znamená, že ROM ochrana ve skutečnosti není vlastnost adresového dekodéru (ATF1), ale vlastníka sběrnice (ATF2).

To je dobře.

Pak bych to rozdělil takto:
ATF1 = čistý adresový dekodér

ATF1 vůbec neřeší:

HALT
EMS mapování
ROM ochranu
SharedRAM

Pouze:

MR[3..0]
Dev_1..Dev_7
Read
Write

a pro EMS okna negeneruje nic.
Návrh MR

Vyhovuje tvé tabulce:

0000-7FFF  -> MR=0000

8000-8FFF  -> MR=0001

9000-9FFF  -> MR=0010

A000-A005  -> MR=1rrr

A006-A01F  -> MR=1111

A020-A0FF  -> MR=0100

A100-FFFF  -> MR=0011

Registry

Pěkné je, že:

A000..A005

lze zakódovat přímo jako

MR3 = 1
MR2 = A2
MR1 = A1
MR0 = A0

pokud zároveň platí:

A15..A4 = A00h

Takže registr číslo je už přímo v MR.

To šetří piny i logiku.
Dev dekodér

Z potvrzeného mapování:

A020-A03F -> Dev_1

A040-A05F -> Dev_2

A060-A07F -> Dev_3

A080-A09F -> Dev_4

A0A0-A0BF -> Dev_5

A0C0-A0DF -> Dev_6

A0E0-A0FF -> Dev_7

lze použít:

A7 A6 A5

jako index zařízení.

To je velmi levné.
Dev_0

Myslím, že Dev_0 bych z ATF1 úplně odstranil.

Tvoje současná architektura vede k:

MR=0000 -> RAM

MR=0011 -> ROM

a v EMS případech:

MR=0001
MR=0010

rozhoduje ATF2.

Takže Dev_0 může generovat výhradně ATF2.

To odstraní jeden potenciální konflikt tristate výstupů.
Co mě zaujalo na GA[12..16]

Napsal jsi:

    GA[] jsou odvozeny bud z CA[], nebo z EMSx.Page.BBBBB nebo pri HALT poskytnuty primo MHF (a ATF je ma jako HiZ a neridi je)

To je mnohem jednodušší, než jsem původně myslel.

Ve skutečnosti jsou jen tři režimy:
Normální RAM/ROM

GA12 = CA12
GA13 = CA13
GA14 = CA14
GA15 = CA15
GA16 = 0

EMS1

GA12..16 = EMS1_PAGE[4..0]

EMS2

GA12..16 = EMS2_PAGE[4..0]

HALT

GA12..16 = HiZ

To znamená, že každý bit GA je pouze 3:1 multiplexer.

Na ATF1504 velmi rozumné.
Jedna architektonická otázka před ATF2

Tady bych se zastavil.

Ownership registry:

A_CPU_OWN
A_MHF_OWN

B_CPU_OWN
B_MHF_OWN

mohou být implementovány dvěma způsoby.
Varianta 1 — synchronně na E

Například:

if rising(E)

pak se přepočítá ownership.

Výhoda:

    stabilní

    predikovatelné

    žádné hazardy

Nevýhoda:

    MHF čeká až na další E

Varianta 2 — asynchronně

Jakmile:

A_SHARE_REQUEST

nebo

CPU_WANTS_A

změní stav,

změní se ownership okamžitě.

Výhoda:

    přesně odpovídá slovnímu zadání

Nevýhoda:

    u CPLD vznikají přechodové stavy

    více hazardů

Já bych osobně ownership synchronizoval na E.

Protože jsi sám psal:

    kdyz se zpozdi o nekolik taktu, nic se nestane

a

    MHF muze cekat sekundy

Takže jeden E cyklus navíc nic neznamená.

Za to výrazně zjednoduší návrh.

Můj odhad po současném upřesnění:

    ATF1 se vejde s velkou rezervou.

    ATF2 se pravděpodobně také vejde do jedné ATF1504AS-64MC, pokud ownership a DIRTY uděláš synchronně na E.

    Největší spotřeba nebude EMS, ale datový multiplex pro čtení registrů A000–A005 na sběrnici D[0..7].

To bude dobré navrhnout hned od začátku tak, aby se jednotlivé bity generovaly přímo z registrů a ne přes velké dekódovací matice.

 ownership synchronizoval na E.
    kdyz se zpozdi o nekolik taktu, nic se nestane


Souhlasím. Z toho, co popisuješ, vychází synchronizace ownership na E jako nejrozumnější varianta.

Dokonce bych šel ještě dál:
Synchronně na E držet

A_CPU_OWN
A_MHF_OWN
A_DIRTY

B_CPU_OWN
B_MHF_OWN
B_DIRTY

EMS1_PAGE
EMS1_SRC

EMS2_PAGE
EMS2_SRC

Tedy všechno, co představuje stav systému.
Kombinačně počítat

CPU_WANTS_A
CPU_WANTS_B

EMS1_C
EMS2_C

EMS1_W
EMS2_W

Chip_A.W
Chip_B.W

a podobné odvozené signály.

To pak vede na velmi jednoduchý model:

Při každém aktivním E cyklu:

if (!RESET)
{
    ...
}
else
{
    přepočítej ownership
    přepočítej DIRTY
    případně ulož registry
}

Dokonce si myslím, že ownership můžeš popsat jako dvoubitový stav místo dvou samostatných latchů.

Místo:

A_CPU_OWN
A_MHF_OWN

použít:

A_OWNER[1:0]

00 nobody
01 CPU
10 MHF
11 illegal

a stejně pro B.

To ušetří logiku při čtení status registru:

Chip_A.C = (A_OWNER == CPU)
Chip_A.A = (A_OWNER == MHF)

a hlavně přechody jsou jednoznačné.

Například:

if (A_OWNER == NONE)
{
    if (CPU_WANTS_A)
        A_OWNER = CPU;
    else if (A_SHARE_REQUEST)
        A_OWNER = MHF;
}

a

if (A_OWNER == CPU)
{
    if (!CPU_WANTS_A)
        A_OWNER = NONE;
}

a

if (A_OWNER == MHF)
{
    if (!A_SHARE_REQUEST)
        A_OWNER = NONE;
}

To vytváří přirozený mezistav:

CPU
  ↓
NONE
  ↓
MHF

nebo obráceně.

Ty sám jsi psal:

    mezikrok neni nutny, ale neskodi

A v CPLD bývá mezistav často jednodušší než snaha o atomické předání vlastnictví.

Ještě jedna věc, která mě při čtení napadla:

Pokud bude ownership synchronní na E, pak bych DIRTY také měnil pouze na E.

Tedy ne:

A_SHARE_REQUEST změnil stav
→ DIRTY hned

ale:

A_SHARE_REQUEST změnil stav

nejbližší E

→ DIRTY změna

Protože tím odstraníš možnost, že CPU uvidí přechodový stav mezi registry.

Z pohledu softwaru je rozdíl jednoho E cyklu zanedbatelný.

V tuhle chvíli už mi ATF2 připadá spíš jako několik malých synchronních stavových automatů než jako komplikovaný CPLD návrh. Nejrizikovější část už není ownership, ale návrat dat při čtení A000–A005 a správné řízení tristate výstupů na datovou sběrnici, aby nikdy nesoupeřily s RAM, VIA, ACIA nebo MHF. To je místo, které bych při psaní CUPL kontroloval nejpečlivěji.

Synchronizace na E neskodi nikde.
dvoubitovy stav místo dvou samostatných latchů pro ownership klidne muze byt, pokud to vyjde lip (na venek se to stejne chova stejne)
vysledne rovnice si urcite prekontroluju osobne rucne (a pak vyzkousim na breakboardu)

Pak bych se nebál ownership přeformulovat na skutečný stavový automat.

Původně jsem vycházel z toho, že:

A_CPU_OWN
A_MHF_OWN

jsou dva nezávislé bity.

Ale když se na to dívám znovu, tak ve skutečnosti popisují jeden stav:

00 = nikdo
01 = CPU
10 = MHF
11 = chyba (nemá nastat)

To je přesně dvoubitový FSM.
Proč se mi to líbí víc

Původní varianta:

A_CPU_OWN := ...
A_MHF_OWN := ...

musí řešit:

jak zabránit 11

v každé rovnici.

FSM varianta:

A_OWNER[1:0]

má:

NONE
CPU
MHF

a stav 11 prostě nikdy negeneruješ.
Přechody

Pro Chip_A:

NONE
 ├─ CPU_WANTS_A      -> CPU
 └─ SHARE_REQUEST    -> MHF

CPU
 ├─ CPU_WANTS_A      -> CPU
 └─ !CPU_WANTS_A     -> NONE

MHF
 ├─ SHARE_REQUEST    -> MHF
 └─ !SHARE_REQUEST   -> NONE

Tohle je velmi dobře čitelné i při pozdějším ladění.
Priorita

Tady je potřeba rozhodnout.

Představ si:

A_OWNER = NONE

CPU_WANTS_A = 1
A_SHARE_REQUEST = 1

ve stejném E cyklu.

Kdo vyhraje?

Já bych navrhoval:

CPU má prioritu

tedy:

NONE
  -> CPU

protože CPU je hlavní vlastník systému.

MHF si počká na další E.

Ale můžeš chtít i opačné pravidlo.

Jen musí být explicitní.
DIRTY

Pořád si myslím, že DIRTY je vhodný jako samostatný latch.

Ne jako odvozený stav.

Protože reprezentuje historii.

Například:

CPU pustí chip

↓

MHF získá chip

↓

MHF se k němu připojí

↓

DIRTY=1

↓

MHF pustí chip

↓

DIRTY pořád zůstává 1

To je klasická stavová informace.

Takže:

OWNER

FSM

a

DIRTY

samostatný registr.
Registry EMS

Tady bych naopak vůbec nic neoptimalizoval.

Nechal bych:

EMS1_SRC[1:0]
EMS1_PAGE[4:0]

EMS2_SRC[1:0]
EMS2_PAGE[4:0]

přesně tak, jak jsou.
Co bych asi udělal při implementaci

Nejdřív bych napsal ATF2 bez DIRTY.

Pouze:

Page registry

ownership

EMS status

a rozchodil:

SystemRAM

EMS->SystemRAM

EMS->MHF_A

EMS->MHF_B

Teprve potom přidal:

DIRTY

SHARE_GRANTED

SHARE_DIRTY

Protože to je vrstva navíc.
Jedna potenciální úspora

Všiml jsem si ještě jedné věci.

Ty vlastně nepotřebuješ:

EMS1_C
EMS2_C

nikde ukládat.

Jsou vždy:

SRC=00 -> 1

SRC=01 -> (OWNER_A == CPU)

SRC=10 -> (OWNER_B == CPU)

Totéž:

EMS1_W
EMS2_W

Takže skutečný stavový prostor celé logiky je překvapivě malý:

EMS1_SRC[1:0]
EMS1_PAGE[4:0]

EMS2_SRC[1:0]
EMS2_PAGE[4:0]

A_OWNER[1:0]
A_DIRTY

B_OWNER[1:0]
B_DIRTY

což je:

7 + 7 + 3 + 3 = 20 bitů

Přesně stejně, jak nám vyšlo na začátku.

A to je na ATF1504 velmi příjemné číslo. Nejspíš se nakonec ukáže, že většinu makrocell nespotřebují registry, ale multiplexery kolem GA[12..16], datové sběrnice a řízení všech těch S_READ/S_WRITE/S_SELECT/G_ENABLE signálů. Tam bych při ruční kontrole rovnic čekal největší prostor pro optimalizaci.

OK, myslim, ze to je takhle dobre.
Priorita (tenhle stav nema dobry duvod nastat a asi nikdy nenastane, ale at je vysledek jednoznacny)
V principu je jedno, kdo vyhraje, jen nesmi vyhrat oba. Hezci je, kdyz vyhraje CPU, tak at vyhraje CPU.
Jestli to takhle staci, tak zkus navrhnout ten kod

Myslím, že už jsme dost blízko, ale ještě bych negeneroval finální CUPL pro ATF1504, protože stále chybí několik věcí, které jsou pro syntézu důležité:

    Přesný pinout obou CPLD (který signál je na kterém pinu).

    Použitý nástroj (WinCUPL? Atmel CUPL? ABEL?).

    Jak chceš implementovat registry v CUPL:

        pomocí FIELD a registrovaných výstupů,

        nebo explicitní DFF.

    Jak přesně budou připojené datové bity D[0..7] při čtení registrů.
    To je kritické, protože ATF2 bude muset v určitých cyklech aktivně řídit datovou sběrnici a jindy být Hi-Z.

Co ale už můžu navrhnout
Stavový model ownership

Pro každý chip:

OWNER[1:0]

00 NONE
01 CPU
10 MHF
11 reserved

Přechody na náběžné hraně E:

NONE:
    CPU_WANTS -> CPU
    else SHARE_REQUEST -> MHF

CPU:
    if !CPU_WANTS -> NONE

MHF:
    if !SHARE_REQUEST -> NONE

CPU má tedy prioritu.
Odvozené signály

A_CPU_OWN = (A_OWNER == CPU)
A_MHF_OWN = (A_OWNER == MHF)

B_CPU_OWN = (B_OWNER == CPU)
B_MHF_OWN = (B_OWNER == MHF)

CPU_WANTS

CPU_WANTS_A =
      (EMS1_SRC == MHF_A)
   OR (EMS2_SRC == MHF_A)

CPU_WANTS_B =
      (EMS1_SRC == MHF_B)
   OR (EMS2_SRC == MHF_B)

EMS status

EMS1:

CASE EMS1_SRC

00 -> C = 1

01 -> C = A_CPU_OWN

10 -> C = B_CPU_OWN

11 -> C = 0

a obdobně EMS2.
W bity

EMS1:

W =
      (EMS1_SRC == MHF_A & A_SHARE_REQUEST)
   OR (EMS1_SRC == MHF_B & B_SHARE_REQUEST)

Chip status

D = DIRTY
W = SHARE_REQUEST
A = OWNER == MHF
C = OWNER == CPU

tedy:

xxxxDWAC

Mapování GA
Native RAM

MR=0000

GA12 = CA12
GA13 = CA13
GA14 = CA14
GA15 = CA15
GA16 = 0

ROM

MR=0011

stejné jako RAM.
EMS1

MR=0001

GA12..16 = EMS1_PAGE

EMS2

MR=0010

GA12..16 = EMS2_PAGE

HALT

GA12..16 = Hi-Z

ROM write protect

Normální běh:

MR=0011

/READ  = !(E & R/W)

/WRITE = 1

HALT:

MHF přebírá sběrnici:

/READ  = !(E & A_READ)

/WRITE = !(E & !A_READ)

Takže MHF může ROM oblast přepisovat.
Co bych udělal dál

Já bych teď nepsal CUPL naslepo.

Místo toho bych nejdřív udělal:
ATF1 truth table

vstupy:

A15..A0

výstupy:

MR[3:0]
Dev[1:7]

a
ATF2 truth table

pro:

MR
HALT
OWNER
EMS_SRC
E
R/W

↓

GA[]
Dev_0
READ
WRITE
G_ENABLE
G_A_DIR
G_D_DIR
S_SELECT
S_READ
S_WRITE
SHARE_GRANTED
SHARE_DIRTY

Protože právě tam se nejspíš objeví poslední logické rozpory.

Až budou ty tabulky hotové, převod do CUPL bude už skoro mechanická práce. V současném stavu bych odhadoval, že architektura je zhruba z 90–95 % definovaná, ale na napsání skutečného syntetizovatelného souboru ještě chybí ta vrstva přesných tabulek a pinového rozhraní.

Přesný pinout obou CPLD neres, to se nastavi v kodu prez 
Pin 9   = CS_RAM1;  
a podobne. Proste je ocisluj postupne, tohle si snadno prerovnam

Použitý nástroj bude WinCUPL

Jak chceš implementovat registry v CUPL - nejak to udelej, nemam znalosti, abych si umel vybrat

Jak přesně budou připojené datové bity D[0..7] při čtení registrů. - neco navrhni.

Dobře. V tom případě už bych se nebál začít generovat skutečný WinCUPL návrh. Ale navrhl bych ho po vrstvách.

Nejdřív důležitá poznámka:
Registry bych v WinCUPL dělal jako registrované uzly

Ne přes explicitní DFF.

Tedy něco ve stylu:

EMS1_SRC0.d = D0;
EMS1_SRC1.d = D1;

EMS1_PAGE0.d = D2;
...

s povolením zápisu přes dekodér adresy.

ATF1504 je na to stavěná a výsledné rovnice bývají menší.
Čtení registrů na D[0..7]

Tohle bych navrhl takto.

ATF2 bude normálně:

D[0..7] = Hi-Z

Pouze při:

MR3=1
&
E=1
&
R/W=1

tedy:

čtení registru

ATF2 převezme datovou sběrnici.

A000 EMS1.Page

D7 = EMS1_SRC1
D6 = EMS1_SRC0
D5 = 0
D4 = EMS1_PAGE4
D3 = EMS1_PAGE3
D2 = EMS1_PAGE2
D1 = EMS1_PAGE1
D0 = EMS1_PAGE0

A001 EMS1.Status

D7..D3 = 0
D2 = 0
D1 = EMS1_W
D0 = EMS1_C

A002 EMS2.Page

analogicky.

A003 EMS2.Status

analogicky.

A004 Chip_A

D7..D4 = 0
D3 = A_DIRTY
D2 = A_SHARE_REQUEST
D1 = A_MHF_OWN
D0 = A_CPU_OWN

A005 Chip_B

analogicky.

To je asi nejlevnější možné řešení.
Co bych změnil proti původnímu návrhu

Tady je jedna věc.

Původně jsme uvažovali:

A_OWNER[1:0]

FSM.

V CUPL to sice jde.

Ale upřímně si nejsem jistý, že to bude úspornější než:

A_CPU_OWN
A_MHF_OWN

protože:

    stejně musíš dekódovat stav

    stejně musíš generovat dva výstupy

    stejně musíš číst dva bity do registru

Já bych pro první verzi nechal:

A_CPU_OWN
A_MHF_OWN

B_CPU_OWN
B_MHF_OWN

a pouze zajistil:

nikdy nevznikne 11

v přechodových rovnicích.

Je to mnohem přehlednější při debugování.
První verze DIRTY

Tady bych byl ještě konzervativnější.

Navrhuji:
Nastavení

Když MHF získá chip:

A_MHF_OWN: 0 -> 1

pak:

A_DIRTY := 1

Vymazání

Když CPU získá chip:

A_CPU_OWN: 0 -> 1

pak:

A_DIRTY := 0

Tím vznikne:

DIRTY = MHF už se tím zabývalo

což přesně odpovídá tomu, jak jsi ho popisoval.
SHARE_GRANTED

Úplně natvrdo:

A_SHARE_GRANTED = A_MHF_OWN

B_SHARE_GRANTED = B_MHF_OWN

SHARE_DIRTY

Podle posledního popisu bych navrhl:

Pokud MHF chip nevlastní:

A_SHARE_DIRTY = A_DIRTY

Pokud MHF chip vlastní:

A_SHARE_DIRTY = CPU_WANTS_A

To přesně odpovídá tvé myšlence:

    když mám chip, DIRTY mi říká, že CPU ho chce zpátky

a

    když ho nemám, DIRTY mi říká, že už jsem se k datům dostal

Struktura WinCUPL projektu

Já bych to rozdělil na:
ATF1.PLD

Pouze:

MR[0..3]

Dev_1..Dev_7

ReadEnable
WriteEnable

bez jediného registru.

Čistě kombinační.
ATF2.PLD

Registry:

EMS1_SRC
EMS1_PAGE

EMS2_SRC
EMS2_PAGE

A_CPU_OWN
A_MHF_OWN
A_DIRTY

B_CPU_OWN
B_MHF_OWN
B_DIRTY

a vše ostatní odvozené.

Můj odhad je, že taková první verze bude mít slušnou šanci vejít se do ATF1504 bez nějakých agresivních optimalizací. A hlavně bude velmi dobře čitelná při ruční kontrole rovnic, což jsi psal, že chceš dělat před osazením do hardware.

Tak to takhle zkus

Zkusím první kostru pro ATF2 v WinCUPL stylu, ale ber to jako návrh architektury, ne syntetizovatelný soubor. U ATF1504 bývá potřeba po prvním překladu ještě upravit syntaxi, polarity a případně rozdělit některé rovnice.

První věc, kterou bych změnil proti poslednímu návrhu:

Neukládal bych A_CPU_OWN a A_MHF_OWN jako dva nezávislé registry.

Důvod:

CPU_WANTS_A = 1
A_SHARE_REQUEST = 1

a najednou musíš řešit prioritu ve dvou registrech.

Místo toho bych skutečně použil:

A_OWNER0
A_OWNER1

00 nobody
01 CPU
10 MHF
11 reserved

Totéž pro B.

To je ve WinCUPL překvapivě přirozené.
Registry

/* EMS1 */

EMS1_SRC0
EMS1_SRC1

EMS1_PAGE0
EMS1_PAGE1
EMS1_PAGE2
EMS1_PAGE3
EMS1_PAGE4

/* EMS2 */

EMS2_SRC0
EMS2_SRC1

EMS2_PAGE0
EMS2_PAGE1
EMS2_PAGE2
EMS2_PAGE3
EMS2_PAGE4

/******************/

A_OWNER0
A_OWNER1

B_OWNER0
B_OWNER1

A_DIRTY
B_DIRTY

Pomocné definice

CPU_WANTS_A =
   (!EMS1_SRC1 & EMS1_SRC0)
 # (!EMS2_SRC1 & EMS2_SRC0);

CPU_WANTS_B =
   ( EMS1_SRC1 & !EMS1_SRC0)
 # ( EMS2_SRC1 & !EMS2_SRC0);

Dekódování owner

A_CPU_OWN = !A_OWNER1 & A_OWNER0;
A_MHF_OWN =  A_OWNER1 & !A_OWNER0;

B_CPU_OWN = !B_OWNER1 & B_OWNER0;
B_MHF_OWN =  B_OWNER1 & !B_OWNER0;

Zápis EMS1 registru

EMS1_WRITE =
    REGSEL0
  & !R_W
  & E;

EMS1_SRC1.d  = EMS1_WRITE & D7
             # !EMS1_WRITE & EMS1_SRC1;

EMS1_SRC0.d  = EMS1_WRITE & D6
             # !EMS1_WRITE & EMS1_SRC0;

EMS1_PAGE4.d = EMS1_WRITE & D4
             # !EMS1_WRITE & EMS1_PAGE4;

EMS1_PAGE3.d = EMS1_WRITE & D3
             # !EMS1_WRITE & EMS1_PAGE3;

EMS1_PAGE2.d = EMS1_WRITE & D2
             # !EMS1_WRITE & EMS1_PAGE2;

EMS1_PAGE1.d = EMS1_WRITE & D1
             # !EMS1_WRITE & EMS1_PAGE1;

EMS1_PAGE0.d = EMS1_WRITE & D0
             # !EMS1_WRITE & EMS1_PAGE0;

Totéž EMS2.
Ownership FSM A
Stav NONE

A_NONE = !A_OWNER1 & !A_OWNER0;

Další stav bit0

A_OWNER0.d =

    RESET

    # (A_NONE & CPU_WANTS_A)

    # (A_CPU_OWN & CPU_WANTS_A);

Další stav bit1

A_OWNER1.d =

    (A_NONE & !CPU_WANTS_A & A_SHARE_REQUEST)

    # (A_MHF_OWN & A_SHARE_REQUEST);

To přímo implementuje:

NONE
 ├─ CPU_WANTS      -> CPU
 └─ REQUEST        -> MHF

CPU
 └─ !CPU_WANTS     -> NONE

MHF
 └─ !REQUEST       -> NONE

a CPU má prioritu.
DIRTY

První jednoduchá verze:

A_DIRTY.d =

      (A_DIRTY & !A_CPU_OWN)

   #  (!A_DIRTY & A_MHF_OWN);

Tj.

MHF získalo chip -> DIRTY=1

CPU získalo chip -> DIRTY=0

EMS status

Kombinační.

EMS1_C =

      (!EMS1_SRC1 & !EMS1_SRC0)

   #  (!EMS1_SRC1 & EMS1_SRC0 & A_CPU_OWN)

   #  ( EMS1_SRC1 & !EMS1_SRC0 & B_CPU_OWN);

EMS1_W =

      (!EMS1_SRC1 & EMS1_SRC0 & A_SHARE_REQUEST)

   #  ( EMS1_SRC1 & !EMS1_SRC0 & B_SHARE_REQUEST);

Chip status

CHIPA_C = A_CPU_OWN;
CHIPA_A = A_MHF_OWN;
CHIPA_W = A_SHARE_REQUEST;
CHIPA_D = A_DIRTY;

Čtení A004

D7 = 0;
D6 = 0;
D5 = 0;
D4 = 0;

D3 = CHIPA_D;
D2 = CHIPA_W;
D1 = CHIPA_A;
D0 = CHIPA_C;

SHARE_GRANTED

A_SHARE_GRANTED = A_MHF_OWN;
B_SHARE_GRANTED = B_MHF_OWN;

SHARE_DIRTY

A_SHARE_DIRTY =

    !A_MHF_OWN & A_DIRTY

  #  A_MHF_OWN & CPU_WANTS_A;

Tohle je zhruba úroveň, kde bych to už skutečně začal cpát do WinCUPL a nechal překladač ukázat:

    kolik makrocell zabírá,

    které rovnice jsou moc velké,

    kde je potřeba použít mezisignály (NODE),

    jestli se vejde do jedné ATF1504.

Až potom bych psal finální verzi ATF1 a dokončoval multiplex datové sběrnice. Právě tam očekávám nejvíc praktických úprav po prvním překladu.
Get smarter responses, upload files and images, and more.


