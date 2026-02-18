.. vim: ft=rst showbreak=--»\  noexpandtab fileencoding=utf-8 nomodified   wrap textwidth=0 foldmethod=marker foldmarker={{{,}}} foldcolumn=4 ruler showcmd lcs=tab\:|- list tabstop=8 noexpandtab nosmarttab softtabstop=0 shiftwidth=0 linebreak  


:date: 2026.02.17 20:11:39
:_modified: 1970.01.01 00:00:00
:tags: FORTH,MHF
:authors: Gilhad
:summary: LST and Cycles
:title: LST and Cycles
:nice_title: |logo| %title% |logo|

%HEADER%

.. include:: .root/FORTH.inc


LST and Cycles
--------------------------------------------------------------------------------

Překlad cyklů a IF-ů
==================================================

Při překladu větších konstrukcí je potřeba vědět, kde začíná (u cyklů, aby šly opakovat), kde končí (např. u IF-ů, aby šlo přeskočit neprováděné) a nebo obojí.

IF...ELSE...THEN
################################################################################

Typický překlad:

.. code::

	0BRANCH(dest_1)		// IF
	...
	...
	BRANCH(dest_2)		// ELSE
	dest_1:
	...
	...
	dest_2:			// THEN

* **dest_1** a **dest_2** jsou dopředné reference.
* V **IF** a **ELSE** zakompiluju nulu a na zásobník uložím její adresu.
* Když dojdu k jejich definici v **ELSE** a **THEN**, vyzvednu adresu ze zásobníku a napíšu na ni vzdálenost (**HERE @ SWAP -**)

Používám zásobník |LST|.

BEGIN...AGAIN
################################################################################

Typický překlad:

.. code::

	orig:			// BEGIN
	...
	...
	BRANCH(orig)		// AGAIN

* **orig** je zpětná reference, známá v okamžiku svého vzniku, ale potřebná až o dost později.
* V BEGIN na zásobník uložím její adresu [*]_
* Na konci v AGAIN ji vyzvednu a použiju

Používám zásobník |DST|.

.. [*] Ve skutečnosti uložím na zásobník nulu a **orig** a pak je vyzvednu obě, viz níže

BEGIN...UNTIL...REPEAT
################################################################################

Typický překlad (s více UNTIL):


.. code::

	orig:			// BEGIN
	...
	0BRANCH(dest)		// UNTIL
	...
	0BRANCH(dest)		// UNTIL
	...
	BRANCH(orig)		// REPEAT
	dest:

* **orig** je zpětná reference, známá v okamžiku svého vzniku, ale potřebná až o dost později.
* **dest** je dopředná reference.
* v **BEGIN** na zásobník uložím nulu a **orig**
* v **UNTIL** zakompiluju nulu a na zásobník uložím její adresu pod vrchní **orig**
* v **REPEAT** vyzvednu a použiju **orig**, potom v cyklu (dokud nenarazím na nulu) vyzvedávám jednotlivé **dest** a řeším je jako v **IF..ELSE..THEN**
	* Stejně jako **BEGIN..AGAIN** to začíná slovem **BEGIN**, proto to slovo používá vnulu vždy a **AGAIN** je v podstatě jinak pojmenovaný **REPEAT** (u mě, jinde to může být jinak)

Používám zásobník |DST|.

**DST** má vršek |TOS| v registrech (tam bude **orig**), zatímco všechny **dest** se dávají pod něj, tedy přímo na vršek implementace zásobníku - takže je to ještě efektivnější, než přidávání nahoru.

Tímhle způsobem se dají přidat i **CONTINUE**, která přečtou, ale nevyzvednou, **orig** a použijí ho, stejně jako **BREAK**, která se prostě přidají do seznamu **dest** (takže se chovají jako **0 UNTIL**)

Kombinace předchozích
==================================================

Typické použití je **BEGIN ... UNTIL ... IF ... CONTINUE THEN ... IF ... BREAK THEN ... REPEAT** 


.. code::

	BEGIN
		...
	UNTIL
		...
		IF
			...
			CONTINUE
		THEN
		...
		IF
			...
			BREAK
		THEN
		...
	REPEAT

Tady je vidět, proč potřebuju používat zásobníky dva - ty **CONTINUE** a **BREAK** jsou zanořené do jednoho, či více **IF...THEN**, takže pokud by sdílely zásobník, bylo by pro ně obtížné najít svá data.

Pokud je  **IF...THEN** na |LST|, tak si navzájem nepřekáží a můžou se křížit po libosti.

Samozřejmě křížení **IF** a začátku či konce cyklu asi není v pořádku, ale to nehodlám vynucovat interpreterem.

Zásobníky při kompilaci
==================================================

|RST| zásobník návratových adres
################################################################################


Překlad je volán z **INTERPRET** (který je volán z **QUIT**) po jednotlivých slovech a když dojde na konec řádku, **INTERPRET** skončí a volá se **ACCEPT** pro zíkání dalšího vstupu a pak se zase volá **INTERPRET**.

