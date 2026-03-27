; .. vim: ft=asm showbreak=--»\  noexpandtab fileencoding=utf-8 nomodified   wrap textwidth=0 foldmethod=marker foldmarker={{{,}}} foldcolumn=4 ruler showcmd lcs=tab\:|- list tabstop=8 noexpandtab nosmarttab softtabstop=0 shiftwidth=0 linebreak  
#include "ScanToASCII.h"

DEFCONSTI1 "BL",		BL,		' ',		line=3
// DEFCONSTI1 "CR",		CR,		'\r',		line=3
// DEFCONSTI1 "LF",		LF,		'\n',		line=3
//
// DEFVAR "PROMPT_X",	PROMPT_X
// DEFVAR "PROMPT_Y",	PROMPT_Y


DEFCONSTI1	"kb_Esc",	"kb_Esc",	kb_Esc,		line=3
DEFCONSTI1	"kb_Tab",	"kb_Tab",	kb_Tab,		line=3
DEFCONSTI1	"kb_Back",	"kb_Back",	kb_Back,	line=3
DEFCONSTI1	"kb_Enter",	"kb_Enter",	kb_Enter,	line=3
DEFCONSTI1	"kb_Space",	"kb_Space",	kb_Space,	line=3

DEFCONSTI1	"kb_CapsLck",	"kb_CapsLck",	kb_CapsLck,	line=3
DEFCONSTI1	"kb_NumLck",	"kb_NumLck",	kb_NumLck,	line=3

DEFCONSTI1	"kb_ShiftL",	"kb_ShiftL",	kb_ShiftL,	line=3
DEFCONSTI1	"kb_ShiftR",	"kb_ShiftR",	kb_ShiftR,	line=3
DEFCONSTI1	"kb_CtrlL",	"kb_CtrlL",	kb_CtrlL,	line=3
DEFCONSTI1	"kb_CtrlR",	"kb_CtrlR",	kb_CtrlR,	line=3
DEFCONSTI1	"kb_AltL",	"kb_AltL",	kb_AltL,	line=3
DEFCONSTI1	"kb_AltR",	"kb_AltR",	kb_AltR,	line=3

DEFCONSTI1	"kb_WinL",	"kb_WinL",	kb_WinL,	line=3
DEFCONSTI1	"kb_WinR",	"kb_WinR",	kb_WinR,	line=3

DEFCONSTI1	"kb_Menu",	"kb_Menu",	kb_Menu,	line=3

DEFCONSTI1	"kb_xStar",	"kb_xStar",	kb_xStar,	line=3
DEFCONSTI1	"kb_xMinus",	"kb_xMinus",	kb_xMinus,	line=3
DEFCONSTI1	"kb_xPlus",	"kb_xPlus",	kb_xPlus,	line=3
DEFCONSTI1	"kb_xSlash",	"kb_xSlash",	kb_xSlash,	line=3
DEFCONSTI1	"kb_xDot",	"kb_xDot",	kb_xDot,	line=3
DEFCONSTI1	"kb_xEnter",	"kb_xEnter",	kb_xEnter,	line=3

DEFCONSTI1	"kb_PrtScr1",	"kb_PrtScr1",	kb_PrtScr1,	line=3
DEFCONSTI1	"kb_PrtScr2",	"kb_PrtScr2",	kb_PrtScr2,	line=3
DEFCONSTI1	"kb_ScrLck",	"kb_ScrLck",	kb_ScrLck,	line=3

DEFCONSTI1	"kb_Ins",	"kb_Ins",	kb_Ins,		line=3
DEFCONSTI1	"kb_Del",	"kb_Del",	kb_Del,		line=3
DEFCONSTI1	"kb_Home",	"kb_Home",	kb_Home,	line=3
DEFCONSTI1	"kb_End",	"kb_End",	kb_End,		line=3
DEFCONSTI1	"kb_PgUp",	"kb_PgUp",	kb_PgUp,	line=3
DEFCONSTI1	"kb_PgDn",	"kb_PgDn",	kb_PgDn,	line=3

DEFCONSTI1	"kb_Left",	"kb_Left",	kb_Left,	line=3
DEFCONSTI1	"kb_Up",	"kb_Up",	kb_Up,		line=3
DEFCONSTI1	"kb_Down",	"kb_Down",	kb_Down,	line=3
DEFCONSTI1	"kb_Right",	"kb_Right",	kb_Right,	line=3

