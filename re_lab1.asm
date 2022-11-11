.model small
.386
.stack 100h
org 100h

.data
		N	dw 640
		H	dw 480
		A 	dd 0.0
		B 	dd 1.0
		stp	dd 0
		K 	dd 0
		Min dd 0
		Max dd 0
		Curr dd 0
		Y	dd 640 dup(?)
		dmul dw 10000
		base dw 10
		i	dw 0
		d	dw 0
		alph db "0123456789"
		point db ".$"
		crlf db 13,10,"$"
.code
start:
		mov ax, @data
		mov ds, ax
		finit
		
		fld B
		fsub A
		fidiv N
		fstp stp
		
		fld A
		fstp Curr

		mov cx, [N]

.for1:	fld Curr
		mov bx, cx
		fstp Y[bx]

		fld Curr
		fadd stp
		fstp Curr
		loop .for1

		fld Y[0]
		fst Min
		fstp Max

		mov cx, [N]

.for2:	mov bx, cx
		
		fld max
		fld Y[bx]
		fcom
		fstsw ax
		sahf

		fxch
		fstp Max
		jnc .if
		fst Max

.if:	fld Min
		fcom
		fstsw ax
		sahf
		jc .endif
		fstp Min
.endif:	loop .for2
		
		fld Max
		fsub Min
		fdivr stp
		fstp K

		mov cx, [N]
.for3:	mov bx, cx
		fld Y[bx]
		fsub Min
		Fmul K
		fst Y[bx]
		loop .for3

		mov cx, [N]
.print:	mov bx, cx
		fld Y[bx]
		fist i
		fisub i
		fimul dmul
		fistp d
		push cx

		mov ax, [i]
.i_iter:cmp ax, 0
		je .i_iter_end
		xor dx, dx
		div base
		push ax

		mov ax, 0200h
		add dl, "0"
		int 21h

		pop ax
		jmp .i_iter
.i_iter_end:
		
		mov ax, 0200h
		mov dl, "."
		int 21h
		
		mov ax, [d]
.d_iter:cmp ax, 0
		je .d_iter_end
		xor dx, dx
		div base
		push ax

		mov ax, 0200h
		add dl, "0"
		int 21h

		pop ax
		jmp .d_iter
.d_iter_end:
		

		mov ax, 0200h
		mov dl, 13
		int 21h
		mov ax, 0200h
		mov dl, 10
		int 21h

		pop cx
		loop .print
		
		mov ah,4Ch
		int 21h
end start