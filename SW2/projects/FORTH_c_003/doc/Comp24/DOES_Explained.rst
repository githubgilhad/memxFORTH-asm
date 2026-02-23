.. vim: ft=rst showbreak=--»\  noexpandtab fileencoding=utf-8 nomodified   wrap textwidth=0 foldmethod=marker foldmarker={{{,}}} foldcolumn=4 ruler showcmd lcs=tab\:|- list tabstop=8 noexpandtab nosmarttab softtabstop=0 shiftwidth=0 linebreak  


:date: 2026.02.11 17:54:29
:_modified: 1970.01.01 00:00:00
:tags: MHF,FORTH
:authors: Gilhad
:summary: DOES_Explained
:title: DOES_Explained
:nice_title: |logo| %title% |logo|

%HEADER%

DOES_Explained
--------------------------------------------------------------------------------

Podrobně je tohle vysvětlované v `MOVING FORTH Part 3: Demystifying DOES> by Brad Rodriguez <https://www.bradrodriguez.com/papers/moving3.htm>`__, zde nabízím jiný pohled/jiná slova pro totéž (abych si načtené rychle obnovil kdykoli později)

Mám FORTH pro MHF-002 (atmega2560, 3B=24bit CELL), motivační příklad je vytvoření dvou konstant TEN a FIVE pro nějaké další použití, představme si, že je teď celá paměť jak writeable, tak executable, ať nemusíme šíbovat s adresami

.. code::

	: CONSTANT CREATE , DOES> @ ;
	10 CONSTANT TEN ( -- 10 )
	5  CONSTANT FIVE ( -- 5 )

* Provedení `: CONSTANT CREATE , DOES> @ ;`
* `:` (je interpretováno) přečte nasledující slovo a vytvoří pro něj hlavičku, zahájí kompilaci (STATUS=F_COMPILING)	( -- )
	.. code::
		
		Addr	| value		| comment
		--------+---------------+------------------------------
		0x001000| 0x0009F0	| 3B odkaz na předchozí hlavičku
		0x001003| 0x40		| 1B Attributy (dočasně FLAG_HIDDEN)
		0x001004| 8		| 1B délka slova
		0x001005| CONSTANT	| 8B název slova
		0x00100D| w_docol_cw	| 3B CW: code_word dvojtečkové definice
		0x001010| ...		| <== sem přijde další kód, zatím sem ukazuje HERE
* `CREATE` není IMMEDIATE, takže se tam prostě vloží jeho **_cw** (zakompiluje se), provede se až po spuštění CONSTANT	( -- )
	.. code::
		
			|		| 
		--------+---------------+------------------------------
		0x001010| w_CREATE_cw	| 3B odkaz na CW slova CREATE
		0x001013| ...		| <== sem přijde další kód, zatím sem ukazuje HERE
* `,` (comma) není IMMEDIATE, takže se zakompiluje	(  -- )
	.. code::
		
			|		| 
		--------+---------------+------------------------------
		0x001013| w_comma_cw	| 3B odkaz na CW slova čárka ,
		0x001016| ...		| <== sem přijde další kód, zatím sem ukazuje HERE
* `DOES>` je IMMEDIATE, zakompiluje odkaz na **ww_does_cw** a asm kód pro CALL do_DOES ( -- )
	.. code::
		
			|		| 
		--------+---------------+------------------------------
		0x001016| ww_does_cw	| 3B odkaz na CW pomocného slova pro DOES>
		0x001019| CALL do_DOES	| 4B volání do_DOES (návratová hodnota bude sloužit jako odkaz sem, nikoli pro return)
		0x00101D| ...		| <== sem přijde další kód, zatím sem ukazuje HERE
	
	* je tu problém, že nová slova se dělají do RAM, ale provádění asm instrukci je možné jen z FLASH. Než toto slovo použijeme, musíme ho tam překlopit
	* tento krok ukončil definování, co se bude dělat při spuštění slova CONSTANT a zahájil definování, co se bude dělat při spuštění slov jím vytvořených (třeba TEN)
	* **ww_does_cw** udělá tu správnou věc až bude spuštěno (viz níže)
* `@` není IMMEDIATE, takže se tam prostě vloží jeho **_cw**, provede se až po spuštění TEN ( -- )
	.. code::
		
			|		| 
		--------+---------------+------------------------------
		0x00101D| w_at_cw	| 3B odkaz na CW slova @
		0x001020| ...		| <== sem přijde další kód, zatím sem ukazuje HERE
