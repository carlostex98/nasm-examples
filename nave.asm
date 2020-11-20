%macro MDibujarNave 1	;vector[8]
	mov di,ax
	mov si,%1
	cld
	mov cx,8
	rep movsb
%endmacro
	
%macro DivNumeros 2 	; 1 = la cantidad que lleva el cronometro ; 2 = corrimiento del cursor
	mov al,[%1]	;numero al registro 'al'
	AAM			; divide los numeros en digitos 
				; al = unidades, ah = decenas
	
	;prepramos la unidad para ser impresa, es decir le sumamos el ascii			
	add al,30h
	mov [uni],al
	
	;prepramos la decena para ser impresa, es decir le sumamos el ascii			
	add ah,30h	
	mov [dece],ah
	
	imprimir dece, %2+01h
	imprimir uni, %2+02h	
%endmacro	

%macro imprimir 2 ; param 1 = lo que imprimo, param 2 = corrimiento del cursor

  ;funcion 02h, interrupción 10h 
  ;Correr el cursor N cantidad de veces
  ;donde dl = N
  
  ;push ds
  ;push dx
  ;xor dx,dx
  
  mov ah,02h
  mov bh,0		;pagina
  mov dh,0		;fila
  mov dl,%2		;columna
  int 10h
  
 
  
  ;Funcion 09H, interrupcion 21h
  ;imprimir  caracteres en consola
   mov dx,%1
   mov ah,09h
   int 21h
  
  ;pop dx
  ;pop ds
%endmacro
;==========================================================================
org 100h
section .text

inicio:
;iniciar el modo video, 13h
	mov al,13h
	xor ah,ah
	int 10h
	
;posicionarme directamente a la memoria de video	
	mov ax,0A00H
	mov es,ax
	
	xor di,di
	
mainLoop:
	mov bl,0
	call ClearScreen

	;===============cronometro===================
	Tiempo:
		mov ax,[microsegundos]
		inc ax
		cmp ax,60
		je masSeg
		mov [microsegundos],ax
		jmp imprimirTiempo
	masSeg:
		mov ax,[segundos]
		inc ax
		cmp ax,60
		je masMin
		mov [segundos],ax
		mov ax,0
		mov [microsegundos],ax
		jmp imprimirTiempo
	masMin:
		mov ax,[minutos]
		inc ax
		mov [minutos],ax
		
		mov ax,0
		mov [segundos],ax
		mov [microsegundos],ax
		
	imprimirTiempo:
		DivNumeros minutos, 1EH
		DivNumeros segundos,21H
		DivNumeros microsegundos, 024H	
	
	;===========nave===========================
	mov ax,[coordY]
	mov bx,[coordX]
	call DibujarNave		
	
	call Flip
	
	
	;============delay==========================
	mov cx,0000h 	;tiempo del delay
	mov dx,0ffffh 	;tiempo del delay
	
	call Delay
	
	
	
	;============leer el buffer de mi teclado =========00
	call HasKey ;hay tecla?
	jz mainLoop	;si no hay, saltar mainLoop
	call GetCh	; si hay, leer cual es
	
	cmp al,'b' 	; es b ? , se sale
	jne MOV1	;sino comprobar movimientos
	
	finProg:
		mov ax,3h	;regresar al modo texto
		int 10h
		
		mov ax, 04c00h	;terminar mi programa
		int 21h
	
	MOV1:	;mov derechar
		cmp al,'d'
		jne MOV2
		
		; si llega aqui es la tecla d
		
		mov ax,[coordX]
		inc ax
		mov [coordX],ax
		
		jmp mainLoop
	
	MOV2:	;mov izq
		cmp al,'a'
		jne MOV3
		
		; si llega aqui es la tecla a
		
		mov ax,[coordX]
		dec ax
		mov [coordX],ax
		
		jmp mainLoop
		
	MOV3:	;mov arriba
		cmp al,'w'
		jne MOV4
		
		; si llega aqui es la tecla w
		
		mov ax,[coordY]
		dec ax
		mov [coordY],ax
		
		jmp mainLoop	
		
	MOV4:	;mov abajo
		cmp al,'s'
		jne MOV4
		
		; si llega aqui es la tecla w
		
		mov ax,[coordY]
		inc ax
		mov [coordY],ax
		
		jmp mainLoop	
	
	
	
	
	
