.model small
.386
.stack 100h
org 100h

.data
	vid_stat dd 0
	fill_col db 07fh
	tmp dw 0
	k dq 0
	w dq 639
	h dq 479
	Y dw 639
.code
start:
	mov ax, @data
	mov ds, ax

	mov ax, 0f00h ; get curr mode
	int 10h

	; mov [vid_stat], ax ; save prev mode
	; mov [vid_stat + 2], bh

	mov ax, 0011h ; set to graphics
	int 10h
	call clear
	mov cx, 0
	finit
	fild h
	fild w
	fdiv
	fchs
	fstp k


line:			;drawin` graph y = tmp*x
	mov ah, 0ch
	mov al, 0fh
	xor bh, bh
	int 10h

	mov bx, cx
	mov [tmp], cx

	fild tmp
	call fn

	fld k
	fmul
	fild h
	fadd
	fistp Y + bx
	mov dx, Y[bx]

	inc cx
	cmp cx, 639
	jne line

	xor ax, ax
	int 16h

	mov ax, 0003h
	int 10h

	mov ax, 4c00h
	int 21h

; in: FPU inited, st(0) - x
; out: st(0) - y
fn:
	fsincos
	fld st(0)
	fmul
	fadd
	fld1
	fld1
	fadd
	fdivp st(1), st(0)
	ret

clear:
	push ax
	push cx
	push dx
	mov cx, 639 ; fill screen with white
	mov al, [fill_col]
	mov ah, 0ch
	xor bh, bh
@@reset:
	mov dx, 479
@@point:
	int 10h

	dec dx
	cmp dx, 0
	jne @@point

	dec cx
	cmp cx, 0
	jne @@reset ; endfill
	pop dx
	pop cx
	pop ax
	ret

end start