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

.code
start:	finit
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

		mov ah,4Ch
		int 21h
end start