* `;`  je IMMEDIATE, zakompiluje odkaz na **w_exit_cw**, shodí flag FLAG_HIDDEN  a ukončí definici (STATUS=F_INTERPRETING) ( -- )
	.. code::

			|		| 
		--------+---------------+------------------------------
		0x001003| 0x0		| 1B Attributy
		
			|		| 
		--------+---------------+------------------------------
		0x001020| w_exit_cw	| 3B odkaz na CW slova EXIT
		0x001023| ...		| <== sem přijde další kód, zatím sem ukazuje HERE
* první řádek je hotov, mám slovo CONSTANT:

	.. code::
		
		Addr	| value		| comment
		--------+---------------+------------------------------
		0x001000| 0x0009F0	| 3B odkaz na předchozí hlavičku
		0x001003| 0x0		| 1B Attributy (žádné)
		0x001004| 8		| 1B délka slova
		0x001005| CONSTANT	| 8B název slova
		0x00100D| w_docol_cw	| 3B CW: code_word dvojtečkové definice
		0x001010| w_CREATE_cw	| 3B odkaz na CW slova CREATE
		0x001013| w_comma_cw	| 3B odkaz na CW slova čárka ,
		0x001016| ww_does_cw	| 3B odkaz na CW pomocného slova pro DOES>
		0x001019| CALL do_DOES	| 4B volání do_DOES (návratová hodnota bude sloužit jako odkaz sem, nikoli pro return)
		0x00101D| w_at_cw	| 3B odkaz na CW slova @
		0x001020| w_exit_cw	| 3B odkaz na CW slova EXIT

----

Teď ho (značně později) použiju k vytvoření slova TEN takto `10 CONSTANT TEN`

----

* Provedení `10 CONSTANT TEN ( -- 10 )`
* INTERPRETER přečte `10`, usoudí, že nejde o slovo, ale o číslo a vloží ho na zásobník ( -- 10 )
* INTERPRETER přečte `CONSTANT`, usoudí, že jde o slovo, a spustí ho
	* tedy se spustí `w_docol_cw` s IP ukazujícím na další slovo a DT s hodnotou `0x001010 (w_CREATE_cw)`
	* DOCOL uloží IP na RST a dá do něj DT a skočí na NEXT
* `0x001010 (w_CREATE_cw)` přečte `TEN` a utvoří pro něj hlavičku ( -- 10 )
	.. code::
		
		Addr	| value		| comment
		--------+---------------+------------------------------
		0x001023| 0x001000	| 3B odkaz na předchozí hlavičku
		0x001026| 0x0		| 1B Attributy (žádné)
		0x001027| 3		| 1B délka slova
		0x00102A| TEN		| 3B název slova
		0x00102D| w_docreate_cw	| 3B CW: code_word vložený CREATE
		0x001030| ...		| <== sem přijde další kód, zatím sem ukazuje HERE
* `0x001013 (w_comma_cw)` vezme hodnotu ze zásobníku a zakompiluje ji jako CELL ( -- )
	.. code::
		
			|		| 
		--------+---------------+------------------------------
		0x001030| 0x00000A	| 3B 10 
		0x001033| ...		| <== sem přijde další kód, zatím sem ukazuje HERE
* `0x001016 (ww_does_cw)` zakompiluje odkaz na po něm následující adresu `0x001019 (CALL do_DOES)` do code word nového slova a dál zafunguje jako `w_exit_cw`, čili ukončí provádění, vyzvedne IP z RST a skočí na NEXT (čímž se vrátí do INTERPRETER)
	.. code::
		
			|		| 
		--------+---------------+------------------------------
		0x00102D| 0x001019	| 3B CW: adresa (CALL do_DOES) ze slova CONSTANT
* takže konstanta `TEN` teď vypadá takto:
	.. code::
		
		Addr	| value		| comment
		--------+---------------+------------------------------
		0x001023| 0x001000	| 3B odkaz na předchozí hlavičku
		0x001026| 0x0		| 1B Attributy (žádné)
		0x001027| 3		| 1B délka slova
		0x00102A| TEN		| 3B název slova
		0x00102D| 0x001019	| 3B CW: adresa (CALL do_DOES) ze slova CONSTANT
		0x001030| 0x00000A	| 3B 10 
