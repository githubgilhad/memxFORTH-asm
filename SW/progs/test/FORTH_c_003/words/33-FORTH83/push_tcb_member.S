; add TCB base and member offset, push on stack

gfunc push_tcb_member
	PushST TOS
	Set3 Zx,DT
	call B3at
;	Set3 DT,Zx
	Set2 TOS2,Parsx2
	add TOS_lo,TCB_lo
	adc TOS_hi,TCB_hi
	ldi TOS_hlo, 0x80
	rjmp NEXT

