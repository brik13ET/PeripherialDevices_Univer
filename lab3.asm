.model small
LOCALS
.386
.stack 100h
org 100h

.data
	vid 	dw 0, 0
	t1		db 64, 0, 64 dup('$')
	offset_x dw 12
	offset_y dw 24
	ssize	equ 6
	symbol	db 8 dup(?)
	mysymbol db 00000000b
			db 00100100b
			db 01111110b
			db 01111110b
			db 01111110b
			db 00111100b
			db 00011000b
			db 00000000b

.code

fill_s proc near
	push bp
	mov bp, sp
	push ax
	push bx
	push cx
	push dx

	mov cx, [bp + 6] ; from x
	mov dx, [bp + 4] ; from y

	mov ah, ssize ; region w
	mov al, ssize ; region h

	@@row:
	@@point:

	push cx
	push dx
	call point
	add sp, 4

	dec ah
	inc cx
	cmp ah, 0
	jne @@point

	mov  bx, ssize
	sub cx, bx
	dec al
	inc dx
	mov ah, ssize
	cmp al, 0
	jne @@row


	pop dx
	pop cx
	pop bx
	pop ax
	pop bp
	ret
fill_s endp

point proc near
	push bp
	mov bp, sp
	push ax
	push bx
	push cx
	push dx


	mov cx, [bp + 6]
	mov dx, [bp + 4]
	mov ax, 0c0Ah
	mov bx, 0
	int 10h

	pop dx
	pop cx
	pop bx
	pop ax
	pop bp
	ret
point endp

dot proc near
	push bp
	mov bp, sp
	push ax
	push bx
	push cx
	push dx

	local siz: byte
	mov [siz], ssize

	mov dx, [bp + 4]
	mov cx, [bp + 6]
	dec cx
	dec dx

	mov ax, cx
	mul [siz]
	push ax
	mov ax, dx
	mul [siz]
	push ax
	call fill_s
	add sp, 4

	pop dx
	pop cx
	pop bx
	pop ax
	pop bp
	ret
dot endp

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
			add cx, [offset_x]
			add di, [offset_y]
			push cx
			push di
			call dot
			add sp, 4
			sub cx, [offset_x]
			sub di, [offset_y]
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

bios_draw proc near
	push bp
	mov bp, sp
	pusha
	
	mov si, 0FA6Eh
	mov ax, 0f000h
	mov es, ax
	mov ax, [bp+4]

	cmp al, '@'
	jne @@bios

	push offset mysymbol
	call draw
	add sp, 2
	jmp @@endp


	@@bios:
	shl ax, 3
	add si, ax

	xor bx, bx
	xor di, di

	mov cx, 8
	@@mem:
	dec cx

	mov bl, es:[si]
	mov symbol[di], bl

	inc di
	inc si
	inc cx
	loop @@mem

	push offset symbol
	call draw
	add sp, 2

	@@endp:

	popa
	pop bp
	ret
bios_draw endp

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

gets proc near
	push bp
	mov bp, sp
	push dx
	push ax

	mov ah, 0ah
	mov dx, [bp+4]
	int 21h

	pop ax
	pop dx
	pop bp
	ret
gets endp

start:
	mov ax, @data
	mov ds, ax

	push offset t1
	call gets
	add sp, 2

	call savevid
	call setvid

	mov cx, 2
	@@dec:

	mov bx, cx
	mov bl, t1[bx]

	cmp bl, "$"
	je @@dec_end

	push bx
	call bios_draw
	add sp, 2
	
	add [offset_x], ssize
	add [offset_x], 1
	; add [offset_x], ssize 
	cmp offset_x, 640 / ssize - ssize
	jge @@line
	cmp bl, 13
	jne @@noline

	@@line:

	mov offset_x, 0
	add offset_y, ssize+4

	@@noline:


	inc cx
	jmp @@dec
	@@dec_end:


	call getch

	call settext


exit:
	mov ax, 4c00h
	int 21h
end start