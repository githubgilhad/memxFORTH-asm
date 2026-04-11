; .. vim: ft=asm showbreak=--»\  noexpandtab fileencoding=utf-8 nomodified   wrap textwidth=0 foldmethod=marker foldmarker={{{,}}} foldcolumn=4 ruler showcmd lcs=tab\:|- list tabstop=8 noexpandtab nosmarttab softtabstop=0 shiftwidth=0 linebreak  tags=./tags;,tags; 


DEFWORD w_LOGO,		0,		"LOGO",		f_docol, yes		; (  --  ) do something TODO [----]
	P24s	w_LIT3_cw, 0x0000F0, w_DEF_COLOR_cw, w_CLS_cw												; $F0 ( VGA_WHITE ) DEF_COLOR CLS
	P24s w_MAX_COLUMNS_cw, w_zero_cw, ww_do_do_cw													; MAX_COLUMNS 0 DO ( lines )
2:
		P24s w_zero_cw, w_I_cw, w_LIT3_cw, 0x000089, w_VRAM_yx_set_cw										; 	0 I $89  VRAM_yx!
		P24s w_LIT3_cw, 0x000002, w_I_cw, w_LIT3_cw, 0x000089, w_VRAM_yx_set_cw									; 	2 I $89  VRAM_yx!
		P24s w_LIT3_cw, 0x000005, w_I_cw, w_LIT3_cw, 0x000089, w_VRAM_yx_set_cw									; 	5 I $89  VRAM_yx!
		P24s w_MAX_LINES_cw, w_one_minus_cw, w_I_cw, w_LIT3_cw, 0x000089, w_VRAM_yx_set_cw							; 	MAX_LINES 1- I $89  VRAM_yx!
		P24s w_MAX_LINES_cw, w_LIT3_cw, 0x000003, w_minus_cw, w_I_cw, w_LIT3_cw, 0x000089, w_VRAM_yx_set_cw					; 	MAX_LINES 3 - I $89  VRAM_yx! 
	P24s ww_do_loop_cw, /*0xFFFFA0,*/ 2b - .														; LOOP
	
	P24s w_MAX_LINES_cw, w_zero_cw, ww_do_do_cw													; MAX_LINES 0  DO ( columns )
