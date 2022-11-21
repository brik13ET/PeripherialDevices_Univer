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
		icwr	dw 00F0h
		N		dw 640
		H		dw 480
		dmul	dw 1000
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

utos:
	push bp
	mov bp, sp
	push ax
	push bx
	push dx
	push si

	mov bx, ss:[bp + 4] ; buf
	mov ax, ss:[bp + 6] ; int
	mov si, bx
	cmp ax, 0
	je utos_nil
	utos_while:
	cmp ax, 0
	je utos_while_end
	xor dx, dx
	div base
	add dx, "0"
	mov [bx], dl
	inc bx
	jmp utos_while
	utos_while_end:
	jmp utos_end
	utos_nil:
	mov byte ptr [bx],  "0"
	utos_end:
	inc bx
	mov byte ptr [bx],  "$"

	push si
	call s_reverse
	add sp, 2

	pop si
	pop dx
	pop bx
	pop ax
	pop bp
ret

s_reverse:
	push bp
	mov bp, sp
	push bx
	push si
	push di

	mov si, ss:[bp + 4]
	mov di, si
	s_reverse_while:
	cmp byte ptr [si], "$"
	je s_reverse_while_end
	inc si
	jmp s_reverse_while
	s_reverse_while_end:
	dec si

	s_reverse_while1:
	cmp si, di
	jle s_reverse_while1_end

	mov bh, [si]
	mov bl, [di]
	xchg bl, bh
	mov [si], bh
	mov [di], bl

	inc di
	dec si
	jmp s_reverse_while1
	s_reverse_while1_end:

	pop di
	pop si
	pop bx
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
	mov bh, "$"

	concat_while1:
	cmp [di], bh
	je concat_while1_end
	inc di
	jmp concat_while1
	concat_while1_end:

	concat_while2:
	cmp [si], bh
	je concat_while2_end
	mov bl, [si]
	mov [di], bl
	inc di
	inc si
	jmp concat_while2
	concat_while2_end:
	; mov bl, [di]
	; mov [si], bl
	mov [si], bh

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
	fld DWORD PTR [bx]
	fist i
	fild i
	fchs
	fadd ST(0), ST(1)

	push [i]
	push offset buf
	call utos
	add sp, 4 

	push offset buf
	push offset point
	call concat
	add sp, 4	

	mov cx, 4
	ftos_right:

	fild base
	fmulp
	fistp d

	push [d]
	push offset buf2
	call utos
	add sp, 4

	push offset buf
	push offset buf2
	call concat
	add sp, 4

	loop ftos_right

	ffree st(0)
	fincstp

	pop dx
	pop cx
	pop bx
	pop bp
ret

clear_var:
	push cx
	push bx
	push di

	mov cx, 31
	mov di, offset buf
	clear_var_while:
	mov bx, cx
	mov byte ptr [di + bx], "$"
	loop clear_var_while

	pop di
	pop bx
	pop cx
ret

start:
	mov ax, @data
	mov ds, ax
	finit
	fstcw [icwr]
	mov ax, 0000111100000000b
	or [icwr], ax
	fldcw [icwr]

	fld B
	fld A
	fsubp ST(1), ST(0)
	fild N
	fdivp
	fstp stp

	fld A
	fstp Curr

	mov cx, 640
	
	iter:

	push offset Curr
	call ftos
	add sp, 2
	
	push offset buf
	call print
	add sp, 2

	push offset crlf
	call print
	add sp, 2

	fld Curr
	fld stp
	faddp
	fstp Curr

	call clear_var

	loop iter

	call exit
end start