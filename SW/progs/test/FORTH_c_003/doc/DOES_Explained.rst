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

	: CONSTANT CREATE ['] , , DOES> @ ;
	10 CONSTANT TEN ( -- 10 )
	5  CONSTANT FIVE ( -- 5 )

* `:` (je interpretováno) přečte nasledující slovo a vytvoří pro něj hlavičku, zahájí kompilaci (STATUS=F_COMPILING)	( -- )
	.. code::
		
		Addr	| value		| comment
		--------+---------------+------------------------------
		0x1000	| 0x009FF0	| odkaz na předchozí hlavičku
		0x1003	| 0x40		| Attributy (dočasně FLAG_HIDDEN)
		0x1004	| 8		| délka slova
		0x1005	| CONSTANT	| název slova
		0x100D	| w_docol_cw	| code_word dvojtečkové definice
		0x1010	| ...		| <== sem přijde další kód, zatím sem ukazuje HERE
* `CREATE` není IMMEDIATE, takže se tam prostě vloží jeho **_cw**, provede se až po spuštění CONSTANT	( -- )
	.. code::
		
			|		| 
		--------+---------------+------------------------------
		0x1010	| w_CREATE_cw	| odkaz na CW slova CREATE
		0x1013	| ...		| <== sem přijde další kód, zatím sem ukazuje HERE
* `[']` je IMMEDIATE, takže načte další slovo `,` a vloží ho na zásobník	( -- w_comma_cw )
	.. code::
		
			|		| 
		--------+---------------+------------------------------
		0x1013	| ...		| <== sem přijde další kód, zatím sem ukazuje HERE
* `,` (ta druhá čárka) je IMMEDIATE, takže načte CELL ze zásobníku a zakompiluje ji	( w_comma_cw -- )
	.. code::
		
			|		| 
		--------+---------------+------------------------------
		0x1013	| w_comma_cw	| odkaz na CW slova čárka ,
		0x1016	| ...		| <== sem přijde další kód, zatím sem ukazuje HERE
* `DOES>` je IMMEDIATE, zakompiluje odkaz na **ww_does_cw** a asm kód pro CALL do_DOES ( -- )
	.. code::
		
			|		| 
		--------+---------------+------------------------------
		0x1016	| ww_does_cw	| odkaz na CW pomocného slova pro DOES>
		0x1019	| call do_DOES	| 4B volání do_DOES (návratová hodnota bude sloužit jako odkaz sem, nikoli pro return
		0x101D	| ...		| <== sem přijde další kód, zatím sem ukazuje HERE
* `@` není IMMEDIATE, takže se tam prostě vloží jeho **_cw**, provede se až po spuštění TEN ( -- )
	.. code::
		
			|		| 
		--------+---------------+------------------------------
		0x101D	| w_at_cw	| odkaz na CW slova @
		0x1020	| ...		| <== sem přijde další kód, zatím sem ukazuje HERE
* `;`  je IMMEDIATE, zakompiluje odkaz na **w_exit_cw** a ukončí definici (STATUS=F_INTERPRETING) ( -- )
	.. code::
		
			|		| 
		--------+---------------+------------------------------
		0x1020	| w_exit_cw	| odkaz na CW slova EXIT
		0x1023	| ...		| <== sem přijde další kód, zatím sem ukazuje HERE
* první řádek je hotov.

