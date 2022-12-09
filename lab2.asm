.model small
LOCALS
.386
.stack 100h
org 100h

F_RO equ 00h
F_WO equ 01h
F_RW equ 02h

F_BEG equ 00h
F_CUR equ 01h
F_END equ 02h

.data
	fd 		dw 0
	fsiz	dw 0
	ferr	db 0
	fmt		db 2eh
	offset_ dw 0
	buf		db 160 dup(0)
	line	db 80
	left	db 0
	line_w	db 0
	fname	db "data.txt", 0 ; asciiz
	err_str	db "Error occured"
	err_cod	db "0000h"
	err_end	db 13, 10, "$"
	xtos_alph db "0123456789ABCDEF"
.code
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

wxtos proc near
	push bp
	mov bp, sp

	push ax
	push bx
	push dx
	push si

	mov ax, [bp + 4]

	mov bx, ax
	and bx,	0fh
	shr bx, 0
	mov dl, [xtos_alph + bx]
	mov [err_cod + 3], bl

	mov bx, ax
	shr bx, 8
	and bx,	0fh
	mov dl, [xtos_alph + bx]
	mov [err_cod + 2], bl

	mov bx, ax
	shr bx, 16
	and bx,	0fh
	mov dl, [xtos_alph + bx]
	mov [err_cod + 1], bl

	mov bx, ax
	shr bx, 24
	and bx,	0fh
	mov dl, [xtos_alph + bx]
	mov [err_cod + 0], bl


	pop si
	pop dx
	pop bx
	pop ax

	pop bp
	ret
wxtos endp

error:
	push ax
	call wxtos
	push offset err_str
	call puts
	jmp exit

setvid proc near
	push ax
	push bx
	
	mov ax,0003h
	
	; видеорежим 3 (очистка экрана)
	int 10h

	pop bx
	pop ax
	ret
setvid endp

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
	mov ax, 0b800h
	mov es, ax

	; fopen
	mov ah, 3dh
	mov al, F_RO
	mov dx, offset fname
	int 21h
	jc error

	mov [fd], ax

	; fseek
	mov ah, 42h
	mov al, F_END
	mov bx, [fd]
	xor cx, cx
	xor dx, dx
	int 21h

	cmp ax, 0
	je error
	mov word ptr [fsiz], ax

	; fseek
	mov ah, 42h
	mov al, F_BEG
	mov bx, [fd]
	xor cx, cx
	xor dx, dx
	int 21h

	mov bx, ax
	cmp bx, 00h
	jne error

	; fread
	mov ah, 3fh
	mov bx, [fd]
	mov cx, [fsiz + 2]
	mov dx, offset buf
	int 21h

	jc error

	; fclose
	mov ah, 3eh
	mov bx, [fd]
	int 21h

	mov cx, [fsiz]
	xor si, si
	xor bx, bx 
	call setvid

	scr_x equ bh
	scr_y equ bl

	mov scr_y, 12
	mov scr_x, 75

	mov si, offset buf

	linew_calc:
	cmp byte ptr [si], ","
	je linew_calc_end
	cmp  byte ptr [si], 0
	je linew_calc_end
	inc si
	jmp linew_calc
	linew_calc_end:

	inc si
	sub si, offset buf
	mov ax, si
	xor si, si
	sub scr_x, al
	shr scr_x, 1

	mov [left], scr_x
	dec [left]

	print:

	cmp byte ptr si, [fsiz]
	jge @@exitfor

	push cx
	movzx ax, scr_y
	mul line
	mov di, ax

	xor cx, cx
	add cl, scr_x
	add di, cx
	shl di, 1
	add di, dx

	mov ah, [fmt]
	mov al, [buf + si]

	mov es:[di+1], ah
	mov es:[di+0], al

	cmp al, ","
	jne @@endfor

	mov scr_x, [left]
	inc scr_y

	@@skip_w:
	cmp [buf + si + 1], " "
	jne @@endfor
	inc si
	jmp @@skip_w

	@@endfor:
	inc si
	inc scr_x
	pop cx
	loop print
	@@exitfor:
	call getch

exit:
	mov ax, 4c00h
	int 21h
end start