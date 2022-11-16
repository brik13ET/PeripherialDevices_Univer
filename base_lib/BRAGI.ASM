.model small
.286
.data
	readbuf db 16, 16
	charbuf	db 20 dup("$")
	integer dd 0
	X		dq 640 dup (0)
	Y		dq 640 dup (0)
	step	dq 0
.stack 100h
.code
start:
; init segment:offset of data
	mov ax,@data
	mov ds,ax

	call read
	call crnl
	call print
	call crnl

;terminate 0
	push 0
	call exit


stoi:
	push ax
	push dx

	

	pop dx
	pop ax
	ret

crnl:
	push ax
	push dx

	mov ah, 02h
	mov dl, 13
	int 21h
	
	mov ah, 02h
	mov dl, 10
	int 21h
	
	pop dx
	pop ax
	ret

print:
	push ax
	push dx

	mov ax, 0900h
	mov dx, offset charbuf
	int 21h

	pop dx
	pop ax
	ret

read:
	push ax
	push dx

	mov ah, 00Ah
	mov dx, offset readbuf
	int 21h

	pop dx
	pop ax
	ret

exit: 
	push bp
	mov bp, sp
	mov ah, 4Ch
	mov al, ss:[bp+4]
	int 21h

end start