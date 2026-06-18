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

ATF1504AS pozorovani: na prepnuti vstupu staci 130 |kOhm| proti zemi/+5V, 140  |kOhm| uz nikoli. Stejne tak nestaci LED+330 |Ohm|.
CASTOR ma necelych 6kB

* Rozhodnuti: 
	* Pridam EEPROM 32kB (68C256), ty mam celkem 3 (vcetne Omen Kilo a BreadBoard 6309 compu)
	* Pridam konfig prepinac BootFrom s 10 |kOhm| odporem a piny GND - IO - +5V - pokud bude nastaven nahoru, bude EEPROM defaultne pripojena
	* Pridam registr do ATF1, pokud bude adresa v EEPROM tak se podle nej bud (pripoji EEPROM a nahlasi MR=ROM) nebo (pripoji RAM a nahlasi MR=LoRAM a vypne Write) (s vyjimkou HALT/BA stavu) (Reg.7, z reserved rozsahu)
	* ten registr se pri resetu nastavi dle prepinace, pujde cist CPU a pujde prepsat CPU (do dalsiho resetu)
		* ops, defaulty neumim, tak to bude live signal, a registr bude zapnuti/vypnuti override, zapis to prepne na pozadovanou vyslednou hodnotu xxxx xxDA A=actual, D=default (mozna vytahnout oba na LEDky?)
	* MR pujdou na LED pres oddelovace, VIA D-latch fix bude pouzivat 74HC chip (pro jistotu)


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

Dev_1..7
--------------------------------------------------------------------------------


.. code::

	A000-A01F -> Registers (ATF2)
	A020-A03F -> Dev_1
	A040-A05F -> Dev_2
	A060-A07F -> Dev_3
	A080-A09F -> Dev_4
	A0A0-A0BF -> Dev_5
	A0C0-A0DF -> Dev_6
	A0E0-A0FF -> Dev_7


Dev_0 je SystemRAM.Enable
--------------------------------------------------------------------------------

Pro 

0000-7FFF
A100-FFFF

je generovan ATF1 jako Dev_0 aktivní (a ATF2 ma tento pin v HiZ a tedy ho neridi)

Pro EMS okna 

8000-8FFF
9000-9FFF

tento pin ATF1 prepne do HiZ (a tedy ho neridi) a ridi ho ATF2 podle namapovani EMS oken

Registry a devices:
A000-A0FF
Pin je neaktivni a ridi ho ATF1


A100-FFFF

fyzicky SystemRAM

* ale zápisy blokuje GLUE, 
* Pokud ji CPU namapuje do EMSx okna, tak do toho okna jde psat a okamzite to je zmene i v "ROM" oblasti.
* Pri HALT stavu do ni jde psat normalne (ostatne tohle je hlavni duvod HALT stavu - naplnit ji pri bootu)

Dalsi upresneni
--------------------------------------------------------------------------------

ChipA.C a ChipB.C jsou latchované

ChipA.A a ChipB.A jsou latchované

Pri soubehu pozadavku na chip je celkem jedno, kdo vyhraje, zda CPU nebo MHF (v praxi by vubec nemelo nastat kvuli jinym okolnostem)

Chip.D je urcen pro CPU, SHARE_DIRTY je urcen pro MHF, ATF2 aktivne ridi oboje 

DIRTY je mozna zavadejici nazev, 

Chip.D se nastavi, kdyz MHF ziska chip, maže se kdyz chip ziska CPU. (Dulezity bod je, ze kdyz se CPU vzda chipu a MHF se ho jeste nepokusilo ziskat, je Chip.D smazany.)

ATF2 nastavi SHARE_DIRTY, kdyz CPU ziska chip, smaze  kdyz MHF ziska chip, nastavi kdyz MHF chip ma a CPU ho chce ziskat, smaze ho, kdyz se MHF vzda chipu.

SHARE_GRANTED je generovan ATF2 pro MHF jako zrcadleni latchu ChipX.A

V HALT rezimu ridi RAM vzdy maximalne jedna deska MHF (jak se ty desky mezi sebou dohonou jde mimo sbernici). Idealne by RAM mohly ridit (na stridacku) jedna, nebo druha, ale pokud by to bylo prilis slozite, tak postaci kdyz ji bude ridit MHF_A

MR generuje ATF1, cte ho ATF2 (aby se usetrily piny pro dekodovani cele adresy). Tabulku jsi pochopil spravne.

Co se signalu E tyce - MHF ma relativne slozity vnitrni pristup ke sbernici a neni synchronizovane s CPU. Pokud nekde dojde ke zpozdeni, nic se nedeje, par taktu neni problem.

CPU generuje E R/W a ocekava, ze se vse bude chovat jako obycejna RAM. Protoze v kazdem cyklu E pristupuje pouze k jedne adrese na jednom chipu, nehrozi zadne problemy s cache (neni tam) ani s konkurencnim pristupem (neni tam) ani s mapovanim (v jednom cyklu se neco zapise, cte se to az zase v jinem cyklu). Pouzij klidne synchronni latch.

Nesejde mi na implementaci, jestli A+C budou dva vnitrni nezavisle bity, nebo jedna dvojice se stejnym vyznamem. Jestli to pomuze usetrit termy, tak to pouzij. Specialni fitter nemam, jedine, co umim je nacpat rovnice do WinCupl a pak prohlizet vysledek. Takze pokud vyjde 45 cel, tak to bude prima, pokud vyjde 85, tak budu muset vymyslet neco jineho, ale to se dozvim teprve az WinCupl ty rovnice zpracuje.

Dev_0 je vnejsi vodic, ATF1 i ATF2 jsou k nemu pripojeny, podle adresy je vzdy jeden z ATF v HiZ stavu a druhy tento vodic nastavuje na 0/1 ATF2 cte i zapisuje do D[0..7], ty jsou pripojeny na skutecnou datovou sbernici, stejne jako CPU, RAM a vse ostatni (jinymi slovy - kdyz CPU pracuje s RAM, zapisuje a cte do RAM chipu, kdyz CPU pracuje s registry, zapisuje a cte do ATF2 a ATF2 se chova stejne jako RAM)

Dev_1..Dev_7 jsou selected v nule a not selected v 1 Read a Write jsi taky pochopil spravne

Napis ty CUPL
