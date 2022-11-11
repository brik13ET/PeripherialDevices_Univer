.model small
.286
LOCALS @@

public memcpy

.code
; in: buf_in, buf_in_seg, buf_out, buf_out_seg, len
; out: void
memcpy:
	push bp
	mov bp, sp
	push sp
	push ax
	push cx
	push si
	push di
	push es


	mov di, [bp+14] ; in
	mov ax, [bp+12] ; in_seg
	mov si, [bp+10] ; out
	mov dx, [bp+8] ; out_seg
	mov cx, [bp+6] ; len

@@whlie:
	mov es, ax
	mov dl, es:[di]
	mov es, dx
	mov es:[si], dl

	inc di
	inc si
	loop @@whlie

	pop es
	pop di
	pop si
	pop cx
	pop ax
	pop sp
	pop bp
retf


end