.model small
LOCALS
.386
.stack 100h
org 100h

.data
		A		dd 0.0
		B		dd 6.2830
		H		dd 0
		Curr	dd 0
		Y		dd 640 dup(0)
		Min		dd 0
		Max		dd 0
		K		dd 0
		Yabs	dw 640 dup(0)
		Wid		dw 640
		Hei		dw 479
		crlf	db 13,10,"$"
		sign	dw 0
		i		dw 0
		d		dw 0
		dc		dw 0
		base	dw 10
		t1		db "Write float ",13,10,"$"
		buf1	db 33, 0
		buf1_s	db 34 dup("$")
		buf2	db 33, 0
		buf2_s	db 34 dup("$")
.code
;fmt, io

replace proc near
	push bp
	mov bp, sp
	push bx
	push SI

	mov	si, [bp + 8] ; str
	mov bh, [bp + 6] ; from
	mov bl, [bp + 4] ; to

	replace_while:
	cmp byte ptr [si], "$"
	je	replace_while_end

	cmp byte ptr ds:[si], bh
	jne replace_while_skip
	mov [si], bl
	replace_while_skip:
	inc si
	jmp replace_while
	replace_while_end:


	pop SI
	pop bx
	pop bp
	ret
replace endp

gets proc near
	push bp
	mov bp, sp
	push dx
	push ax

	mov ah, 0ah
	mov dx, [bp+4]
	int 21h

	pop ax
	pop dx
	pop bp
	ret
gets endp

stof proc near
	push bp
	mov bp, sp
	push ax
	push bx
	push cx
	push dx
	push si
	push di


	mov si, [bp + 6]
	mov bx, [bp + 4]
	;mov [base], 10

	mov [i], 0
	mov [d], 0
	mov [dc], 0
	mov [sign], 0

	; sign
	cmp byte ptr [si], "-"
	jne @@end_sign
	mov sign, 1
	inc si
	@@end_sign:

	@@whole:
	cmp byte ptr [si], "$"
	je @@endf
	cmp byte ptr [si], 13
	je @@endf
	cmp byte ptr [si], 10
	je @@endf
	cmp byte ptr [si], "."
	je @@end_whole

	xor dx, dx
	mov ax, [i]
	mul base
	xor dx, dx
	mov dl, [si]
	add ax, dx
	sub ax, "0"
	mov [i], ax

	inc si
	jmp @@whole
	@@end_whole:
	inc si

	@@float:
	cmp byte ptr [si], "$"
	je @@end_float
	cmp byte ptr [si], 13
	je @@end_float
	cmp byte ptr [si], 10
	je @@end_float

	xor dx, dx
	mov ax, [d]
	mul base
	xor dx, dx
	mov dl, [si]
	add ax, dx
	sub ax, "0"
	mov [d], ax

	inc [dc]
	inc si

	jmp @@float
	@@end_float:

	fild i
	fild d

	mov cx, [dc]
	@@mul10:

	fild base
	fdivp

	loop @@mul10

	faddp
	cmp [sign], 0
	je @@end_sign_processing
	fchs
	@@end_sign_processing:

	@@endf: 

	pop di
	pop si
	pop dx
	pop cx
	pop bx
	pop ax
	pop bp
	ret
stof endp

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

; Math, iterate
; in: st(0)
; out: st(0)
fn_calc proc near
	push bp
	mov bp, sp

	fsincos
	fmul st(0), st(0)
	fxch st(1)
	fld st(0)
	fmul st(0), st(1)
	fmulp
	faddp

	pop bp
	ret
fn_calc endp