* a konstanta `FIVE` teď vypadá takto:
	.. code::
		
		Addr	| value		| comment
		--------+---------------+------------------------------
		0x001033| 0x001000	| 3B odkaz na předchozí hlavičku
		0x001036| 0x0		| 1B Attributy (žádné)
		0x001037| 4		| 1B délka slova
		0x00103A| FIVE		| 4B název slova
		0x00103E| 0x001019	| 3B CW: adresa (CALL do_DOES) ze slova CONSTANT
		0x001031| 0x000005	| 3B 5 
	
	* A povšimněme si, že vůbec neobsahují kód po DOES>, bez ohledu na jeho délku. To může být i značná úspora pro složitější kód a víc konstant

----

A konečně k čemu je to dobré a co to zajímavého dělá - v `MOVING FORTH Part 3: Demystifying DOES> by Brad Rodriguez <https://www.bradrodriguez.com/papers/moving3.htm>`__ jsou k tomu obrázky, já si to tu rozepíšu krok po kroku, ale hlavní trik je, že se bude provádět kód v těle CONSTANT s daty z těla TEN (nebo FIVE, nebo ..).

----

* Provedení `TEN`
* INTERPRETER  přečte `TEN`, usoudí, že jde o slovo, a spustí ho
	.. code::
		
		Addr	| value		| comment
		--------+---------------+------------------------------
		0x001023| 0x001000	| 3B odkaz na předchozí hlavičku
		0x001026| 0x0		| 1B Attributy (žádné)
		0x001027| 3		| 1B délka slova
		0x00102A| TEN		| 3B název slova
		0x00102D| 0x001019	| 3B CW: adresa (CALL do_DOES) ze slova CONSTANT
	
* tedy skočí na adresu z jeho CW, čili `0x001019` s IP ukazujícím na další slovo a DT s hodnotou `0x001030` (adresa, kde je to `0x00000A` = 10)
	.. code::
	
		0x001019| CALL do_DOES	| 4B volání do_DOES (návratová hodnota bude sloužit jako odkaz sem, nikoli pro return)
		0x00101D| w_at_cw	| 3B odkaz na CW slova @
		0x001020| w_exit_cw	| 3B odkaz na CW slova EXIT
		
* na adrese `0x001019` je instrukce `CALL do_DOES`, tedy se na systémový zásobník uloží následující adresa  `0x00101D` jako bod pro návrat a skočí se na `do_DOES` 
* `do_DOES` uloží IP na RST, uloží DT na zásobník, do IP vyzvedne  hodnotu ze systémového zásobníku (`0x00101D`) a skočí na NEXT ( -- 0x001030 )
* NEXT zařídí, že se začnou vykonávat slova od `0x00101D` včetně
	.. code::
	
		0x00101D| w_at_cw	| 3B odkaz na CW slova @
	
	* `@` převede adresu na obsah ( 0x001030 -- 10 )
* NEXT zařídí, že se začnou vykonávat slova od `0x00101D` včetně
	.. code::
	
		0x001020| w_exit_cw	| 3B odkaz na CW slova EXIT
	
	* `w_exit_cw` zajistí návrat do volaného slova (10 -- 10)
* a to jsou právě ta slova, co byla při kompilování CONSTANT za tím DOES>
* (takže se vezme CELL z té adresy, čili 10 a uloží se na zásobník a tím to skončí) 



.. code::

	
	                           IP1
	               -----+-----+-----+---+-----------------------------------------------
	                ... | DUP | TEN | * | ...                                   
	               -----+-----+-----+---+------------------------------------------------
	                              \ 
	                               \ 
	                                \   DT
	                                 \| 0x102D  1E   1F
	     -----+-------+---+---+-----+---------+----+-----
	      ... | <link | A | 4 | TEN | TEN_cw  | 10 | ... 
	     -----+-------+---+---+-----+--\------+----+-----
	                                    \
	                                     \
	                                      \   DDT
	                                       \| 0x1019   1A   1B
	                 ----+------------+--------------+----+--------------------
	                     | ww_do_DOES | CALL do_DOES | @  | ... FORTH code ...
	                  ---+------------+-----/--------+----+---------------------
	                                       / 
	                                      / 
	                                     / 
	                                   |/ 
	                       -----+--------------+-----
	                        ... | do_DOES code | ...
	                       -----+--------------+-----