Tím mezi jednotlivými slovy se může |RST| i snížit (a zase vrátit), data tedy nemohou ležet na jeho vrcholku.

Pokud se nezmění **QUIT** ani **INTERPRET**, tak by data mohla být o pozici níž, ale znamenalo by to žonglování při přístupu k nim (každé další složené slovo přidává návrat na zásobník a tím mění hloubku dat). Asi se mi do toho nechce.

|DST|  Data stack, hlavní datový zásobník
################################################################################

**INTERPRET** na něj během překladu čísla nepřidává, rovnou je zakompilovává do nového slova (pokud nevyskočím pomocí **[ ... ]** a pak snad vím, proč tam dávám, co tam dávám a s čím se mi co kříží).

Při překladu na něj dávám **BEGIN..** a **DO..** smyčky ve tvaru **0**, seznam adres k vyřešení, **orig**


|LST| secondary zásobník
################################################################################

|LST| je secondary zásobník a je tak pojmenovaný, protože v `CamelForth <http://www.camelforth.com/index.html>`__ ho tak pojmenovali a já na jeho potřebu přišel právě tam, když jsem přemýšlel, jak udělat **LEAVE** čistě.

**INTERPRET** ho nepoužívá.

Při překladu na něj dávám **IF...ELSE...THEN** adresy

Příklad
################################################################################

Pro složitější strukturu to může vypadat nějak takto: Každý cyklus má svůj blok ukončený nulou, zatímco každý **IF** má jen jednu položku. Cykly a **IF**\ y jsou na sobě nezávislé, není vidět, jak jsou navzájem zanořené.

.. code::

	
	    DST              LST
	| 1 orig   |    | 1 dest_1 |
	| 1 dest_n |    | 2 dest_2 |
	|   ...    |    | 3 dest_1 |
	|   ...    |    | 4 dest_2 |
	| 1 dest_n |    | 5 dest_1 |
	| 1 dest_n |    | 6 dest_1 |
	|    0     |    |   ...    |
	+----------+    |   ...    |
	| 2 orig   |    +----------+
	| 2 dest_n |
	|   ...    |
	|   ...    |
	| 2 dest_n |
	| 2 dest_n |
	|    0     |
	+----------+


Jak jsem k tomu vlastně došel
--------------------------------------------------------------------------------

Začal jsem si psát FORTH pro MHF-002 a chtěl jsem to mít poněkud míň zmatené, než tu předchozí verzi (založenou vágně na JonesFORTH). Hledání na webu naráží na značnou roztříštěnost, nakonec jsem se přichytil FORTH 2012 jako nejnovější a asi nejpropracovanější a snadno dostupné. 

Nejpropracovanější asi byla, ale moc jsem z ní nevyčetl, jak mám věci dělat, jen se co chvíli ukázalo, že takhle ne, protože je to něco proti něčemu, co bylo zcela jinde. A pak jsem se náhodou dočetl o pitvání žab [1]_ ...

**FORTH 2012** používá **(C: -- do-sys )**  semantiky a nepopisuje, jak vypadají, ale má na to nějaká slova, která dost omezují, jak to může vypadat a co tam půjde snadno (například ani **BREAK** ani **CONTINUE** v delších důsledcích ne)

Já jsem se rozhodl přestat se držet FORTH 2012, protože mě víc láká pozorovat žábu skákat, než ji jen pitvat [1]_

Pak jsem se dostal ke `CamelForth <http://www.camelforth.com/index.html>`__ a vypadá to, že se v něm dokážu celkem zorientovat a budu ho používat jako pomůcku a částečně i vzor, ale nakonec půjdu vlastní cestou.


----

.. [1] One learns one set of things about frogs from studying them in their natural environment or by getting a doctorate in zoology and specializing in frogs. And people who spend an hour disecting a dead frog in a pan of fermaldahide in a biology class learn something else about frogs.

   Live frogs are just very different than dead frogs.

   Dead frogs stink.

   Více v `Jeff's UltraTechnology Blog <https://www.ultratechnology.com/blog.htm>`__ 

   Já na to narazil v `My history with Forth & stack machines <https://yosefk.com/blog/my-history-with-forth-stack-machines.html>`__  kde Yossi citoval  Jeffa

   A Jeff `Jeff's UltraTechnology Blog <https://www.ultratechnology.com/blog.htm>`__ vysvětluje, že Yoshi nic nepochopil (v asi 1/5 strany  "10/22/10 My Thoughts on a Different Sort of Blog" 
   a ve 7/8 je to citované "Sept 28, 2007, "Forth Enthusiasts are not all the same." " druhá půlka )

   Zajímavé je to celé.

   Také zajímavé je `ANSI Forth is ANTI Forth <https://www.ultratechnology.com/antiansi.htm>`__

