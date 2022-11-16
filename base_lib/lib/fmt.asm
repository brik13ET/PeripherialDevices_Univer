.model small
.286

INCLUDE sys.inc

public print
public read
public replace
public stoi
public strlen
public stox
public stoupper
public stolower
public to_lower
public to_upper
public itos

; test
public stof

; todo
public xtos
public ftos

cr EQU 0Dh
lf EQU 0Ah
case_delta equ "a" - "A"

LOCALS @@

.data
	hex_alph db "0123456789ABCDEF"

; calling conv: args in stack, return in ax

.code
; in: string
; out: integer
stoi:
	push bp
	mov bp, sp
	push bx
	push cx
	push dx
	push ds

	mov bx, [bp+6]

	mov ax, @data
	mov ds, ax
	
	xor cx,cx
	xor ax,ax
	@@WHILE:
		mov cl, ds:[bx]
		cmp cl, "$"
		je @@ENDW

		sub cl, "0"
		
		cmp cl, 10
		jl @@ELSE
			stc
			jmp @@ENDW

	@@ELSE:
			imul ax, 10
			add ax, cx
		inc bx
	jmp @@WHILE
	@@ENDW:
	mov bx, ss:[bp+6]
	mov cl, ds:[bx]
	cmp cl, "-"
	jne @@ENDIF
		neg ax
	@@ENDIF:
	
	pop ds
	pop dx
	pop cx
	pop bx
	pop bp
	retf

; in: string
; out: float
; ret in st(0)
stof:
	push bp
	mov bp, sp
	sub sp, 4
	push bx
	push cx
	push dx

	xor cx,cx
	mov bx, [bp+6]
	mov cl, ds:[bx]
	mov [bp], 10
	fldz
	@@WHILE: 
	cmp cl, "$" 
	je @@ENDW
	cmp cl, "." 
	je @@ENDW
	cmp cl, "," 
	je @@ENDW
	cmp cl, " " 
	je @@ENDW
		mov cl, ds:[bx]
		sub cl, "0"
		cmp cl, 10
		jl @@ELSE
			stc
			jmp @@ENDW
		@@ELSE:
			mov [bp - 2], cx
			fimul [bp]
			fiadd [bp - 2]
		inc bx
		mov cl, ds:[bx]
		jmp @@WHILE
	@@ENDW:
	fldz
	cmp cl, "."
	jne @@ENDIF
	cmp cl, ","
	jne @@ENDIF
		inc bx
		mov cl, ds:[bx]
	@@WHILE1:
		mov cl, ds:[bx]
		cmp cl, "$"
		je @@ENDW1
			sub cl, "0"
			
			cmp cl, 10
			jl @@ELSE1
				stc
				jmp @@ENDW1
		@@ELSE1:
				mov [bp - 2], cx
				fiadd [bp - 2]
				fidiv [bp]
			inc bx
			mov cl, ds:[bx]
		jmp @@WHILE1
	@@ENDW1:
	faddp
	mov bx, [bp+6]
	mov cl, ds:[bx]
	cmp cl, "-"
	jne @@ENDIF
		fchs
	@@ENDIF:
	pop dx
	pop cx
	pop bx
	add sp, 4
	pop bp
	retf

; in: string
; out: uint
strlen:
	push bp
	mov bp, sp
	push bx
	push cx
	push ds

	mov ax, @data
	mov ds, ax

	xor ax, ax

	mov bx, [bp + 6]
	mov cl, [bx]
	@@WHILE:
	cmp cl , "$"
	je @@ENDW
		inc ax
		inc bx
		mov cl, ds:[bx]
	jmp @@WHILE
	@@ENDW:
	
	pop ds
	pop cx
	pop bx
	pop bp
	retf

; in: string
; out: void
print:
	push bp
	mov bp, sp
	push ax
	push dx

	mov ax, 0900h
	mov dx, [bp + 6]
	int 21h

	pop dx
	pop ax
	pop bp
	retf

; in: ptr to formatted buffer in stack
; out: void
read:
	push bp
	mov bp, sp
	push ax
	push dx

	mov ah, 0ah
	mov dx, [bp + 6]
	int 21h

	pop dx
	pop ax
	pop bp
	retf

; in: string, char, char
; out: void
replace:
	push bp
	mov bp, sp
	push ax
	push bx
	push cx
	
	mov ch, [bp + 6]
	mov ah, [bp + 8]
	mov bx, [bp + 10]
	
	mov al, [bx + 0]
	@@WHILE:
		cmp al, ah
		jne @@ENDIF
			mov [bx], ch 
	@@ENDIF:
		inc bx
		mov al, [bx + 0]

	cmp  al, "$"
	jne @@WHILE

	pop cx
	pop bx
	pop ax
	pop bp
	retf