2:
		P24s w_I_cw, w_zero_cw, w_LIT3_cw, 0x00007C, w_VRAM_yx_set_cw										; 	I 0 $7c VRAM_yx!
		P24s w_I_cw, w_MAX_COLUMNS_cw, w_one_minus_cw, w_LIT3_cw, 0x00007C, w_VRAM_yx_set_cw							; 	I MAX_COLUMNS 1- $7c VRAM_yx!
	P24s ww_do_loop_cw, /* 0xFFFFDC */  2b - .														; LOOP
	P24s w_LITSTRING_cw																; S" MEGA HOME FORTH"
		.byte	0x0F
		.ascii "MEGA HOME FORTH"
	P24s w_DUP_cw, w_MAX_COLUMNS_cw, w_SWAP_cw, w_minus_cw, w_half_cw, w_one_cw, w_SWAP_cw, w_CUR_yx_cw, w_TELL_cw					; DUP MAX_COLUMNS SWAP - 2/ 1 SWAP CUR_yx TELL 
	P24s w_VER_NUM_cw, w_DUP_cw, w_MAX_COLUMNS_cw, w_SWAP_cw, w_minus_cw, w_half_cw, w_LIT3_cw, 0x000003, w_SWAP_cw, w_CUR_yx_cw, w_TELL_cw
																			; VER_NUM     DUP MAX_COLUMNS SWAP - 2/ 3 SWAP CUR_yx TELL 
	P24s w_VER_MESSAGE_cw, w_DUP_cw, w_MAX_COLUMNS_cw, w_SWAP_cw, w_minus_cw, w_half_cw, w_LIT3_cw, 0x000004, w_SWAP_cw, w_CUR_yx_cw, w_TELL_cw
																			; VER_MESSAGE DUP MAX_COLUMNS SWAP - 2/ 4 SWAP CUR_yx TELL 
	P24s w_MAX_LINES_cw, w_LIT3_cw, 0x000002, w_minus_cw, w_LIT3_cw, 0x000003, w_CUR_yx_cw								; MAX_LINES 2 - 3 CUR_yx
	P24s w_LITSTRING_cw																; ." from " 
		.byte	0x05
		.ascii "from "
	P24s w_TELL_cw, w_VER_DATE_cw, w_TELL_cw, w_SPACE_cw, w_VER_TIME_cw, w_TELL_cw									; VER_DATE TELL SPACE VER_TIME TELL
	P24s w_zero_cw, w_zero_cw, w_LIT3_cw, 0x000080, w_VRAM_yx_set_cw										; 0 0 $80 VRAM_yx!
	P24s w_zero_cw, w_MAX_COLUMNS_cw, w_one_minus_cw, w_LIT3_cw, 0x000082, w_VRAM_yx_set_cw								; 0 MAX_COLUMNS 1- $82 VRAM_yx!
	P24s w_MAX_LINES_cw, w_one_minus_cw, w_zero_cw, w_LIT3_cw, 0x000086, w_VRAM_yx_set_cw								; MAX_LINES 1- 0 $86 VRAM_yx!
	P24s w_MAX_LINES_cw, w_one_minus_cw, w_MAX_COLUMNS_cw, w_one_minus_cw, w_LIT3_cw, 0x000088, w_VRAM_yx_set_cw					; MAX_LINES 1- MAX_COLUMNS 1- $88 VRAM_yx!
	P24s w_LIT3_cw, 0x000002, w_zero_cw, w_LIT3_cw, 0x000083, w_VRAM_yx_set_cw									; 2 0 $83 VRAM_yx!
	P24s w_LIT3_cw, 0x000002, w_MAX_COLUMNS_cw, w_one_minus_cw, w_LIT3_cw, 0x000085, w_VRAM_yx_set_cw						; 2 MAX_COLUMNS 1- $85 VRAM_yx!
	P24s w_LIT3_cw, 0x000005, w_zero_cw, w_LIT3_cw, 0x000083, w_VRAM_yx_set_cw									; 5 0 $83 VRAM_yx!
	P24s w_LIT3_cw, 0x000005, w_MAX_COLUMNS_cw, w_one_minus_cw, w_LIT3_cw, 0x000085, w_VRAM_yx_set_cw						; 5 MAX_COLUMNS 1- $85 VRAM_yx!
	P24s w_MAX_LINES_cw, w_LIT3_cw, 0x000003, w_minus_cw, w_zero_cw, w_LIT3_cw, 0x000083, w_VRAM_yx_set_cw						; MAX_LINES 3 -  0 $83 VRAM_yx!
	P24s w_MAX_LINES_cw, w_LIT3_cw, 0x000003, w_minus_cw, w_MAX_COLUMNS_cw, w_one_minus_cw, w_LIT3_cw, 0x000085, w_VRAM_yx_set_cw			; MAX_LINES 3 - MAX_COLUMNS 1- $85 VRAM_yx!
	P24s w_zero_cw, w_LIT3_cw, 0x0000D8, w_ROW_COLOR_Y_cw												; 0 $D8 ( VGA_YELLOW + VGA_BG_DKRED )	ROW_COLOR_Y
	P24s w_one_cw, w_LIT3_cw, 0x0000D8, w_ROW_COLOR_Y_cw												; 1 $D8 ( VGA_YELLOW + VGA_BG_DKRED )	ROW_COLOR_Y
	P24s w_LIT3_cw, 0x000002, w_LIT3_cw, 0x0000D8, w_ROW_COLOR_Y_cw											; 2 $D8 ( VGA_YELLOW + VGA_BG_DKRED )	ROW_COLOR_Y
	P24s w_LIT3_cw, 0x000003, w_LIT3_cw, 0x0000D4, w_ROW_COLOR_Y_cw											; 3 $D4 ( VGA_YELLOW + VGA_BG_DKGREEN )	ROW_COLOR_Y
	P24s w_LIT3_cw, 0x000004, w_LIT3_cw, 0x0000D4, w_ROW_COLOR_Y_cw											; 4 $D4 ( VGA_YELLOW + VGA_BG_DKGREEN )	ROW_COLOR_Y
	P24s w_MAX_LINES_cw, w_LIT3_cw, 0x000002, w_minus_cw, w_LIT3_cw, 0x0000D2, w_ROW_COLOR_Y_cw							; MAX_LINES 2 -  $D2 ( VGA_YELLOW + VGA_BG_DKBLUE )	ROW_COLOR_Y
	P24s w_LIT3_cw, 0x000006, w_one_cw, w_CUR_yx_cw, w_LIT3_cw, 0x00003E, w_EMIT_cw									; 6 1 CUR_yx '>' EMIT
	P24s w_exit_cw