DEFCONSTI1	"kb_x0",	"kb_x0",	kb_x0,		line=3
DEFCONSTI1	"kb_x1",	"kb_x1",	kb_x1,		line=3
DEFCONSTI1	"kb_x2",	"kb_x2",	kb_x2,		line=3
DEFCONSTI1	"kb_x3",	"kb_x3",	kb_x3,		line=3
DEFCONSTI1	"kb_x4",	"kb_x4",	kb_x4,		line=3
DEFCONSTI1	"kb_x5",	"kb_x5",	kb_x5,		line=3
DEFCONSTI1	"kb_x6",	"kb_x6",	kb_x6,		line=3
DEFCONSTI1	"kb_x7",	"kb_x7",	kb_x7,		line=3
DEFCONSTI1	"kb_x8",	"kb_x8",	kb_x8,		line=3
DEFCONSTI1	"kb_x9",	"kb_x9",	kb_x9,		line=3

DEFCONSTI1	"kb_F1",	"kb_F1",	kb_F1,		line=3
DEFCONSTI1	"kb_F2",	"kb_F2",	kb_F2,		line=3
DEFCONSTI1	"kb_F3",	"kb_F3",	kb_F3,		line=3
DEFCONSTI1	"kb_F4",	"kb_F4",	kb_F4,		line=3
DEFCONSTI1	"kb_F5",	"kb_F5",	kb_F5,		line=3
DEFCONSTI1	"kb_F6",	"kb_F6",	kb_F6,		line=3
DEFCONSTI1	"kb_F7",	"kb_F7",	kb_F7,		line=3
DEFCONSTI1	"kb_F8",	"kb_F8",	kb_F8,		line=3
DEFCONSTI1	"kb_F9",	"kb_F9",	kb_F9,		line=3
DEFCONSTI1	"kb_F10",	"kb_F10",	kb_F10,		line=3
DEFCONSTI1	"kb_F11",	"kb_F11",	kb_F11,		line=3
DEFCONSTI1	"kb_F12",	"kb_F12",	kb_F12,		line=3

DEFCONSTI1	"kb_Pause",	"kb_Pause",	kb_Pause,	line=3

DEFCONSTI1	"kb_Ctrl_A",	"kb_Ctrl_A",	kb_Ctrl_A,	line=3
DEFCONSTI1	"kb_Ctrl_B",	"kb_Ctrl_B",	kb_Ctrl_B,	line=3
DEFCONSTI1	"kb_Ctrl_C",	"kb_Ctrl_C",	kb_Ctrl_C,	line=3
DEFCONSTI1	"kb_Ctrl_D",	"kb_Ctrl_D",	kb_Ctrl_D,	line=3
DEFCONSTI1	"kb_Ctrl_E",	"kb_Ctrl_E",	kb_Ctrl_E,	line=3
DEFCONSTI1	"kb_Ctrl_F",	"kb_Ctrl_F",	kb_Ctrl_F,	line=3
DEFCONSTI1	"kb_Ctrl_G",	"kb_Ctrl_G",	kb_Ctrl_G,	line=3
DEFCONSTI1	"kb_Ctrl_H",	"kb_Ctrl_H",	kb_Ctrl_H,	line=3
DEFCONSTI1	"kb_Ctrl_I",	"kb_Ctrl_I",	kb_Ctrl_I,	line=3
DEFCONSTI1	"kb_Ctrl_J",	"kb_Ctrl_J",	kb_Ctrl_J,	line=3
DEFCONSTI1	"kb_Ctrl_K",	"kb_Ctrl_K",	kb_Ctrl_K,	line=3
DEFCONSTI1	"kb_Ctrl_L",	"kb_Ctrl_L",	kb_Ctrl_L,	line=3
DEFCONSTI1	"kb_Ctrl_M",	"kb_Ctrl_M",	kb_Ctrl_M,	line=3
DEFCONSTI1	"kb_Ctrl_N",	"kb_Ctrl_N",	kb_Ctrl_N,	line=3
DEFCONSTI1	"kb_Ctrl_O",	"kb_Ctrl_O",	kb_Ctrl_O,	line=3
DEFCONSTI1	"kb_Ctrl_P",	"kb_Ctrl_P",	kb_Ctrl_P,	line=3
DEFCONSTI1	"kb_Ctrl_Q",	"kb_Ctrl_Q",	kb_Ctrl_Q,	line=3
DEFCONSTI1	"kb_Ctrl_R",	"kb_Ctrl_R",	kb_Ctrl_R,	line=3
DEFCONSTI1	"kb_Ctrl_S",	"kb_Ctrl_S",	kb_Ctrl_S,	line=3
DEFCONSTI1	"kb_Ctrl_T",	"kb_Ctrl_T",	kb_Ctrl_T,	line=3
DEFCONSTI1	"kb_Ctrl_U",	"kb_Ctrl_U",	kb_Ctrl_U,	line=3
DEFCONSTI1	"kb_Ctrl_V",	"kb_Ctrl_V",	kb_Ctrl_V,	line=3
DEFCONSTI1	"kb_Ctrl_W",	"kb_Ctrl_W",	kb_Ctrl_W,	line=3
DEFCONSTI1	"kb_Ctrl_X",	"kb_Ctrl_X",	kb_Ctrl_X,	line=3
DEFCONSTI1	"kb_Ctrl_Y",	"kb_Ctrl_Y",	kb_Ctrl_Y,	line=3
DEFCONSTI1	"kb_Ctrl_Z",	"kb_Ctrl_Z",	kb_Ctrl_Z,	line=3

