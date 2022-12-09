.model small
LOCALS
.386
.stack 100h
org 100h

.data
	vid 	dw 0, 0
	t1		db "Hello, world!",13, 10, "$"
	symbol	db 00000000b
			db 00100100b
			db 01111110b
			db 01111110b
			db 01111110b
			db 00111100b
			db 00011000b
			db 00000000b
.code
point proc near
	push bp
	mov bp, sp
	push ax
	push bx
	push cx
	push dx

	mov ax, 0c0Ah
	mov bx, 0000h
	mov cx, [bp + 6]
	mov dx, [bp + 4]
	int 10h

	pop dx
	pop cx
	pop bx
	pop ax
	pop bp
	ret
point endp

setvid proc near
	push ax
	push bx
	
	mov ax, 0012h
	int 10h

	mov ax, 0500h
	int 10h

	pop bx
	pop ax
	ret
setvid endp

draw proc near
	push bp
	mov bp, sp
	push bx
	push cx
	push di
	push si

	xor di, di
	xor cx, cx
	mov si, [bp + 4]
	@@line:
		mov bx, [si] ; bl - symbol line
		inc si
		inc di
		cmp di, 8
		je @@end
		mov cx, 0
		@@point:
			inc cx
			shl bl, 1
			jc @@draw
			jnc @@end_draw
		@@draw:
			push cx
			push di
			call point
			add sp, 4
		@@end_draw:
		cmp cx, 8
		je @@line
		jmp @@point
	@@end:
	pop si
	pop di
	pop cx
	pop bx
	pop bp
	ret
draw endp

savevid proc near
	push ax
	push bx

	mov ah, 0fh
	int 10h

	mov [vid], ax
	xchg bh, bl
	mov [vid + 2], bx

	pop bx
	pop ax
	ret
savevid endp

settext proc near
	push bp
	mov bp, sp
	push ax
	

	mov ax, [vid]
	mov ah, 00h
	int 10h

	mov ax, [vid + 2]
	xchg ah, al
	mov ah, 05h
	int 10h

	pop ax
	pop bp
	ret
settext endp


puts proc near
	push bp
	mov bp, sp
	push ax
	push dx

	mov ax, 0900h
	mov dx, [bp + 4]
	int 21h

	pop dx
	pop ax
	pop bp
	ret
puts endp

getch proc near
	push bp
	mov bp, sp
	push ax
	
	mov ax, 0800h
	int 21h

	pop ax
	pop bp
	ret
getch endp

start:
	mov ax, @data
	mov ds, ax

	call savevid
	call setvid

	push offset symbol
	call draw
	add sp, 2

	call getch
	call settext

	mov ax, 0f000h
	mov es, ax

	; push offset t1
	; call my_puts
	; add sp, 2

exit:
	mov ax, 4c00h
	int 21h
end start