----

 A to je všechno. 

----


Problém s RAM a FLASH
--------------------------------------------------------------------------------

Problém je, že na ATMEGA nejde z RAM spouštět kód, takže pokud to má fungovat, tak CONSTANT musí být ve FLASH paměti, kam zase nejde psát.

* Ovšem pokud bych nastavil v tom `TEN_cw` nějaký bit jako příznak (FLAG_DoubleIndirect) a NEXT by to detekoval a provedl dvojitou dereferenci a navic nechal někde (Temp) tu druhou adresu ... tak by na `0x1019` byla jen 3B adresa `do_DOES code` a chodilo by to v RAM i ve FLASH ... a tak to udělám já :)
	* vlastně je to logicky daší krok v sekvenci STC->ITC :) opět nahradím instrukci volání pouhou adresou


New DOES_Explained with double indirect flag
--------------------------------------------------------------------------------

Podrobně je tohle vysvětlované v `MOVING FORTH Part 3: Demystifying DOES> by Brad Rodriguez <https://www.bradrodriguez.com/papers/moving3.htm>`__, zde nabízím jiný pohled/jiná slova pro totéž (abych si načtené rychle obnovil kdykoli později)

Mám FORTH pro MHF-002 (atmega2560, 3B=24bit CELL), motivační příklad je vytvoření dvou konstant TEN a FIVE pro nějaké další použití, vytvářet to budeme do RAM, ale chodit to bude jak z RAM, tak z FLASH

.. code::

	: CONSTANT CREATE , DOES> @ ;
	10 CONSTANT TEN ( -- 10 )
	5  CONSTANT FIVE ( -- 5 )

* Provedení `: CONSTANT CREATE , DOES> @ ;`
* `:` (je interpretováno) přečte nasledující slovo a vytvoří pro něj hlavičku, zahájí kompilaci (STATUS=F_COMPILING)	( -- )
	.. code::
		
		Addr	| value		| comment
		--------+---------------+------------------------------
		0x001000| 0x0009F0	| 3B odkaz na předchozí hlavičku
		0x001003| 0x40		| 1B Attributy (dočasně FLAG_HIDDEN)
		0x001004| 8		| 1B délka slova
		0x001005| CONSTANT	| 8B název slova
		0x00100D| w_docol_cw	| 3B CW: code_word dvojtečkové definice
		0x001010| ...		| <== sem přijde další kód, zatím sem ukazuje HERE
* `CREATE` není IMMEDIATE, takže se tam prostě vloží jeho **_cw** (zakompiluje se), provede se až po spuštění CONSTANT	( -- )
	.. code::
		
			|		| 
		--------+---------------+------------------------------
		0x001010| w_CREATE_cw	| 3B odkaz na CW slova CREATE
		0x001013| ...		| <== sem přijde další kód, zatím sem ukazuje HERE
* `,` (comma) není IMMEDIATE, takže se zakompiluje	(  -- )
	.. code::
		
			|		| 
		--------+---------------+------------------------------
		0x001013| w_comma_cw	| 3B odkaz na CW slova čárka ,
		0x001016| ...		| <== sem přijde další kód, zatím sem ukazuje HERE
* `DOES>` je IMMEDIATE, zakompiluje odkaz na **ww_does_cw** a odkaz na **do_DOES** ( -- )
	.. code::
		
			|		| 
		--------+---------------+------------------------------
		0x001016| ww_does_cw	| 3B odkaz na CW pomocného slova pro DOES>
		0x001019| do_DOES	| 3B adresa do_DOES, použiju Double Indirect funkci NEXT
		0x00101C| ...		| <== sem přijde další kód, zatím sem ukazuje HERE
	
	* tento krok ukončil definování, co se bude dělat při spuštění slova CONSTANT a zahájil definování, co se bude dělat při spuštění slov jím vytvořených (třeba TEN)
	* **ww_does_cw** udělá tu správnou věc až bude spuštěno (viz níže)
* `@` není IMMEDIATE, takže se tam prostě vloží jeho **_cw**, provede se až po spuštění TEN ( -- )
	.. code::
		
			|		| 
		--------+---------------+------------------------------
		0x00101C| w_at_cw	| 3B odkaz na CW slova @
		0x00101F| ...		| <== sem přijde další kód, zatím sem ukazuje HERE
