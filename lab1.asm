.model small
.286
.stack 100h
org 100h

INCLUDE fmt.inc

.data
	tmp db 20, 0ffh
	tmp_s db 20 dup("$")
	crlf db cr, lf, "$"
	hello db "Hello, DOS ?", cr, lf, "$"
	stoi_test db 0, 13, 10, "$"
.code
start:
	mov ax, @data
	mov ds, ax
	finit
		
	push offset hello
	call far ptr print
	add sp, 2
	
	push offset tmp
	call far ptr read
	add sp, 2
	
	push offset tmp_s
	push lf
	push "$"
	call far ptr replace
	add sp, 6

	push offset tmp_s
	push cr
	push "$"
	call far ptr replace
	add sp, 6
	
	push offset crlf
	call far ptr print

	push offset tmp_s
	call far ptr print
	add sp, 2
	
	push offset crlf
	call far ptr print

	push offset tmp_s
	call far ptr strlen
	add sp, 2

	add al, "0"
	mov [stoi_test], al
	push offset stoi_test
	call far ptr print
	add sp, 2

	call exit

exit:
	mov ax, 4c00h
	int 21h
end start