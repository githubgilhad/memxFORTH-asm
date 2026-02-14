; .. vim: ft=asm showbreak=--»\  noexpandtab fileencoding=utf-8 nomodified   wrap textwidth=0 foldmethod=marker foldmarker={{{,}}} foldcolumn=4 ruler showcmd lcs=tab\:|- list tabstop=8 noexpandtab nosmarttab softtabstop=0 shiftwidth=0 linebreak  

.global C_B3at
C_B3at:
        
	mov r30, r22
	mov r31, r23
	mov r25, r24
	call B3at 
	clr r25
	ret
        
.global C_B2at
C_B2at:
	mov r30, r22
	mov r31, r23
	mov r25, r24
	call B2at
	movw r24, r22
	ret

.global C_B1at
C_B1at:
	mov r30, r22
	mov r31, r23
	mov r25, r24
	call B1at
	mov r24, r22
	ret

.global RAM
RAM:
        
	ldi r24, 0x80
	clr r25
	ret
        
