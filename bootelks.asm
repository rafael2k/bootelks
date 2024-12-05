; BootELKS V 0.1 - 28.08.1997
; Copyright (C) 1997 Steffen Gabel
; gabel@physik.uni-kl.de

		NAME	BootELKS

StartSeg	SEGMENT	PARA	'CODE'
		ASSUME cs:StartSeg, ds:StartSeg, es:StartSeg

		org 	0100h	;COM file

BootELKSVer	equ 	"0.1"
BootFlag        equ 	0AA55h
PosBootFlag	equ 	2
StackSize	equ 	00800h
InitSeg		equ 	00100h	;Position of bootsec.S Code
SetupSeg	equ 	00120h	;Position of setup.S Code
SysSeg		equ 	01000h	;Position of the kernel image
;***************************************
; Start of the relcated code of BootELKS
;***************************************

Start	        PROC FAR
		jmp 	StartUp
Start		ENDP

		ASSUME cs:StartSeg, ds:NOTHING, es:NOTHING
Copyall		PROC FAR
C_Start:	cli				; silence

		cld
		mov 	ax,cs:(IntStart-C_Start); Move int table
		mov 	ds,ax
		mov 	si,0f0h			; Offset of source int table
		xor 	ax,ax			; Target
		mov 	es,ax
		xor 	di,di
		mov 	cx,0500h	   	; 500h bytes
		rep 	movsb

; move bootsector
		mov 	ax,cs:(ELKStart-C_Start); Source
		mov 	ds,ax
		xor 	si,si
		mov 	ax,InitSeg		; Target
		mov 	es,ax
		xor 	di,di
		mov 	cx,0200h		; length of bootsector
		rep 	movsb			; copy

; move setup
		mov 	al,ds:497     		; numbers of setup sectors
		xor 	ah,ah
		mov 	cx,0200h
		mul 	cx
		mov 	cx,ax			; number of bytes to move
		mov 	bx,ax
		mov 	ax,ds			; Source
		add 	ax,020h
		mov 	ds,ax
		xor 	si,si
		mov 	ax,SetupSeg		; Target
		mov 	es,ax
		xor 	di,di
		rep 	movsb			; copy
; move kernel
		mov	ax,SysSeg		; fist block of target
		mov 	es,ax
		xor 	di,di
		mov 	cl,4
		shr 	bx,cl        		; calc kernel start
		mov 	ax,ds
		mov 	dx,bx
C_KLoop:	add 	ax,dx			; source
		mov 	ds,ax
		xor 	si,si
		xor 	di,di
		mov 	cx,0200h		; copy per block
		rep 	movsb			; copy

		mov 	dx,ds
		mov 	ax,cs:(ELKSEnd-C_Start)
		cmp 	dx,ax
		jae 	short C_KEnd
		mov 	bx,020h			; setup next targetblock
		mov 	ax,es
		add 	ax,bx
		mov 	es,ax
		mov 	ax,020h
		jmp 	short C_KLoop

C_KEnd:         cli

		mov 	ax,InitSeg	    	; setup stack for startup
		mov 	ss,ax
		mov 	di,04000h-12
		mov 	sp,di
		mov 	ax,SetupSeg
		mov 	es,ax           	; setup es, ds
		mov 	ds,ax
		sti

		db 	0eah		    	; hardcode jump to SetupSeg:0
		dw 	0
		dw 	SetupSeg

IntStart	dw 	?
ELKStart	dw 	?
ELKSEnd		dw 	?
Copyall		ENDP
C_Length	equ	$- Copyall

;*************************************
; Start of the static code of BootELKS
;*************************************

		ASSUME cs:StartSeg, ds:StartSeg, es:StartSeg

ClearScr	PROC NEAR
		mov 	ax,0f00h	;read Videomode
		int 	10h
		and 	ax,007fh	;set it to clear screen
		int 	10h
		mov 	ax,0500h 	;set page 0
		int 	10h
		ret
ClearScr	ENDP

WriteMsg	PROC NEAR 		;(si=offset of message)
Wr_loop:        cld
		lodsb			; Zeichen holen
		or	al,al		; Letztes Zeichen (0h)
		jz	Wr_exit
		xor	bh,bh
		mov	ah,0eh		; BIOS-Subroutine 0eh
		int	10h
		jmp	short Wr_loop 	; Naechstes Zeichen
Wr_exit:	ret
WriteMsg	ENDP

		ASSUME cs:StartSeg, ds:StartSeg, es:StartSeg
ReadELKS	PROC NEAR 	    		;(ax=Segment to load to) (ax=next free segment)
		push 	ax
R_Retry:	mov 	dx,offset ImageName 	; Specify file name
		mov 	ax,03d00h		; open file read-only
		int 	21h
		jnc 	R_IsOpen

		mov 	si, offset noImage	; print error message
		call 	WriteMsg
		jmp 	short R_Retry