* `;`  je IMMEDIATE, zakompiluje odkaz na **w_exit_cw**, shodí flag FLAG_HIDDEN  a ukončí definici (STATUS=F_INTERPRETING) ( -- )
	.. code::
		
			|		| 
		--------+---------------+------------------------------
		0x001003| 0x0		| 1B Attributy
		
			|		| 
		--------+---------------+------------------------------
		0x00101F| w_exit_cw	| 3B odkaz na CW slova EXIT
		0x001022| ...		| <== sem přijde další kód, zatím sem ukazuje HERE
* první řádek je hotov, mám slovo CONSTANT:

	.. code::
		
		Addr	| value		| comment
		--------+---------------+------------------------------
		0x001000| 0x0009F0	| 3B odkaz na předchozí hlavičku
		0x001003| 0x0		| 1B Attributy (žádné)
		0x001004| 8		| 1B délka slova
		0x001005| CONSTANT	| 8B název slova
		0x00100D| w_docol_cw	| 3B CW: code_word dvojtečkové definice
		0x001010| w_CREATE_cw	| 3B odkaz na CW slova CREATE
		0x001013| w_comma_cw	| 3B odkaz na CW slova čárka ,
		0x001016| ww_does_cw	| 3B odkaz na CW pomocného slova pro DOES>
		0x001019| do_DOES	| 3B adresa do_DOES, použiju Double Indirect funkci NEXT
		0x00101C| w_at_cw	| 3B odkaz na CW slova @
		0x00101F| w_exit_cw	| 3B odkaz na CW slova EXIT

----

Teď ho (značně později) použiju k vytvoření slova TEN takto `10 CONSTANT TEN`

----

* Provedení `10 CONSTANT TEN ( -- 10 )`
* INTERPRETER přečte `10`, usoudí, že nejde o slovo, ale o číslo a vloží ho na zásobník ( -- 10 )
* INTERPRETER přečte `CONSTANT`, usoudí, že jde o slovo, a spustí ho
	* tedy se spustí `w_docol_cw` s IP ukazujícím na další slovo a DT s hodnotou `0x001010 (w_CREATE_cw)`
	* DOCOL uloží IP na RST a dá do něj DT a skočí na NEXT
* `0x001010 (w_CREATE_cw)` přečte `TEN` a utvoří pro něj hlavičku ( -- 10 )
	.. code::
		
		Addr	| value		| comment
		--------+---------------+------------------------------
		0x001023| 0x001000	| 3B odkaz na předchozí hlavičku
		0x001026| 0x0		| 1B Attributy (žádné)
		0x001027| 3		| 1B délka slova
		0x00102A| TEN		| 3B název slova
		0x00102D| w_docreate_cw	| 3B CW: code_word vložený CREATE
		0x001030| ...		| <== sem přijde další kód, zatím sem ukazuje HERE
* `0x001013 (w_comma_cw)` vezme hodnotu ze zásobníku a zakompiluje ji jako CELL ( -- )
	.. code::
		
			|		| 
		--------+---------------+------------------------------
		0x001030| 0x00000A	| 3B 10 
		0x001033| ...		| <== sem přijde další kód, zatím sem ukazuje HERE
* `0x001016 (ww_does_cw)` zakompiluje odkaz na po něm následující adresu `0x001019 (do_DOES)` do code word nového slova s příznakem Double Indirect a a dál zafunguje jako `w_exit_cw`, čili ukončí provádění, vyzvedne IP z RST a skočí na NEXT (čímž se vrátí do INTERPRETER)
	.. code::
		
			|		| 
		--------+---------------+------------------------------
		0x00102D| 0x101019	| 3B CW: adresa (do_DOES) ze slova CONSTANT + Double Indirect flag
* takže konstanta `TEN` teď vypadá takto:
	.. code::
		
		Addr	| value		| comment
		--------+---------------+------------------------------
		0x001023| 0x001000	| 3B odkaz na předchozí hlavičku
		0x001026| 0x0		| 1B Attributy (žádné)
		0x001027| 3		| 1B délka slova
		0x00102A| TEN		| 3B název slova
		0x00102D| 0x101019	| 3B CW: adresa (CALL do_DOES) ze slova CONSTANT + Double Indirect flag
		0x001030| 0x00000A	| 3B 10 