; in: string with hex num
; out: num
stox:
	push bp
	mov bp, sp
	push bx
	push cx
	push dx
	; push ds

	mov bx, [bp+6]

	; mov ax, @data
	; mov ds, ax
	
	xor cx,cx
	xor ax,ax
	xor dx,dx
	@@WHILE:
		mov cl, ds:[bx]
		cmp cl, "$"
		je @@ENDW

		push cx
		call far ptr to_lower
		add sp, 2

		cmp al, "9"
		jg @@NAN
		cmp al, "0"
		jl @@NAN

		sub al, "0"
		jmp @@ENDIF

	@@NAN:

		cmp al, "a"
		jl @@BAD
		cmp al, "f"
		jg @@BAD

		sub al, 87
		jmp @@ENDIF

	@@BAD:
		stc
		jmp @@ENDW

	@@ENDIF:
		imul dx, dx, 10h
		add dx, ax

	inc bx
	jmp @@WHILE
	@@ENDW:
	mov ax, dx
	mov bx, ss:[bp+6]
	mov cl, ds:[bx]
	cmp cl, "-"
	jne @@ENDIF1
		neg ax
	@@ENDIF1:
	
	; pop ds
	pop dx
	pop cx
	pop bx
	pop bp
	retf

; in: short, buf ptr, buf size
; out: string in buf
itos:
	push bp
	mov bp, sp
	sub sp, 2
	push bx
	push cx
	push dx
	push si
	push di

	xor di, di
	mov [bp], 10
	mov ax, [bp + 10] ; short
	mov bx, [bp + 8] ; buf ptr
	mov cx, [bp + 6] ; buf size

	mov di, cx
	@@while:
	cmp di, 0
	jl @@endw
	test ax, ax
	jz @@endw
	
	push ds
	mov dx, @data
	mov ds, dx

	xor dx, dx

	div [bp]
	mov si, dx
	mov dh, [hex_alph + si]
	pop ds
	mov [bx + di], dh

	dec di
	jmp @@while
	@@endw:

	lea ax, [bx + di + 1]

	pop di
	pop si
	pop dx
	pop cx
	pop bx
	add sp, 2
	pop bp
	retf

; in: short, buf ptr, buf size
; out: string in buf
xtos:
	push bp
	mov bp, sp
	sub sp, 2
	push bx
	push cx
	push dx
	push si
	push di

	xor di, di
	mov [bp], 10h
	mov ax, [bp + 10] ; short
	mov bx, [bp + 8] ; buf ptr
	mov cx, [bp + 6] ; buf size

	mov di, cx
	@@while:
	cmp di, 0
	jl @@endw
	test ax, ax
	jz @@endw
	
	push ds
	mov dx, @data
	mov ds, dx

	xor dx, dx

	div [bp]
	mov si, dx
	mov dh, [hex_alph + si]
	pop ds
	mov [bx + di], dh

	dec di
	jmp @@while
	@@endw:

	lea ax, [bx + di + 1]

	pop di
	pop si
	pop dx
	pop cx
	pop bx
	add sp, 2
	pop bp
	retf


; in: float, buf, line
; out: buf
ftos:
	push bp
	mov bp, sp
	push sp
	sub sp, 10 ; 3 variables in stack for 6 bytes
	push bx
	push cx
	push dx
	push si
	push di
	push es

	mov ss:[bp-2], 0010h ; base
	mov ss:[bp-4], 0000h ; whole
	mov ss:[bp-6], 0000h ; point
	mov ss:[bp - 8], 00000000h ; tmp

	mov bx, ss:[bp + 10] ; single precision float
	mov di, ss:[bp + 8] ; buf ptr
	mov si, ss:[bp + 6] ; buf siz

	push bx
	mov bx, @data
	mov es, bx
	pop bx

	mov ss:[bp - 8], bx

	; push 4
	; push ss
	; push bp - 8
	; push ds
	; push di
	; call memcpy
	; add sp, 10 

	fild ss:[bp - 8]
	fist ss:[bp - 4]

	add si, di
	sub si, 2
	@@while:
	cmp di, si
	jg @@endw
	cmp word [bp - 4], 0
	je @@endw

	xor dx, dx
	mov bx, 10
	div bx
	mov bx, dx
	mov dh, es:[hex_alph + bx]
	mov [si], dh
	dec si
	jmp @@while
	@@endw:
	pop es
	pop di
	pop si
	pop dx
	pop cx
	pop bx
	pop sp
	pop bp
	retf

; in: char
; out: char
to_lower:
	push bp
	mov bp, sp

	xor ax,ax
	mov al, ss:[bp + 6]

	cmp al, "Z"
	jg @@ENDIF
	cmp al, "A"
	jl @@ENDIF
	add al, case_delta
	@@ENDIF:
	pop bp
	retf

; in: char
; out: char
to_upper:
	push bp
	mov bp, sp

	xor ax,ax
	mov al, ss:[bp + 6]

	cmp al, "a"
	jl @@ENDIF
	cmp al, "z"
	jg @@ENDIF
	sub al, case_delta
	@@ENDIF:
	pop bp
	retf

; in: string
; out: void
stolower:
	push bp
	mov bp, sp
	push bx
	mov bx, [bp + 6]
	@@WHILE:
	mov al, [bx]
	cmp al, "$"
	je @@ENDW
	push ax
	call far ptr to_lower
	add sp, 2
	jc @@ENDW

	mov [bx], al

	inc bx
	jmp @@WHILE
	@@ENDW:
	pop bx
	pop bp
	retf

; in: string
; out: void
stoupper:
	push bp
	mov bp, sp
	push bx
	mov bx, [bp + 6]
	@@WHILE:
	mov al, [bx]
	cmp al, "$"
	je @@ENDW
	push ax
	call far ptr to_upper
	add sp, 2
	jc @@ENDW

	mov [bx], al

	inc bx
	jmp @@WHILE
	@@ENDW:
	pop bx
	pop bp
	retf

end