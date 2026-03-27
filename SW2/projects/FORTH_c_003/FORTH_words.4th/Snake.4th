
NEXTcounter .h .h 
HEADLESS

( keys 8462 on numeric keyboard, or numbers )
( item )
: brick $A0 ;
( score, max )
0 0 0 0 VALUE score VALUE maxscore VALUE crash VALUE grow
: show_score
	1 2 CUR_yx  ." SCORE: " score .
	score maxscore > IF score TO maxscore 1 MAX_COLUMNS 2/ 1- CUR_yx brick EMIT $4D ROW_COLOR THEN
	1 MAX_COLUMNS 2/   CUR_yx  ." MAX: " maxscore .
	;
( wall )
: wall CLS
	0 BEGIN 0 OVER brick VRAM_yx! 2 OVER brick VRAM_yx! MAX_LINES 1- OVER brick VRAM_yx!  1+ DUP MAX_COLUMNS  = UNTIL DROP
	0 BEGIN                     DUP  0 brick VRAM_yx! DUP MAX_COLUMNS 1-  brick VRAM_yx!  1+ DUP MAX_LINES  = UNTIL DROP
	1 2 CUR_yx ." SCORE:" 0 . SPACE
	;
: is_wall ( c -- flag ) brick = ;
: test_wall ( y x --  )  VRAM_yx@ is_wall IF 1 TO crash THEN ;
( movement )
: do_step ( y x d -- y x )
	CASE
	0 OF SWAP 1+ SWAP ENDOF
	1 OF 1- ENDOF
	2 OF 1+ ENDOF
	3 OF SWAP 1- SWAP ENDOF
	ENDCASE ;
: key_to_dir ( olddir key -- newdir ) CASE
	kb_Down OF DROP 0 ENDOF
	kb_Left OF DROP 1 ENDOF
	kb_Right OF DROP 2 ENDOF
	kb_Up OF DROP 3 ENDOF
	ENDCASE ;
: body_str S" abc#de#fg#hi#jkl" ; : body_str_addr body_str DROP ;
( : body_str S" -##fg#hi#jkl" ; : body_str_addr body_str DROP ; )
: head_str S" v<>^" ; : head_str_addr head_str DROP ;
: tail_str S" ;=~!" ; : tail_str_addr tail_str DROP ;
: fruit_str S" @$&*" ; : fruit_str_addr fruit_str DROP ;
( body )
: show_body ( y x old new ) SWAP 4* + body_str_addr + C@ VRAM_yx! ;
: is_body ( c -- flag ) body_str ISINSTR ;
: test_body ( y x --  )  VRAM_yx@ is_body IF 2 TO crash THEN ;
( fruit )
: random_fruit fruit_str RANDOM + C@ ;
: show_fruit ( -- ) 5 RANDOM IFNOT MAX_LINES 4 - RANDOM 3 + MAX_COLUMNS 2 - RANDOM 1+ DUP2 VRAM_yx@ BL = IF random_fruit VRAM_yx! ELSE DROP2 THEN THEN ;
: is_fruit ( c -- flag ) fruit_str ISINSTR ;
: test_fruit ( y x --  ) VRAM_yx@ is_fruit IF 1 TO grow 1 +TO score THEN ;
( tail )
0 0 0 VALUE tx VALUE ty VALUE td
: hide_tail ty tx BL VRAM_yx! ;
: is_tail ( c -- flag ) tail_str ISINSTR ;
: show_tail ty tx tail_str_addr td + C@ VRAM_yx! ;
: test_tail ( y x --  )  VRAM_yx@ is_tail IF 2 TO crash THEN ;
: move_tail
	grow crash ||
	IFNOT
		hide_tail
		ty tx td do_step DUP2 TO tx TO ty VRAM_yx@ body_str POS IFNOT 10 TO crash ELSE 3 AND  TO td THEN
		show_tail
	THEN
	;
( head )
0 0 0 0 VALUE hx VALUE hy VALUE hd VALUE hdd
: hide_head hy hx BL VRAM_yx! ;
: show_head hy hx head_str_addr hd + C@ VRAM_yx! ;
: move_head
	10 WAIT hide_head
	hy hx hd ( body here )
		hy hx ( new head )
			hd KEYpress key_to_dir ( dir )
			DUP TO hdd
			do_step
		DUP2 test_body
		DUP2 test_tail
		DUP2 test_wall
		DUP2 test_fruit
		crash IF DROP DROP2 DROP2 ELSE
		TO hx TO hy hdd TO hd
		hd ( y x old new ) show_body
		THEN
	show_head ;

: snake_game 
		wall show_score
		MAX_COLUMNS 2/ TO hx
		MAX_LINES 2/ TO hy
		2 TO hd
		0 TO score
		show_head
		hx 1- TO tx hy TO ty hd TO td show_tail
		0 TO crash
		BEGIN
			0 TO grow
			move_head
			move_tail
			show_fruit
			show_score
(			BEGIN KEYpress 0= UNTIL )
		crash UNTIL
		2 5 CUR_yx $D8 ROW_COLOR crash 1 = IF  ." * Avoid Walls ! *" ELSE ." * Avoid yourself *" THEN
	;
: snake_wrap
	BEGIN
		snake_game
		MAX_LINES 1- 5 CUR_yx $4D ROW_COLOR ." Press Space / Q " 
		BEGIN 
			BEGIN KEYpress ?DUP UNTIL ( non-zero key pressed)
			DUP .
			DUP 'q' = IF EXIT THEN 
		32 = UNTIL
	REPEAT
;
: snake
	snake_wrap
	CLS '>' EMIT
;

: hb  ( c old new  -- ) ( hack body character ) SWAP 4* + body_str_addr + C! ;
: full_body 
				0 0 1 2 show_body
				0 1 2 2 show_body
				0 2 2 3 show_body
				1 2 3 3 show_body
				2 2 3 0 show_body
				2 1 0 0 show_body
				2 0 0 1 show_body
				1 0 1 1 show_body
	4 1 CUR_yx
;

6 VALUE sp
: ascii_fill sp 0 DO SPACE LOOP ;
: ascii 
	  10   0 DO SPACE SPACE I . SPACE I EMIT ascii_fill  LOOP 
	 100  10 DO SPACE       I . SPACE I EMIT ascii_fill  LOOP 
	$100 100 DO             I . SPACE I EMIT ascii_fill  LOOP 
;

130 2 3 hb full_body ( up - left )
128 1 2 hb full_body ( left - down)
137 2 2 hb full_body ( left - left )

HEADMORE

snake


0 1
1 1
1 2
2 2
2 3
3 3
3 0
0 0













