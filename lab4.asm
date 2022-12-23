.model small
LOCALS
.386
.stack 100h
org 100h

.data

	float		dq 420.1337
	decimal 	dd 0
	r_decimal 	dd 0

	whole 		dw 0
	r_whole 	dw 0
	msg_max_len db 15
	msg_len 	db 15
	msg 		db 15 dup(?)
	crlf		db 13,10,'$'
	dig_cnt 	db 0
	base		dw 10
	prec		db 4



.code

; in: buf, buf_len, st(0)
; out: buf
ftos proc near
	push bp
	mov bp, sp
	
	push ax
	push bx
	push cx
	push dx
	push di
	push si

	mov cx, [bp+4]
	mov bx, [bp+6]

	fist whole

	push cx
	movzx cx, prec
	fisub whole
	getDecimal:
		fimul base
	loop getDecimal
	pop cx

	fistp decimal

	@@25:
		cmp [whole], 0
		je @@30

		mov ax, r_whole
		xor dx, dx
		mul base
		mov r_whole, ax

		mov ax, whole
		xor dx, dx
		div base
		add r_whole, dx
		mov whole, ax
		inc dig_cnt

		jmp @@25
	@@30:

	@@32:
		cmp dig_cnt, 0
		jbe @@39
		cmp si, cx
		jae @@39

		mov ax, r_whole
		xor dx, dx
		div base
		add dx, '0'
		mov bx[si], dl
		mov r_whole, ax
		inc si
		dec dig_cnt

		jmp @@32
	@@39:

	cmp si, 0
	jne @@44
	mov byte ptr bx[si], '0'
	inc si

	@@44:
	cmp si, cx
	jae return

	mov byte ptr bx[si], '.'
	inc si

	cmp si, cx
	jae return

	mov dig_cnt, 0
	@@55:
	cmp decimal, 0
	jbe @@60

	mov ax,word ptr  r_decimal
	xor dx, dx
	mul base
	mov word ptr r_decimal, ax

	mov ax,word ptr  decimal
	xor dx, dx
	div base
	add word ptr r_decimal, dx
	mov word ptr decimal, ax
	inc dig_cnt

	jmp @@55
	@@60:	

	@@62:
	cmp si, cx
	jae @@69

	mov ax,word ptr  r_decimal
	xor dx, dx
	div base
	add dx, '0'
	mov bx[si], dl
	mov word ptr r_decimal, ax
	inc si
	dec dig_cnt

	jmp @@62
	@@69:

	cmp si, cx
	jae return

	mov byte ptr bx[si], "$"

return:
	mov bx, cx
	dec bx
	mov msg[bx], "$"
	pop si
	pop di
	pop dx
	pop cx
	pop bx
	pop ax
	pop bp
	ret
ftos endp

setRoundDown proc near
	push bp
	mov bp, sp
	push ax

	local @@tmp_cwr: word

	fstcw @@tmp_cwr
	mov ax, [@@tmp_cwr]
	or ax, 0100h
	mov [@@tmp_cwr], ax
	fldcw @@tmp_cwr


	pop ax
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
	fld float
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