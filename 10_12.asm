.model small
.286
.stack 100h
org 100h

.data
somedat	dw 42 dup(?)
head	dw 4,1, 16,5, 12,0, 0,4, 8,2

.code
start:
	mov ax, @data
	mov ds, ax

	xor bx, bx
	xor ax, ax
	xor cx, cx
	sum:

	add ax, head[bx+2]
	mov bx, head[bx]
	inc cx

	cmp bx, 0
	jne sum
	xor dx, dx
	div cx

	mov dx, ax
	add cx, "0"
	add dx , "0"

	mov ah, 02
	int 21h
	mov dl, " "
	int 21h
	mov dl, cl
	int 21h
	mov dl, 13
	int 21h
	mov dl, 10
	int 21h

	mov ax, 4c00h
	int 21h
end start