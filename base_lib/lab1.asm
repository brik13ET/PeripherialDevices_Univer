.model small
.286
.stack 100h
org 100h

.data
	crlf db cr, lf, "$"
	hello db "print float single precision", cr, lf, "$"
	float dd 42.1337
	tmp db 20 dup("$")
	tmp_size equ 20
.code
start:
; init data segment
	assume cs: @code, ds: @data, ss: @stack
	finit
	
; float to str
	push offset float ; 2
	push offset tmp ; 2
	push tmp_size ; 2
	call far ptr ftos
	add sp, 6
; print welcome msg
	
	push ax
	call far ptr print
	add sp, 2

; print crlf
	push offset crlf
	call far ptr print
	add sp, 2



	call exit

exit:
	mov ax, 4c00h
	int 21h
end start