.model small
.286
.stack 100h
org 100h

INCLUDE fmt.inc

.data
	tmp db 20, 0ffh
	tmp_s db 20 dup("$")
	crlf db cr, lf, "$"
	hello db "Converter; set func to choose another", cr, lf, "$"
	testbuf db 20 dup("$")
.code
start:
; init data segment
	mov ax, @data
	mov ds, ax
	finit
		
; print welcome msg
	push offset hello
	call far ptr print
	add sp, 2
; read string
	push offset tmp
	call far ptr read
	add sp, 2

; delete LF symbol
	push offset tmp_s
	push lf
	push "$"
	call far ptr replace
	add sp, 6

; delete CR symbol
	push offset tmp_s
	push cr
	push "$"
	call far ptr replace
	add sp, 6
; print CRLF
	push offset crlf
	call far ptr print
	add sp, 2

; convert string with decimal to integer
	push offset tmp_s
	call far ptr stoi
	add sp, 2
; convert integer to string with hexadecimal
	push ax
	push offset testbuf
	push 19
	call far ptr xtos
	add sp, 6

; print that string
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