;;	
;;	
;;	Typická implementace (FORTH-83 styl)
;;	Pomocná proměnná
;;	
;;	VARIABLE HANDLER   \ uložený stav pro CATCH
;;	
;;	CATCH
;;	
;;	: CATCH  ( xt -- n )
;;	   SP@ >R            \ uložit datový zásobník
;;	   RP@ HANDLER !     \ uložit návratový zásobník
;;	   EXECUTE           \ spustit slovo
;;	   R> DROP           \ úklid, pokud nenastala chyba
;;	   0                 \ žádná chyba
;;	;
;;	
;;	THROW
;;	
;;	: THROW  ( n -- )
;;	   ?DUP IF
;;	      HANDLER @ RP!  \ obnovit návratový zásobník
;;	      R> SWAP >R     \ upravit návrat
;;	      SP!            \ obnovit datový zásobník
;;	      EXIT           \ návrat do CATCH
;;	   THEN
;;	;
;;	
;;	    ⚠️ Přesná podoba se liší podle implementace (hlavně práce s RP!, SP!), ale logika je vždy stejná.
;;	
;;	0 THROW   \ pokračuje se normálně
;;	
;;	ErrorNumber THROW \ okamžitě ukončí výpočet
;;	
;;	    žádné návraty z vnořených slov
;;	
;;	    žádné EXIT
;;	
;;	    tvrdý skok zpět do CATCH
;;	
;;	3️⃣ Není to klasický návrat
;;	
;;	Je to řízený únik (non-local exit), podobný:
;;	
;;	    longjmp v C
;;	
;;	    výjimkám v moderních jazycích
;;	
;;	Minimální příklad
;;	
;;	: FAIL   -13 THROW ;
;;	
;;	: TEST
;;	   ['] FAIL CATCH
;;	   IF ." Chyba" ELSE ." OK" THEN
;;	;
;;	