R_IsOpen:	mov 	ImageHandle,ax		; save file handle of image file

		mov 	si, offset lImage	; print load image message
		call 	WriteMsg

		mov 	dx,ds			; setup DS
		pop 	ds
		push 	dx
		push 	ds

R_read:         mov 	ah,03fh			; read via handle
		mov 	bx,es:ImageHandle
		mov 	cx,02000h		; read 16 blocks
		xor 	dx,dx			; offset 0
		int 	21h

		mov 	dx,ds
		add 	dx,0200h
		mov 	ds,dx			; calc next segment

		cmp 	ax,02000h		;all read?
		je  	short R_read

		pop 	ds
		mov 	cx,word ptr ds:[0200h-PosBootFlag]
		pop 	ds
		push 	dx			; save next free Segment
		cmp 	cx,BootFlag
		jne 	R_end

		mov 	si,offset SXSMsg
		call 	WriteMsg          	; write success message

R_end:          mov 	ah,03eh          	; close File
		mov 	bx,es:ImageHandle
		int 	21h

		pop 	ax
		ret
ReadELKS	ENDP

		ASSUME cs:StartSeg, ds:StartSeg, es:StartSeg
ReadInts	PROC NEAR 			;(ax=Segment to load to) (ax=next free segment)
		push 	ax
RI_Retry:	mov 	dx,offset IntName 	; Specify file name
		mov 	ax,03d00h		; open file read-only
		int 	21h
		jnc 	RI_IsOpen

		mov 	si, offset noInt	; print error message
		call 	WriteMsg
		jmp 	short RI_Retry

RI_IsOpen:	mov 	IntHandle,ax		; save file handle of int file

		mov 	si, offset lInt		; print load int message
		call 	WriteMsg

		mov 	dx,ds			; setup DS
		pop 	ds
		push 	dx
		push 	ds

		mov 	ah,03fh			; read via handle
		mov 	bx,es:IntHandle
		mov 	cx,0600h		; read 3 blocks
		xor 	dx,dx			; offset 0
		int 	21h

		mov 	dx,ds
		add 	dx,060h			; 3 block read

		pop 	ds
		cmp 	ax,0600h		;all read?
		jne 	short RI_end		;Error? exit
		mov 	cx,word ptr ds:[0600h-PosBootFlag]
		pop 	ds
		push 	dx			; save next free Segment
		cmp 	cx,BootFlag
		jne 	short RI_end

		mov 	si,offset SXSMsg
		call 	WriteMsg           	; Write SuccessMSG

RI_end:		mov 	ah,03eh          	; close File
		mov 	bx,es:IntHandle
		int 	21h

		pop 	ax
		ret
ReadInts	ENDP

StartUp		PROC NEAR
		call ClearScr

		mov 	bx,offset EndOfCode
		add 	bx,StackSize		; get Start of Stack

                cli
		push 	cs
		pop 	ss
		mov 	sp,bx
		sti				; set new stack

		dec 	bx
		mov 	cl,4
		shr 	bx,cl
		inc 	bx
		mov 	ax,ss
		add 	ax,bx			; Calc segment after stack
		mov 	si,SysSeg
		cmp 	ax,si
		jae 	St_SaveSeg		; if segment < 1000h

		push 	si
		mov 	si, offset BelowMsg	; print error message
		call 	WriteMsg
		pop 	ax
		;mov 	ax,si               	; segment = 1000h
St_SaveSeg:	mov 	LoadSeg,ax          	; save segment

		mov 	IntStart,ax 		; save start segment of ints.bin
		call 	ReadInts
		mov 	ELKStart,ax 		; save start segment of kernel image
		call 	ReadELKS
		mov 	ELKSEnd,ax 		; save end segment of kernel image
		mov 	ELKSEndPtr,ax		; save end segment for jump to Copyall

		push 	cs			; copy Copyall to end of kernel image
		pop  	ds
		mov  	cx,C_Length
		mov  	ax,offset Copyall
		mov  	si,ax

		mov  	ax,ELKSEnd
		mov  	es,ax
		xor  	di,di
		rep  	movsb

		db   	0eah       		; hardcoded jump to end Copyall
		dw   	0
ELKSEndPtr      dw   	?

		mov	ah,04ch
		int 	21h
StartUp		ENDP

LoadSeg		dw 	?			; segment address for kernel image

ImageName	db 	"Image",0		; name & path of the kernel image
ImageHandle	dw 	?			; file handle of kernel image

IntName		db 	"Ints.bin",0		; name & path of the interrupt table
IntHandle	dw 	?			; filehandle of interrupt table file

noImage		db 	"Can't find kernel image!",13,10,0
lImage		db 	"Loading kernel image...",13,10,0

noInt		db 	"Can't find interrupts image!",13,10,0
lInt		db 	"Loading interrupts image...",13,10,0

SXSMsg		db 	"Success.",13,10,0
BelowMsg	db 	"BELOW!",13,10,0

EndOfCode	LABEL BYTE
StartSeg	ENDS
		END StartSeg:Start