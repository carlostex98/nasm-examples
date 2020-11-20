%macro pixel 3		; x0,y0,color
	
	push cx			; guardar en la pila cx
	
	;funcion 0ch = pintar un pixel, donde:
	;al = color del pixel
	;bh = 0h
	;dx = coordenada en y0
	;cx = coordenada en x0
	mov ah,0ch		;funcion pinta un pixel
	mov al,%3
	mov bh,0h
	mov dx,%2		;coord y0
	mov cx,%1		;coord x0
	
	int 10h
	
	pop cx
	
	
%endmacro


org 100h
section .text
	;iniciamos modo video
	mov ax,13h
	int 10h
	
	;iniciamos a pintar el eje X
	mov cx,13eh
	
eje_x:
	pixel 13eh, 5fh, 4fh	