* a konstanta `FIVE` teď vypadá takto:
	.. code::
		
		Addr	| value		| comment
		--------+---------------+------------------------------
		0x001033| 0x001000	| 3B odkaz na předchozí hlavičku
		0x001036| 0x0		| 1B Attributy (žádné)
		0x001037| 4		| 1B délka slova
		0x00103A| FIVE		| 4B název slova
		0x00103E| 0x101019	| 3B CW: adresa (CALL do_DOES) ze slova CONSTANT + Double Indirect flag
		0x001031| 0x000005	| 3B 5 
	
	* A povšimněme si, že vůbec neobsahují kód po DOES>, bez ohledu na jeho délku. To může být i značná úspora pro složitější kód a víc konstant

----

A konečně k čemu je to dobré a co to zajímavého dělá - v `MOVING FORTH Part 3: Demystifying DOES> by Brad Rodriguez <https://www.bradrodriguez.com/papers/moving3.htm>`__ jsou k tomu obrázky, já si to tu rozepíšu krok po kroku, ale hlavní trik je, že se bude provádět kód v těle CONSTANT s daty z těla TEN (nebo FIVE, nebo ..).

----

* Provedení `TEN`
* INTERPRETER  přečte `TEN`, usoudí, že jde o slovo, a spustí ho
	.. code::
		
		Addr	| value		| comment
		--------+---------------+------------------------------
		0x001023| 0x001000	| 3B odkaz na předchozí hlavičku
		0x001026| 0x0		| 1B Attributy (žádné)
		0x001027| 3		| 1B délka slova
		0x00102A| TEN		| 3B název slova
		0x00102D| 0x101019	| 3B CW: adresa (do_DOES) ze slova CONSTANT + Double Indirect flag
		(0x001030| 0x00000A	| 3B 10 )
	
* tedy vezme adresu z jeho CW, zjistí, že má nastavený FLAG_DoubleIndirect, takže adresa konečného cíle je uložena na adrese `0x001019`, tedy cílem je `do_DOES` 
* nastaví  IP na další slovo, DT na další buňku slova TEN (DT= `0x001030` (adresa kde je `0x00000A` = 10)) a Temp na adresu za zadresou  `0x001019` (Temp= `0x00101C` (adresa, kde je `@` z CONSTANT))
	.. code::
	
		0x001019| do_DOES	| 3B adresa do_DOES, použiju Double Indirect funkci NEXT
		0x00101C| w_at_cw	| 3B odkaz na CW slova @
		0x0010!F| w_exit_cw	| 3B odkaz na CW slova EXIT
		
* `do_DOES` uloží IP na RST, uloží DT na zásobník, do IP dá  hodnotu z `Temp` (`0x00101D`) a skočí na NEXT ( -- 0x001030 )
* NEXT zařídí, že se začnou vykonávat slova od `0x00101D` včetně
	.. code::
	
		0x00101D| w_at_cw	| 3B odkaz na CW slova @
	
	* `@` převede adresu na obsah ( 0x001030 -- 10 )
* NEXT zařídí, že se začnou vykonávat slova od `0x00101D` včetně
	.. code::
	
		0x001020| w_exit_cw	| 3B odkaz na CW slova EXIT
	
	* `w_exit_cw` zajistí návrat do volaného slova (10 -- 10)
* a to jsou právě ta slova, co byla při kompilování CONSTANT za tím DOES>
* (takže se vezme CELL z té adresy, čili 10 a uloží se na zásobník a tím to skončí) 



.. code::

	
	                           IP1
	               -----+-----+-----+---+-----------------------------------------------
	                ... | DUP | TEN | * | ...                                   
	               -----+-----+-----+---+------------------------------------------------
	                              \ 
	                               \ 
	                                \   DT
	                                 \| 0x102D  30   33
	     -----+-------+---+---+-----+---------+----+-----
	      ... | <link | A | 4 | TEN | TEN_cw  | 10 | ... 
	     -----+-------+---+---+-----+--\------+----+-----
	                                    \
	                                     \
	                                      \   DDT
	                                       \| 0x1019  1C   1F
	                    -----+------------+---------+----+--------------------
	                     ... | ww_do_DOES | do_DOES | @  | ... FORTH code ...
	                    -----+------------+---------+----+---------------------
	                                       / 
	                                      / 
	                                     / 
	                                   |/ 
	                       -----+--------------+-----
	                        ... | do_DOES code | ...
	                       -----+--------------+-----

----

 A to je všechno. 


