.model small
LOCALS
.386
.stack 100h
org 100h

.data
	float1		dq 420.01337
	float2		dq -420.01337

	msg_max_len db 15
	msg_len 	db 15
	msg 		db 15 dup(?)
	crlf		db 13,10,'$'
	dig_cnt 	db 0
	base		dw 10

.code

; in: buf, buf_len, st(0)
; out: buf
ftos proc near
	push bp
	mov bp, sp
	push 0
	push ax
	push bx
	push cx
	push dx
	push di
	push si

	mov bx, [bp + 6]
	xor cx, cx
	xor si, si
	mov dh, 5

	mov ax, base
	dec ax
	mov [bp], ax
	fild word ptr [bp]
	fxch

	@@abs:
	fldz
	fxch st(1)
	fcom st(1)
	fstsw ax
	sahf
	ja @@abs_end

	mov byte ptr [bx], '-'
	inc bx
	fchs
	mov dl, 1
	
	@@abs_end:
	@@norm:
	
	ficom base
	fstsw ax
	sahf
	jb @@norm_end

	fidiv base
	inc cx

	jmp @@norm
	@@norm_end:
	inc cx
	@@digit:
	
	fist word ptr [bp]
	fisub word ptr [bp]
	fimul base
	mov ax, [bp]

	cmp cx, 0
	jl @@point_end
	je @@point_equ
	dec cx
	jmp @@point_end
	
	@@point_equ:
	mov byte ptr [bx], '.'
	dec cx
	inc bx
	@@point_end:

	cmp cx, 0ffffh
	jne @@end_cmp

	cmp al, 0
	je @@al0
	cmp al, 9
	je @@al9
	jmp @@al_else
	@@al9:
	cmp dh, 9
	jne @@nine_ch

	inc si
	jmp @@end_cmp
	@@nine_ch:

	mov di, bx
	mov si, 1
	mov dh, 9
	jmp @@end_cmp
	@@al0:

	cmp dh, 0
	jne @@zero_ch

	inc si
	jmp @@end_cmp
	@@zero_ch:

	mov di, bx
	mov si, 1
	mov dh, 0
	jmp @@end_cmp

	@@al_else:
	mov si, 0
	mov dh, 5 ; not 0 and not 9

	@@end_cmp:

	cmp si, 3
	ja @@end_proc


	; TODO: exit on si >= 3 (@@end_proc)

	add al, '0'
	mov [bx], al
	inc bx

	jmp @@digit

	@@end_proc:

	mov byte ptr [di], '$'
	cmp dh, 0
	je @@end_inc
	cmp dl, 1
	dec di
	inc byte ptr [di]
	@@end_inc:

	pop si
	pop di
	pop dx
	pop cx
	pop bx
	pop ax
	add sp, 2
	pop bp
	ret
ftos endp

setRoundDown proc near
	push bp
	mov bp, sp
	push 0

	

	fstcw [bp]
	or word ptr [bp], 0C00h
	; mov [bp], ax
	fldcw word ptr [bp]


	add sp, 2
	pop bp
	ret
setRoundDown endp

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

start:
	mov ax, @data
	mov ds, ax
	finit

	call setRoundDown

	push offset msg
	movzx dx, msg_len
	push dx
	fld float1
	call ftos
	add sp, 2
	ffree

	push offset msg
	call puts
	add sp, 2
	push offset crlf
	call puts
	add sp, 2

	push offset msg
	movzx dx, msg_len
	push dx
	fld float2
	call ftos
	add sp, 2
	ffree

	push offset msg
	call puts
	add sp, 2
	push offset crlf
	call puts
	add sp, 2

	mov ax, 4c00h
	int 21h
end start