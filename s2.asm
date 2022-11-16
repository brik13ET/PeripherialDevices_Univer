.model small
.386
.stack 100h
org 100h

.data
		A		dd 0.0
		B		dd 1.0
		stp		dd 0
		K		dd 0
		Min		dd 0
		Max		dd 0
		Curr	dd 0
		Y		dd 640 dup(0)
		N		dw 640
		H		dw 480
		dmul	dw 10000
		base	dw 10
		i		dw 0
		d		dw 0
		buf		db 16 dup("$")
		buf2	db 16 dup("$")
		point	db ".$"
		crlf	db 13,10,"$"
		t1		db "Write float, delimiter is point ",13,10,"$"
.code
print:
	push bp
	mov bp, sp
	push ax
	push dx

	mov ax, 0900h
	mov dx, ss:[bp + 4]
	int 21h

	pop dx
	pop ax
	pop bp
ret

putch:
	push bp
	mov bp, sp
	push ax
	push dx

	mov ax, 0200h
	mov bl, [bp + 6]
	int 21h

	pop dx
	pop ax
	pop bp
ret

exit:
	mov ax, 4C00h
	int 21h
ret

itos:
	push bp
	mov bp, sp
	push ax
	push bx
	push dx

	mov bx, ss:[bp + 4] ; buf
	mov ax, ss:[bp + 6] ; int
	itos_while:
	cmp ax, 0
	je itos_while_end
	xor dx, dx
	div base
	add ax, "0"
	mov [bx], ax
	inc bx
	jmp itos_while
	itos_while_end:
	mov [bx], "$"

	pop dx
	pop bx
	pop ax
	pop bp
ret

concat:
	push bp
	mov bp, sp
	push ax
	push bx
	push si
	push di

	mov si, ss:[bp + 4] ; src
	mov di, ss:[bp + 6] ; tar
	concat_while1:
	cmp [si], "$"
	je concat_while1_end
	inc si
	jmp concat_while1
	concat_while1_end:
	concat_while2:
	cmp [di], "$"
	je concat_while2_end
	mov bl, [di]
	mov [si], bl
	inc di
	inc si
	jmp concat_while2
	concat_while2_end:
	mov bl, [di]
	mov [si], bl

	pop di
	pop si
	pop bx
	pop ax
	pop bp
ret

ftos:
	push bp
	mov bp, sp
	push bx
	push cx
	push dx

	mov bx, ss:[bp+4]
	fld [ds:bx]
	fist d
	fild d
	fchs
	fadd ST(0), ST(1)
	fild dmul
	fmulp ST(1), ST(0)
	fistp i

	push [i]
	push offset buf
	call itos
	add sp, 4 


	push [d]
	push offset buf2
	call itos
	add sp, 4 

	push offset buf
	push offset buf2
	call concat
	add sp, 4

	pop dx
	pop cx
	pop bx
	pop bp
ret

start:
	mov ax, @data
	mov ds, ax
	finit

	push offset B
	call ftos
	add sp, 2
	
	push offset buf
	call print
	add sp, 2



	call exit
end start