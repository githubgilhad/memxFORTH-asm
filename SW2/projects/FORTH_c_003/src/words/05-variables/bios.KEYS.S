; .. vim: ft=asm showbreak=--»\  noexpandtab fileencoding=utf-8 nomodified   wrap textwidth=0 foldmethod=marker foldmarker={{{,}}} foldcolumn=4 ruler showcmd lcs=tab\:|- list tabstop=8 noexpandtab nosmarttab softtabstop=0 shiftwidth=0 linebreak  
#include "ScanToASCII.h"


DEFCONSTI1 "BL",		BL,		' ',		line=3
DEFCONSTI1 "CR",		CR,		'\r',		line=3
DEFCONSTI1 "LF",		LF,		'\n',		line=3
/**/



DEFVAR "PROMPT_X",	PROMPT_X
DEFVAR "PROMPT_Y",	PROMPT_Y




DEFCONSTI1 "kb_Esc",		"kb_Esc",	kb_Esc,		line=3
DEFCONSTI1 "kb_Tab",		"kb_Tab",	kb_Tab,		line=3
DEFCONSTI1 "kb_Back",		"kb_Back",	kb_Back,	line=3
DEFCONSTI1 "kb_Enter",		"kb_Enter",	kb_Enter,	line=3

DEFCONSTI1 "kb_CapsLck",	"kb_CapsLck",	kb_CapsLck,	line=3
DEFCONSTI1 "kb_NumLck",		"kb_NumLck",	kb_NumLck,	line=3

DEFCONSTI1 "kb_ShiftL",		"kb_ShiftL",	kb_ShiftL,	line=3
DEFCONSTI1 "kb_ShiftR",		"kb_ShiftR",	kb_ShiftR,	line=3
DEFCONSTI1 "kb_CtrlL",		"kb_CtrlL",	kb_CtrlL,	line=3
DEFCONSTI1 "kb_CtrlR",		"kb_CtrlR",	kb_CtrlR,	line=3
DEFCONSTI1 "kb_AltL",		"kb_AltL",	kb_AltL,	line=3
DEFCONSTI1 "kb_AltR",		"kb_AltR",	kb_AltR,	line=3

DEFCONSTI1 "kb_WinL",		"kb_WinL",	kb_WinL,	line=3
DEFCONSTI1 "kb_WinR",		"kb_WinR",	kb_WinR,	line=3

DEFCONSTI1 "kb_Menu",		"kb_Menu",	kb_Menu,	line=3

DEFCONSTI1 "kb_xStar",		"kb_xStar",	kb_xStar,	line=3
DEFCONSTI1 "kb_xMinus",		"kb_xMinus",	kb_xMinus,	line=3
DEFCONSTI1 "kb_xPlus",		"kb_xPlus",	kb_xPlus,	line=3
DEFCONSTI1 "kb_xSlash",		"kb_xSlash",	kb_xSlash,	line=3
DEFCONSTI1 "kb_xDot",		"kb_xDot",	kb_xDot,	line=3
DEFCONSTI1 "kb_xEnter",		"kb_xEnter",	kb_xEnter,	line=3

DEFCONSTI1 "kb_PrtScr1",	"kb_PrtScr1",	kb_PrtScr1,	line=3
DEFCONSTI1 "kb_PrtScr2",	"kb_PrtScr2",	kb_PrtScr2,	line=3
DEFCONSTI1 "kb_ScrLck",		"kb_ScrLck",	kb_ScrLck,	line=3

DEFCONSTI1 "kb_Ins",		"kb_Ins",	kb_Ins,		line=3
DEFCONSTI1 "kb_Del",		"kb_Del",	kb_Del,		line=3
DEFCONSTI1 "kb_Home",		"kb_Home",	kb_Home,	line=3
DEFCONSTI1 "kb_End",		"kb_End",	kb_End,		line=3
DEFCONSTI1 "kb_PgUp",		"kb_PgUp",	kb_PgUp,	line=3
DEFCONSTI1 "kb_PgDn",		"kb_PgDn",	kb_PgDn,	line=3

DEFCONSTI1 "kb_Left",		"kb_Left",	kb_Left,	line=3
DEFCONSTI1 "kb_Up",		"kb_Up",	kb_Up,		line=3
DEFCONSTI1 "kb_Down",		"kb_Down",	kb_Down,	line=3
DEFCONSTI1 "kb_Right",		"kb_Right",	kb_Right,	line=3

DEFCONSTI1 "kb_x0",		"kb_x0",	kb_x0,		line=3
DEFCONSTI1 "kb_x1",		"kb_x1",	kb_x1,		line=3
DEFCONSTI1 "kb_x2",		"kb_x2",	kb_x2,		line=3
DEFCONSTI1 "kb_x3",		"kb_x3",	kb_x3,		line=3
DEFCONSTI1 "kb_x4",		"kb_x4",	kb_x4,		line=3
DEFCONSTI1 "kb_x5",		"kb_x5",	kb_x5,		line=3
DEFCONSTI1 "kb_x6",		"kb_x6",	kb_x6,		line=3
DEFCONSTI1 "kb_x7",		"kb_x7",	kb_x7,		line=3
DEFCONSTI1 "kb_x8",		"kb_x8",	kb_x8,		line=3
DEFCONSTI1 "kb_x9",		"kb_x9",	kb_x9,		line=3

DEFCONSTI1 "kb_F1",		"kb_F1",	kb_F1,		line=3
DEFCONSTI1 "kb_F2",		"kb_F2",	kb_F2,		line=3
DEFCONSTI1 "kb_F3",		"kb_F3",	kb_F3,		line=3
DEFCONSTI1 "kb_F4",		"kb_F4",	kb_F4,		line=3
DEFCONSTI1 "kb_F5",		"kb_F5",	kb_F5,		line=3
DEFCONSTI1 "kb_F6",		"kb_F6",	kb_F6,		line=3
DEFCONSTI1 "kb_F7",		"kb_F7",	kb_F7,		line=3
DEFCONSTI1 "kb_F8",		"kb_F8",	kb_F8,		line=3
DEFCONSTI1 "kb_F9",		"kb_F9",	kb_F9,		line=3
DEFCONSTI1 "kb_F10",		"kb_F10",	kb_F10,		line=3
DEFCONSTI1 "kb_F11",		"kb_F11",	kb_F11,		line=3
DEFCONSTI1 "kb_F12",		"kb_F12",	kb_F12,		line=3

DEFCONSTI1 "kb_Pause",		"kb_Pause",	kb_Pause,	line=3
