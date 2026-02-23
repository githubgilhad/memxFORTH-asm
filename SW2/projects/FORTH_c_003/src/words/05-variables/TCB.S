; .. vim: ft=asm showbreak=--»\  noexpandtab fileencoding=utf-8 nomodified   wrap textwidth=0 foldmethod=marker foldmarker={{{,}}} foldcolumn=4 ruler showcmd lcs=tab\:|- list tabstop=8 noexpandtab nosmarttab softtabstop=0 shiftwidth=0 linebreak  

DEFTCBVAR "TCB.STATE", TCB_STATE
DEFTCBVAR "TCB.TIB", TCB_TIB
DEFTCBVAR "TCB.TIB.len", TCB_TIB_len
DEFTCBVAR "TCB.TIB.cur", TCB_TIB_cur
DEFTCBVAR "TCB.AIB", TCB_AIB
DEFTCBVAR "TCB.AIB.max", TCB_AIB_max
DEFTCBVAR "TCB.AIB.len", TCB_AIB_len
DEFTCBVAR "TCB.AIB.cur", TCB_AIB_cur
DEFTCBVAR "TCB.WL.CURRENT", TCB_WL_CURRENT
DEFTCBVAR "TCB.WL.ORDER", TCB_WL_ORDER
DEFTCBVAR "TCB.WL.ORDER.count", TCB_WL_ORDER_len

DEFCONSTI2 "TCB.TIB.max", TCB_TIB_max, TIB_SIZE
