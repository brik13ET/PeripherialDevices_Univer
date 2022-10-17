.model small
.286

public print
public read
public replace
public stoi
public strlen

; test
public stof

; todo
public stox
public itos
public xtos
public ftos

cr EQU 0Dh
lf EQU 0Ah
ch_nil equ "0"

LOCALS @@

.data
	int_part dw 0
	point_part dw 0
	base dw 10
	tmp dw 0

; calling conv: args in stack, return in ax

.code
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

		sub cl, ch_nil
		
		cmp cl, 10
		jl @@ELSE
			stc
			jmp @@ENDW

	@@ELSE:
			imul [base]
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

; ret float in st(0)
stof:
	push bp
	mov bp, sp
	push bx
	push cx
	push dx
	xor cx,cx
	mov bx, [bp+6]
	mov cl, ds:[bx]
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
		sub cl, ch_nil
		cmp cl, 10
		jl @@ELSE
			stc
			jmp @@ENDW
		@@ELSE:
			mov [tmp], cx
			fimul base
			fiadd tmp
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
			sub cl, ch_nil
			
			cmp cl, 10
			jl @@ELSE1
				stc
				jmp @@ENDW1
		@@ELSE1:
				mov [tmp], cx
				fiadd tmp
				fidiv base
			inc bx
			mov cl, ds:[bx]
		jmp @@WHILE1
	@@ENDW1:
	faddp
	mov bx, ss:[bp+6]
	mov cl, ds:[bx]
	cmp cl, "-"
	jne @@ENDIF
		fchs
	@@ENDIF:
	pop dx
	pop cx
	pop bx
	pop bp
	retf

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

stox:

	retf

itos:

	retf

xtos:
	
	retf

ftos:
	
	retf
end