;==========================================================================
;procedimiento con la funcion 0, int 10, al = modo en el que estamos	
  ;mov ah,0
  ;mov al, 13h
  ;int 10h
  
 ;procedimiento directo a la memoria de video
ClearScreen:
	mov ax,ds	
	mov es,ax	;Guardando la dirección base
	mov di,buffer
	
	mov al,bl	; pasar el color a ax low
	mov ah,bl	; pasar el color a ax high
	shl eax,16	
	mov al,bl
	mov ah,bl
	
	mov cx,16000 	; 64 000 bytes / 4byte por copia = 16, 000
	rep stosd 		;ciclo "stro string double word" repetirla 16000
	
	ret
	
;==========================================================================  
    ;bx= coordenada x
    ;ax= coordenada y
	; y*320 + x = (x,y)
	;10 * 320 + 100 = 3300
	
DibujarNave:
	push ax
	
	mov ax,ds
	mov es,ax	;guardando la dirección base
	
	pop ax
	
	mov cx,bx	;coord x
	shl cx,8
	shl bx,6
	
	add bx,cx	;bx = 320
	
	add ax,bx	;sumar x a y
	
	add ax, buffer
	
	mov di,ax	;di = (10,10)
	MDibujarNave naveFila1
	
	add ax,320	; aumentar y
	MDibujarNave naveFila2
	
	add ax,320	; ; aumentar y
	MDibujarNave naveFila3
	
	add ax,320	; aumentar y
	MDibujarNave naveFila4

	add ax,320	; aumentar y
	MDibujarNave naveFila5
	
	add ax,320	; aumentar y
	MDibujarNave naveFila6
	
	add ax,320	; aumentar y
	MDibujarNave naveFila7
	
	ret

;=====================================================================
	; flip copiar de buffer a pantalla
	; casi casi es un clearscreen 
	; movsd ( como stosd pero copia de memoria a memoria ) 
	; movsd copia desde ds:si hacia es:di 

Flip:
	

	mov ax,0A000H
	mov es,ax
	mov di,0
	
	mov si,buffer
	mov cx,16000
	
	call VSync
	
	rep movsd
	
	
	ret
	
;======================================================================

    ;wait for vsync ( retraso vertical ) 	
VSync:
	mov dx,03dah
	WaitNotVSync: 	; esperar a estar afuera de la sincronización vertical
	in al,dx
	and al,08h
	jnz WaitNotVSync
	WaitVSync: 		; esperar hasta que la sincronización vertical inicie
	in al,dx
	and al,08h
	jz WaitVSync
	ret
	
;==========================================================================
;procedimiento de delay
;funcion 86h, interrupcion 15h
;Esta funcion recibe un numero de 32 bits, pero en dos partes
; de 16 bits c/u cx y en dx,  CX es la parte alta y DX es la parte baja
;Esta funcion causa retardos de un microsegundo=1/1 000 000

Delay:
  mov ah,86h
  int 15h
  
  ret
	
;==========================================================================
    ; funcion HasKey
    ; hay una tecla presionada en espera?
    ; zf = 0 => Hay tecla esperando 
    ; zf = 1 => No hay tecla en espera     
    HasKey:
		push ax
		mov ah,01h
		int 16h
		pop ax
		ret
		
;======================================================================
    ; funcion GetCh
    ; ascii tecla presionada
    ; Salida en al codigo ascii sin eco, via BIOS		
	GetCh:
		xor ah,ah
		int 16h
		ret
		
		
;==========================================================================
section .data
	naveFila1 DB 0 , 0 , 0 , 15 , 15 , 0 , 0 , 0 
	naveFila2 DB 0 , 0 , 15 , 3 , 3 , 15 , 0 , 0 
    naveFila3 DB 0 , 7 , 7 , 6 , 6 , 7 , 7 , 0 
    naveFila4 DB 7 , 7 , 7 , 7 , 7 , 7 , 7 , 7 
    naveFila5 DB 8 , 8 , 8 , 8 , 8 , 8 , 8 , 8 
    naveFila6 DB 4 , 4 , 4 , 0 , 0 , 4 , 4 , 4
    naveFila7 DB 0 , 4 , 0 , 0 , 0 , 0 , 4 , 0
	
	coordX DW 10
	coordY DW 10
	
	;doble buffer
    buffer resb 64000
	
	
	uni				db 0,"$"
    dece			db 0,"$"
    
    microsegundos		dw 0
    segundos		dw 0
    minutos		  	dw 0