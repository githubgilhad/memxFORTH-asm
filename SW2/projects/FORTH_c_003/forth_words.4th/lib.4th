.S 1 2 3 4 5 .S
HEADLESS

: ALLOT HERE +! ;

: [COMPILE] IMMEDIATE
	PARSE-NAME			(     ( -- c-addr u ) )
	DUP 0= IF			(  (3) )
		2DROP EXIT		(  nic ke zpracování )
	THEN				(  3: )
	
	FIND-NAME ?DUP			(  ( c-addr u --  xt flag flag | c-addr u 0 ) )
	IF				(  (3) word found )
		DROP			( zahodit flag )
		,
	ELSE				(  3:(4) word found  // nenalezeno -> číslo? )
		CERROR			(  ( c-addr u -- ) )
		EXIT
	THEN				(  4: word found )
;

: CASE IMMEDIATE
	0 >L		( push 0 to L to mark the bottom of the stack )
	'C' EMIT
;

: OF IMMEDIATE
	LIT3 OVER ,	( compile OVER )
	LIT3 = ,		( compile = )
	[COMPILE] IF	( compile IF )
	LIT3 DROP ,  	( compile DROP )
;

: ENDOF IMMEDIATE
	[COMPILE] ELSE	( ENDOF is the same as ELSE )
;

: ENDCASE IMMEDIATE
	LIT3 DROP ,	( compile DROP )

	( keep compiling THEN until we get to our zero marker )
	BEGIN
		L> ?DUP
	WHILE
		>L
		[COMPILE] THEN
		'c' EMIT
	REPEAT
;



: S" IMMEDIATE		( -- addr len )
	TCB.STATE C@ IF	( compiling? )
		LIT3 LITSTRING ,	( compile LITSTRING )
		HERE @		( save the address of the length word on the stack )
		0 C,		( dummy 1 byte length - we don't know what it is yet )
		BEGIN
			BEGIN KEY ?DUP UNTIL ( get next character of the string )
			DUP '"' <>
		WHILE
			C,		( copy character )
		REPEAT
		DROP		( drop the double quote character at the end )
		DUP		( get the saved address of the length word )
		HERE @ SWAP -	( calculate the length )
		1 -		( subtract 1 (because we measured from the start of the length word) )
		SWAP C!		( and back-fill the length location )
	ELSE		( immediate mode )
		HERE @		( get the start address of the temporary space )
		BEGIN
			BEGIN KEY ?DUP UNTIL ( get next character of the string )
			DUP '"' <>
		WHILE
			OVER C!		( save next character )
			1+		( increment address )
		REPEAT
		DROP		( drop the final " character )
		HERE @ -	( calculate the length )
		HERE @		( push the start address )
		SWAP 		( addr len )
	THEN
;
: ." IMMEDIATE		( -- )
	TCB.STATE C@ IF	( compiling? )
		[COMPILE] S"	( read the string, and compile LITSTRING, etc. )
		LIT3 TELL ,	( compile the final TELL )
	ELSE
		( In immediate mode, just read characters and print them until we get
		  to the ending double quote. )
		BEGIN
			BEGIN KEY ?DUP UNTIL ( get next character of the string )
			DUP '"' = IF
				DROP	( drop the double quote character )
				EXIT	( return from this function )
			THEN
			EMIT
		REPEAT
THEN
;


: DEFER CREATE , DOES> @ EXECUTE ;
: IS IMMEDIATE [ ' TO , ] ;

HEADMORE

