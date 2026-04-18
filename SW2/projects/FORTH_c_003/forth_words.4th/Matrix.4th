60 VALUE num_lines
5 VALUE min_len
25 VALUE max_len
1 VALUE wait
VARIABLE lines num_lines 1- CELLS ALLOT ( array of lines )
0 0 0 VALUE x VALUE y VALUE l ( line=CELL={y x l} )
: RANDOM_R ( max min -- rand ) DUP2 - RANDOM + SWAP DROP ;
: show_line ( addr -- ) DUP @ C>3B TO l TO x TO y
	MAX_LINES y > IF  y x 127 33 RANDOM_R VRAM_yx! THEN
	l y > IFNOT y l - DUP MAX_LINES < IF x 32 VRAM_yx! ELSE DROP -1 TO y MAX_COLUMNS RANDOM TO x max_len min_len RANDOM_R TO l THEN THEN
	y 1+ x l 3B>C SWAP ! ;
: matrix_setup ( -- )
	MAX_LINES 0 DO I 2 RANDOM IF VGA_DKGREEN ELSE VGA_GREEN THEN ROW_COLOR_Y LOOP
	HEADLESS lines num_lines 0 DO DUP DUP MAX_LINES 5 - RANDOM SWAP B! 1+ DUP MAX_COLUMNS RANDOM SWAP B! 1+ DUP max_len min_len RANDOM_R  SWAP B! 1+ SWAP show_line LOOP DROP HEADMORE
	;
: matrix matrix_setup
 	BEGIN
		HEADLESS lines num_lines 2/  0 DO DUP show_line 3 + LOOP DROP HEADMORE wait WAIT
		HEADLESS lines num_lines num_lines  2/  DO DUP show_line 3 + LOOP DROP HEADMORE wait WAIT
		KEYpress
	UNTIL
	LOGO
	;