DEFCONSTI1	"kb_Alt_A",	"kb_Alt_A",	kb_Alt_A,	line=3
DEFCONSTI1	"kb_Alt_B",	"kb_Alt_B",	kb_Alt_B,	line=3
DEFCONSTI1	"kb_Alt_C",	"kb_Alt_C",	kb_Alt_C,	line=3
DEFCONSTI1	"kb_Alt_D",	"kb_Alt_D",	kb_Alt_D,	line=3
DEFCONSTI1	"kb_Alt_E",	"kb_Alt_E",	kb_Alt_E,	line=3
DEFCONSTI1	"kb_Alt_F",	"kb_Alt_F",	kb_Alt_F,	line=3
DEFCONSTI1	"kb_Alt_G",	"kb_Alt_G",	kb_Alt_G,	line=3
DEFCONSTI1	"kb_Alt_H",	"kb_Alt_H",	kb_Alt_H,	line=3
DEFCONSTI1	"kb_Alt_I",	"kb_Alt_I",	kb_Alt_I,	line=3
DEFCONSTI1	"kb_Alt_J",	"kb_Alt_J",	kb_Alt_J,	line=3
DEFCONSTI1	"kb_Alt_K",	"kb_Alt_K",	kb_Alt_K,	line=3
DEFCONSTI1	"kb_Alt_L",	"kb_Alt_L",	kb_Alt_L,	line=3
DEFCONSTI1	"kb_Alt_M",	"kb_Alt_M",	kb_Alt_M,	line=3
DEFCONSTI1	"kb_Alt_N",	"kb_Alt_N",	kb_Alt_N,	line=3
DEFCONSTI1	"kb_Alt_O",	"kb_Alt_O",	kb_Alt_O,	line=3
DEFCONSTI1	"kb_Alt_P",	"kb_Alt_P",	kb_Alt_P,	line=3
DEFCONSTI1	"kb_Alt_Q",	"kb_Alt_Q",	kb_Alt_Q,	line=3
DEFCONSTI1	"kb_Alt_R",	"kb_Alt_R",	kb_Alt_R,	line=3
DEFCONSTI1	"kb_Alt_S",	"kb_Alt_S",	kb_Alt_S,	line=3
DEFCONSTI1	"kb_Alt_T",	"kb_Alt_T",	kb_Alt_T,	line=3
DEFCONSTI1	"kb_Alt_U",	"kb_Alt_U",	kb_Alt_U,	line=3
DEFCONSTI1	"kb_Alt_V",	"kb_Alt_V",	kb_Alt_V,	line=3
DEFCONSTI1	"kb_Alt_W",	"kb_Alt_W",	kb_Alt_W,	line=3
DEFCONSTI1	"kb_Alt_X",	"kb_Alt_X",	kb_Alt_X,	line=3
DEFCONSTI1	"kb_Alt_Y",	"kb_Alt_Y",	kb_Alt_Y,	line=3
DEFCONSTI1	"kb_Alt_Z",	"kb_Alt_Z",	kb_Alt_Z,	line=3
