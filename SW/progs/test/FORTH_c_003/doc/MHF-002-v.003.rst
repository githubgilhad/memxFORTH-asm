.. vim: ft=rst showbreak=--»\  noexpandtab fileencoding=utf-8 nomodified   wrap textwidth=0 foldmethod=marker foldmarker={{{,}}} foldcolumn=4 ruler showcmd lcs=tab\:|- list tabstop=8 noexpandtab nosmarttab softtabstop=0 shiftwidth=0 linebreak  


:date: 2026.02.11 13:59:31
:_modified: 1970.01.01 00:00:00
:tags: FORTH,MHF
:authors: Gilhad
:summary: MHF-002-v.003
:title: MHF-002-v.003
:nice_title: |logo| %title% |logo|

%HEADER%

MHF-002-v.003
--------------------------------------------------------------------------------


Chci si napsat FORTH pro MHF-002 a naražím na problémy, jak co zařídit. Rozhodl jsem se, že se mi celkem zamlouvají věci z FORTH 2012 a tak to udělám podobně. Některé věci se mi nezamlouvají, tak je udělám jinak a celkový přístup mi tam přijde už opravdu moc jako "pitvání žáby", takže místy prostě budu raději koukat, kam ta žába doskáče.

**MHF-002-v.003** nemá ambice být normou, ani Stadardním Systémem, takže Standardní Programy možná nebudou fungovat. Na druhou stranu pokud někdo zhruba o FORTH 2012 ví, tak má velkou šanci, že co tu napíše bude nejspíš fungovat podle jeho představ.

FORTH 2012 používajte jako referenční příručku, ale neberte ho příliš vážně a doslova. Některé významné rozdíly (a jiné podivnosti) zkusím rozepsat tady níž.

* **CELL** je 24bitů = 3 byty velká. To stačí na ukazatele do celé RAM (0x80xxxx 64kB), FLASH (0x01xxxx-0x03xxxx 256kB) External Memory (128kB) a Shared Memory (128kB) najednou a pro jednotný přístup k paměti
* Tasky a vlákna - plánuju vícevláknový systém a kooperativní multitasking, s interrupty (které vloží další slovo do zpracování)
* **Task Controll Block**, krátce **TCB** je struktura pro každé vlákno zvlášť. **Povinně** je uložená v RAM (a tedy přístup pomocí `ld rxx, Z+` je validní), paměť odkazovaná pomocí **HERE** musí být zapisovatelná (ale nemusí být v hlavní RAM)
* překlad ve FORTHu používá datový zásobník pro interní záležitosti (zejména překlad IF-ELSE-THEN, DO-LOOP a BEGIN-XXX) (jako vrstvy a hlavní adresy konstrukce) a L-zásobník (jako seznamy, co je potřeba zpětně vyplnit), aby mohly být podmíněné LEAVE, BREAK (kde IF..THEN obsahuje LEAVE od DO..LOOP, ve kterém je a LEAVE potřebuje vyřešit skok za smyčku)
	* **DO** vloží při překladu na DST svou adresu a na LST 0. Při běhu přesune na RST pár limit, first 
		* **LOOP** (a +LOOP a spol.) použijí adresu pro cyklus a vyřeší odkazy na LST až do 0 jako relativní za konec cyklu. Ukončují cyklus a ruší kontrolní struktury. Při překladu uklidí zásobník.
		* **NEXT** (a +NEXT a spol.) použijí (a zachovají) adresu pro cyklus a nic jiného neřeší; jak by vlastně měly fungovat? mám je vůbec vymýšlet?
		* **LEAVE** opuští celý cyklus a ruší kontrolní struktury. Při překladu přidá svou adresu na LST.
		* **UNLOOP** jen čistí kontrolní struktury, po něm může přijít EXIT.
		* **I**, J, K čtou hodnoty z RST 
	* **BEGIN** vloží na DST svou adresu, a na LST 0
		* **UNTIL**, **REPEAT** a **AGAIN** použijí adresu pro cyklus a vyřeší odkazy na LST až do 0 jako relativní za konec cyklu. Ukončují cyklus a ruší kontrolní struktury. Při překladu uklidí zásobník.
		* **WHILE** při nule skočí za cyklus (lze jich mít i víc)
		* **BREAK** skočí za cyklus
		* **CONTINUE** skočí na začátek cyklu
	* **IF-ELSE-THEN** - klasika, **IFNOT** je logický opak IF pro elegantnější zápisy, **FI**je **THEN** (if pozpatku, endif, ...)
	* IMMEDIATE slova vetsinou zakompiluji do noveho slova pomocne slovo zacinajici na `www_do_`
	* CREATE ... DOES> - zakompiluje do noveho slova (typu CONSTANT, VARIABLE ...) `www_do_DOES_cw`, ktere dela to samé co `w_exit_cw` a má 4B "parametr", který je asm instrukce `call www_do_DOES_code`, protože na něj bude ukazovat code_word slov vytvořených tím novým slovem (typu HODNOTA_TAKOVA, POCET_CEHOSI, ...), aby na systémovém stacku zůstala adresa, kde je část za `DOES>`, viz `DOES> Explained <DOES_Explained>`__ 
		* tato nová slova (CONSTANT...) jsou v RAM nějakého druhu (takže `call www_do_DOES_code` nelze provést), proto slova jimi vytvořená (HODNOTA_TAKOVA ...)  **NELZE** okamžitě použít, dokud nebude to nové slovo (CONSTANT, ...) převedené do FLASH
		* při převádění slov typu HODNOTA_TAKOVA se pro _cw použije `P24 <adresa toho 'call www_do_DOES_code'` v příslušném CONSTANT
		* otázka je, zda neupravit NEXT, aby dokázal tohle řešit přez "dvojitě nepřímou adresu" na nákladě příznaku v ní. (Když je nastaven, uloží se na zásobník DST ještě adresa ZA cílem a cíl se jeětě jednou dereferencuje. Pak by měl www_do_DOES_cw jen 3B parametr=adresu)
			* příznak 0x10xxxx bude **double reference** který kromě `DT` ještě nastaví `Tempx` (`Parsx` se používá v NEXT pro B3at)  na adresu za tím "parametrem" `www_do_DOES_cw` (DDT=*DT, adresa kódu, Tempx = DDT+++ )
			* `Udělal  jsem to tak <http://comp24.gilhad.cz//MHF-002/FORTH/DOES_Explained.html>`__

