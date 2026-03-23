#include "ScanToASCII.h"

const uint16_t ScanToASCII[2][128] PROGMEM =								// [x][..]: SHIFT/ALTGR keystate and PS/2 scancode, [..][y]: ASCII code)
	{
	{		// normal codes
	//		0		1		2		3		4		5		6		7		8		9		A		B		C		D		E		F
	/*0*/		0,		kb_F9,		0,		kb_F5,		kb_F3,		kb_F1,		kb_F2,		kb_F12,		0,		kb_F10,		kb_F8,		kb_F6,		kb_F4,		kb_Tab,		'`',		0,
	/*1*/		0,		kb_AltL,	kb_ShiftL,	0,		kb_CtrlL,	'q',		'1',		0,		0,		0,		'z',		's',		'a',		'w',		'2',		0,
	/*2*/		0,		'c',		'x',		'd',		'e',		'4',		'3',		kb_WinR,	0,		' ',		'v',		'f',		't',		'r',		'5',		0,
	/*3*/		0,		'n',		'b',		'h',		'g',		'y',		'6',		0,		0,		0,		'm',		'j',		'u',		'7',		'8',		0,
	/*4*/		0,		',',		'k',		'i',		'o',		'0',		'9',		0,		0,		'.',		'/',		'l',		';',		'p',		'-',		0,
	/*5*/		0,		0,		'\'',		0,		'[',		'=',		0,		0,		kb_CapsLck,	kb_ShiftR,	kb_Enter,	']',		0,		'\\',		0,		0,
	/*6*/		0,		0,		0,		0,		0,		0,		kb_Back,	0,		0,		kb_x1,		0,		kb_x4,		kb_x7,		0,		0,		0,
	/*7*/		kb_x0,		kb_xDot,	kb_x2,		kb_x5,		kb_x6,		kb_x8,		kb_Esc,		kb_NumLck,	kb_F11,		kb_xPlus,	kb_x3,		kb_xMinus,	kb_xStar,	kb_x9,		kb_ScrLck,	0
	// 83=xF7
	},
	{		// E0 codes
	//		0		1		2		3		4		5		6		7		8		9		A		B		C		D		E		F
	/*0*/		0,		0,		0,		0,		0,		0,		0,		0,		0,		0,		0,		0,		0,		0,		0,		0,
	/*1*/		0,		kb_AltR,	kb_PrtScr1,	0,		kb_CtrlR,	0,		0,		0,		0,		0,		0,		0,		0,		0,		0,		kb_WinL,
	/*2*/		0,		0,		0,		0,		0,		0,		0,		kb_WinR,	0,		0,		0,		0,		0,		0,		0,		kb_Menu,
	/*3*/		0,		0,		0,		0,		0,		0,		0,		0,		0,		0,		0,		0,		0,		0,		0,		0,
	/*4*/		0,		0,		0,		0,		0,		0,		0,		0,		0,		0,		kb_xSlash,	0,		0,		0,		0,		0,
	/*5*/		0,		0,		0,		0,		0,		0,		0,		0,		0,		0,		kb_xEnter,	0,		0,		0,		0,		0,
	/*6*/		0,		0,		0,		0,		0,		0,		0,		0,		0,		kb_End,		0,		kb_Left,	kb_Home,	0,		0,		0,
	/*7*/		kb_Ins,		kb_Del,		kb_Down,	0,		kb_Right,	kb_Up,		0,		0,		0,		0,		kb_PgDn,	0,		kb_PrtScr2,	kb_PgUp,	0,		0
	},
	};

// [83]=xF7
// [E1][14][77] = Pause
