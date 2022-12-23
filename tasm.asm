.model small
LOCALS
.386
.stack 100h
org 100h

.data

	testw db "Hello, world!", 13, 10, '$'

.code
start:
	mov ax, @data
	mov ds, ax

	mov ax, 0900h
	mov dx, offset testw
	int 21h

	mov ax, 4c00h
	int 21h

end start