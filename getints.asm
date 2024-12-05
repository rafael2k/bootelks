	;; Bootblock zum ermitteln der Interrupverktoren und Biosparametertabelle beim Booten
	;; Copyright (C) Steffen Gabel 1997
	;; gabel@physik.uni-kl.de
	;; Version 0.1 - 24.08.1997

bootseg		equ	07c0h	; "Start"-Segment
intnumber	equ	020h	; Anzahl der zu rettenden Ints.
datenumber	equ	008h	; 8 Bytes Biosdatum
dateseg		equ	0ffffh	; "Biosdatum"-Segment
dateoffset	equ	05h    ; "Biosdatum"-Offset
	;;
memstart	segment at 0	; Schablone fuer die Interrupttablelle

memstart	ends
	
start		segment byte public
		assume	cs:start, ds:start, es:start
		org	0	; Offset 0
	
entry:		jmp	short cont	; Dummy Sprung
		nop
		db	"BOOTELKS",0	; Sektorkennung fuer Bootelksloader

cont:		cli		; Interrupts blocken

		xor	ax,ax	; ax loeschen
		mov	ds,ax	; Segmentregister
		mov	ax,bootseg
		mov	es,ax	; initialisieren

                mov     ax,0aa55h
		mov     es:(0600h-2),ax

		cld
		mov	cx,0500h ; Laenge
		xor	si,si	; Offset der Quelle
		mov	di,offset inttarget	; Ziel
		rep	movsb	; kopieren

		mov 	ax,dateseg	; DS mit dateseg laden
		mov	ds,ax
		mov	si,dateoffset	; Quelle
		mov	di,offset datetarget	;Ziel
		mov	cx,datenumber	; 8 Byte L„nge
		rep     movsb		;kopieren

		mov	ax,bootseg	; ES und DS mit bootseg wieder laden
		mov	ds,ax
		mov     es,ax
		mov	si,offset datetarget	; Quelle
		mov	di,offset datestring	; Ziel
		mov	cx,datenumber		; 8 Bytes
		rep	movsb			; kopieren

		mov     si,offset beep
		call	showmsg ;

		mov	si,offset datemsg
		call	showmsg

		mov	si,offset mymsg	; Meldung ausgeben
		call	showmsg

		mov 	ax,0303h	; Schreibe auf Floppy, Sektor 1 & 2 & 3
		xor	dx,dx 		; Disk A:, Seite 0
		mov	cx,1		; Spur 0, Sektor 1 & 2 & 3
		mov	bx,0		; ab ES:00h
		int	13h
	
waitkey:	mov	ah,1	; Tastaturpuffer pollen
		int	16h
		jz	waitkey ; nein, dann weiter pollen
		mov	ah,0	; Zeichen auslesen
		int	16h
	
reboot:		int	19h	; REBOOT

	;; Nachricht mittels BIOS-Int 10h ausgeben
showmsg		proc   near
showloop:	lodsb		; Zeichen holen
		or	al,al	; Letztes Zeichen (0h)
		jz	showexit
		xor	bh,bh
		mov	ah,0eh	; BIOS-Subroutine 0eh
		int	10h
		jmp	short showloop ; Naechstes Zeichen
showexit:	ret
showmsg		endp
	
	;; Meldungen
beep		db	7,0
mymsg		db	"Interrupts saved to disk. Hit any key to reboot system.",13,10,0
datemsg		db	"BIOS-Date: "
datestring	db	"xxxxxxxx",13,10,0
		org	0f0h-datenumber		; inittarget ab 0F0h-timenumber
datetarget	db	datenumber dup (?)	; Position des Biosdatums
inttarget	dw	2*intnumber dup(?)	; Position der Interrupttabelle

		org	0200h-2	; Groesse auf 512 Byte setzen
		db	055h,0aah ;  Bootblocksignatur
start		ends
		end	entry