fn proc near
	push bp
	mov bp, sp
	push ax
	push cx
	push bx

	; Calculate Y Values for range [A-B] with step H
	mov cx, [Wid]
	fld B
	fstp Curr

	fn_loop1:

	sub cx, 1
	mov bx, cx

	shl bx, 2

	fld Curr
	
	call fn_calc

	fstp Y[bx]

	fld Curr
	fld H
	fsubp
	fstp Curr

	add cx, 1
	loop fn_loop1

	fld Y[0]
	fst Max
	fstp Min

	; Min & Max Calc
	mov cx, [Wid]
	fn_loop2:
	sub cx, 1
	mov bx, cx
	shl bx, 2

	fld Y[bx]
	fld Max
	fxch

	; cmp max & fpu top
	fcom st(1)
	fstsw ax
	sahf
	jc fn_loop2_endMax
	jz fn_loop2_endMax
	fst Max
	fn_loop2_endMax:

	ffree
	fld Min
	fxch

	; cmp min & fpu top
	fcom st(1)
	fstsw ax
	sahf
	jnc fn_loop2_endMin
	
	fst Min
	fn_loop2_endMin:

	; fxch
	add cx,1
	ffree st(0)
	fincstp
	ffree st(0)
	
	loop fn_loop2

	fld Max
	fsub Min
	fild Hei
	fxch
	fdivp
	fstp K
	call setRoundNear

	mov cx, [Wid]
	fn_loop3:

	sub cx, 1
	mov bx, cx
	shl bx, 2
	fld K

	fld Y[bx]
	fsub Min
	fmul
	fild Hei
	fxch
	fsubp
	shr bx, 1
	fistp Yabs[bx]

	add cx, 1
	loop fn_loop3

	pop bx
	pop cx
	pop ax
	pop bp
	ret
fn endp

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

setRoundUp proc near
	push bp
	mov bp, sp
	push ax

	local @@tmp_cwr: word

	fstcw @@tmp_cwr
	mov ax, [@@tmp_cwr]
	or ax, 0200h
	mov [@@tmp_cwr], ax
	fldcw @@tmp_cwr

	pop ax
	pop bp
	ret
setRoundUp endp

setRoundNear proc near
	push bp
	mov bp, sp
	push ax

	local @@tmp_cwr: word

	fstcw @@tmp_cwr
	mov ax, [@@tmp_cwr]
	and ax, 0FCFFh
	mov [@@tmp_cwr], ax
	fldcw @@tmp_cwr


	pop ax
	pop bp
	ret
setRoundNear endp

; plot, videomode
setvid proc near
	push bp
	mov bp, sp
	push ax
	
	mov ax, 0012h
	int 10h

	mov ax, 0500h
	int 10h

	pop ax
	pop bp
	ret
setvid endp

settext proc near
	push bp
	mov bp, sp
	push ax
	
	mov ax, 0003h
	int 10h

	mov ax, 0500h
	int 10h

	pop ax
	pop bp
	ret
settext endp

point proc near
	push bp
	mov bp, sp
	push ax
	push bx
	push cx
	push dx

	mov ax, 0c0Ah
	mov bx, 0000h
	mov cx, [bp + 6]
	mov dx, [bp + 4]
	int 10h

	pop dx
	pop cx
	pop bx
	pop ax
	pop bp
	ret
point endp

draw_fn proc near
	push bp
	mov bp, sp
	push cx
	push bx
	push dx

	mov cx, [Wid]
	draw_fn_loop1:
	sub cx, 1
	mov bx, cx
	shl bx, 1

	mov dx, Yabs[bx]
	push cx
	push dx
	call point
	add sp, 4
	add cx, 1
	loop draw_fn_loop1

	pop dx
	pop bx
	pop cx
	pop bp
	ret
draw_fn endp

draw_scr proc near
	push bp
	mov bp, sp
	push cx

	mov cx, [Wid]
	draw_scr_loop1:
	dec cx
	push cx
	push 0
	call point
	add sp, 4

	push cx
	push 479
	call point
	add sp, 4
	inc cx
	loop draw_scr_loop1
	mov cx, [Hei]
	draw_scr_loop2:
	dec cx

	push 0
	push cx
	call point
	add sp, 4

	push 639
	push cx
	call point
	add sp, 4
	inc cx
	loop draw_scr_loop2

	pop cx
	pop bp
	ret
draw_scr endp


start:
	mov ax, @data
	mov ds, ax
	finit
	call setRoundDown


	; read floats
	push offset t1
	call puts
	add sp, 2

	push offset buf1
	call gets
	add sp, 2

	push offset buf1_s
	push ','
	push '.'
	call replace
	add sp, 6

	push offset buf1_s
	push offset A
	call stof
	add sp, 4

	push offset t1
	call puts
	add sp, 2

	push offset buf2
	call gets
	add sp, 2

	push offset buf2_s
	push ','
	push '.'
	call replace
	add sp, 6

	push offset buf2_s
	push offset B
	call stof
	add sp, 4

	; init constatnts
	fld B
	fsub A
	fild Wid
	fdivp
	fstp H
	ffree
	fdecstp

	call fn
	call setvid
	; call draw_scr
	; call getch
	call draw_fn
	call getch
	call settext

	;exit 0
	mov ax,4c00h
	int 21h
end start