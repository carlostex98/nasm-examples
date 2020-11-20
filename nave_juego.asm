%macro MDibujarNave 1 ;la barita
  mov di,ax
  mov si,%1
  cld
  mov cx,20
  rep movsb
%endmacro

%macro MdibujarBola 1 
  mov di,ax
  mov si,%1
  cld
  mov cx,4
  rep movsb
%endmacro


%macro dibujarChungo 1 
  mov di,ax
  mov si,%1
  cld
  mov cx,20
  rep movsb
%endmacro

%macro moverPelota 1
    
  %if %1 = 0
    inc ax
    inc bx
  %endif


%endmacro

%macro imprimirDX 1
  mov dx,%1
  mov ah,9
  int 21h
%endmacro

%macro LimpiarPantalla 0
  mov ah,00h
  mov al,03h
  int 10h
%endmacro

%macro getChar 0
    mov ah, 0x00
  int 0x16
  
  mov ah, 0x02
  mov dl,al
  int 0x21
  mov bl,al
  
  sub bl,48
%endmacro 



%macro imprimirVN 2     ; param 1 = lo que imprimo, param 2 = corrimiento del cursor
  ;funcion 02h, interrupción 10h 
  ;Correr el cursos N cantidad de veces
  ;donde dl = N
  
  mov ah,02H
  mov bh,00h
  mov dh,00h
  mov dl,%2
  int 10h
  
  ;Funcion 09H, interrupcion 21h
  ;imprimir  caracteres en consola
  
  mov dx,%1
  mov ah,9
  int 21h
  
%endmacro

%macro pixel 3    ; x0,y0,color
  
  push cx     ; guardar en la pila cx
  
  mov ah,0ch    ;funcion pinta un pixel
  mov al,%3
  mov bh,0h
  mov dx,%2   ;coord y0
  mov cx,%1   ;coord x0

  inc cx
  inc dx
  
  int 10h
  
  pop cx

  
  
%endmacro




%macro DivirNumeros 2 ; param 1 = la cantidad que lleva el cronometro , param 2 = corrimiento del cursor

  mov al,[%1]   ;numero al registro al
  AAM           ;división de numeros en digitos
                ;al unidades; ah decenas
  
  ;Preparar la unidad para imprimir, es decir sumar el ascii
  add al,30h
  mov [uni],al
  
  ;Preparar la decena para imprimir, es decir sumar el ascii
  add ah,30h
  mov [dece],ah
                            
  ; uni = 0
  ; dece= 3    
  imprimirVN dece, %2+01h      
  imprimirVN uni, %2+02h

%endmacro

;==========================================================================
org 100h
section .text

mainmenu:
  LimpiarPantalla
  imprimirDX encabezado
  imprimirDX blanco
  imprimirDX _menu
  imprimirDX blanco
  getChar
  cmp bl,1
  je inicio
  cmp bl,2
  je imPuntos
  cmp bl,3
  je salir
  
imPuntos:
  LimpiarPantalla
  mov dx, [puntos]

  cmp dx, 0
  je fgg0

  cmp dx, 1
  je fgg1

  cmp dx, 2
  je fgg2

  cmp dx, 3
  je fgg3

  cmp dx, 4
  je fgg4

  cmp dx, 5
  je fgg5

  cmp dx, 6
  je fgg6

  cmp dx, 7
  je fgg7

  cmp dx, 8
  je fgg8

  cmp dx, 9
  je fgg9

  cmp dx, 10
  je fgg10

fgg0:
  imprimirDX n0
  getChar
  jmp mainmenu

fgg1:
  imprimirDX n1
  getChar
  jmp mainmenu

fgg2:
  imprimirDX n2
  getChar
  jmp mainmenu

fgg3:
  imprimirDX n3
  getChar
  jmp mainmenu

fgg4:
  imprimirDX n4
  getChar
  jmp mainmenu

fgg5:
  imprimirDX n5
  getChar
  jmp mainmenu

fgg6:
  imprimirDX n6
  getChar
  jmp mainmenu

fgg7:
  imprimirDX n7
  getChar
  jmp mainmenu

fgg8:
  imprimirDX n8
  getChar
  jmp mainmenu

fgg9:
  imprimirDX n9
  getChar
  jmp mainmenu

fgg10:
  imprimirDX n10
  getChar
  jmp mainmenu
  


inicio:
  ;iniciar el modo video, 13h
  mov ax,13h
  int 10h
  
  mov ax,0A000H
  mov es,ax




  
mainLoop:
  call ClearScreen
  jmp puntoscalc

  
Tiempo:  
  mov ax,[micsegundos]
  inc ax
  cmp ax,60
  je masSeg
  mov [micsegundos],ax
  jmp imprimirTiempo
masSeg:
  mov ax,[segundos]
  inc ax
  cmp ax,60
  je masMin
  mov [segundos],ax
  mov ax,0
  mov [micsegundos],ax
  jmp imprimirTiempo
masMin:
  mov ax,[minutos]
  inc ax
  mov [minutos],ax
    
  mov ax,0
  mov [segundos],ax
  mov [micsegundos],ax
imprimirTiempo:
  DivirNumeros minutos,1EH
  DivirNumeros segundos, 021H
  DivirNumeros micsegundos, 024H
  
  
  ;===========nave===========================
  mov ax,[coordY]
  mov bx,[coordX]
  call DibujarNave

  mov ax, [obsX]
  mov bx, [obsY]
  call DibujarPoll


  ;====pelota
  mov ax,[pelotaX]
  mov bx,[pelotaY]

  call DibujarBola


  
  
  call VSync
  call VSync
  
  ;===========delay==========================
  mov cx, 0000h   ;tiempo del delay
  mov dx, 00fffh  ;tiempo del delay    
  
  
  call Delay
  
  ;===========leer teclado====================  
  call HasKey       ; hay tecla?
  jz mainLoop       ; si no hay, saltar a mainLoop
  call GetCh        ; si hay, leer cual es
  
  cmp al, 'b'       ; es b? , sale
  jne MOV3
  jmp finProg2          

  salir:
    mov ax,04c00h     ;salir
    int 21h
  
  finProg2:
    mov ax,3h         ; Modo Texto
    int 10h
    jmp mainmenu

  finProg:
    mov ax,3h         ; Modo Texto
    int 10h
  
    mov ax,04c00h     ;salir
    int 21h
  
  puntoscalc:
    xor dx, dx
    mov dx, [puntos]
    cmp dx, 20
    je finProg2

    jmp moverbola

  calcobs:
    mov dx, [pelotaX]
    mov bx, [pelotaY]

    cmp bx, 20
    je prebarra

    jmp Tiempo

  prebarra:
    xor eax, eax 
    xor ebx, ebx
    jmp cgen

  cgen:
    cmp dx, 280
    jge vm10

    cmp dx, 250
    jge vm9

    cmp dx, 220
    jge vm8

    cmp dx, 190
    jge vm7

    cmp dx, 160
    jge vm6

    cmp dx, 130
    jge vm5

    cmp dx, 100
    jge vm4

    cmp dx, 70
    jge vm3

    cmp dx, 40
    jge vm2

    cmp dx, 10
    jge vm1

    jmp final2

  vm1:
    cmp dx, 30
    jle elimbar1
    jmp final2

  vm2:
    cmp dx, 60
    jle elimbar2
    jmp final2

  vm3:
    cmp dx, 90
    jle elimbar3
    jmp final2

  vm4:
    cmp dx, 120
    jle elimbar4
    jmp final2

  vm5:
    cmp dx, 150
    jle elimbar5
    jmp final2

  vm6:
    cmp dx, 180
    jle elimbar6
    jmp final2

  vm7:
    cmp dx, 210
    jle elimbar7
    jmp final2

  vm8:
    cmp dx, 240
    jle elimbar8
    jmp final2

  vm9:
    cmp dx, 270
    jle elimbar9
    jmp final2

  vm10:
    cmp dx, 300
    jle elimbar10
    jmp final2


  elimbar1:
    mov eax, 0
    mov edx, dword [barra1+ebx]
    cmp edx, eax
    je final2
    mov dword [barra1+ebx], eax
    inc ebx
    cmp ebx, 20
    jb elimbar1
    jmp final3

  elimbar2:
    mov eax, 0
    mov edx, dword [barra2+ebx]
    cmp edx, eax
    je final2
    mov dword [barra2+ebx], eax
    inc ebx
    cmp ebx, 20
    jb elimbar2
    jmp final3

  elimbar3:
    mov eax, 0
    mov edx, dword [barra3+ebx]
    cmp edx, eax
    je final2
    mov dword [barra3+ebx], eax
    inc ebx
    cmp ebx, 20
    jb elimbar3
    jmp final3

  elimbar4:
    mov eax, 0
    mov edx, dword [barra4+ebx]
    cmp edx, eax
    je final2
    mov dword [barra4+ebx], eax
    inc ebx
    cmp ebx, 20
    jb elimbar4
    jmp final3

  elimbar5:
    mov eax, 0
    mov edx, dword [barra5+ebx]
    cmp edx, eax
    je final2
    mov dword [barra5+ebx], eax
    inc ebx
    cmp ebx, 20
    jb elimbar5
    jmp final3

  elimbar6:
    mov eax, 0
    mov edx, dword [barra6+ebx]
    cmp edx, eax
    je final2
    mov dword [barra6+ebx], eax
    inc ebx
    cmp ebx, 20
    jb elimbar6
    jmp final3

  elimbar7:
    mov eax, 0
    mov edx, dword [barra6+ebx]
    cmp edx, eax
    je final2
    mov dword [barra7+ebx], eax
    inc ebx
    cmp ebx, 20
    jb elimbar7
    jmp final3

  elimbar8:
    mov eax, 0
    mov edx, dword [barra6+ebx]
    cmp edx, eax
    je final2
    mov dword [barra8+ebx], eax
    inc ebx
    cmp ebx, 20
    jb elimbar8
    jmp final3

  elimbar9:
    mov eax, 0
    mov edx, dword [barra9+ebx]
    cmp edx, eax
    je final2
    mov dword [barra9+ebx], eax
    inc ebx
    cmp ebx, 20
    jb elimbar9
    jmp final3

  elimbar10:
    mov eax, 0
    mov edx, dword [barra10+ebx]
    cmp edx, eax
    je final2
    mov dword [barra10+ebx], eax
    inc ebx
    cmp ebx, 20
    jb elimbar10
    jmp final3

  final3:
    jmp Tiempo

  final2:
    jmp Tiempo

  moverbola:
    mov ax, [pelotaX]
    mov bx, [pelotaY]
    mov edx, [movimiento]

    cmp edx, '1'
    je mv1

    cmp edx, '2'
    je mv2

    cmp edx, '3'
    je mv3

    cmp edx, '4'
    je mv4



    mv1:
      dec ax
      dec bx
      jmp pared

    mv2:
      inc ax
      dec bx
      jmp pared

    mv3:
      inc ax
      inc bx
      jmp pared

    mv4:
      dec ax
      inc bx
      jmp pared


    pared:


      cmp ax, 0
      je paredIzq

      cmp bx, 10
      je paredArr

      cmp ax, 318
      je paredDer

      cmp bx, 199 
      je paredAbj

      jmp final

    paredIzq:
      inc ax
      inc ax
      cmp edx, '1'
      je f1

      cmp edx, '4'
      je f2

    f1:
      mov edx, '2'
      jmp final

    f2:
      mov edx, '3'
      jmp final

    paredArr:
      inc bx
      inc bx
      cmp edx, '2'
      je fd1

      cmp edx, '1'
      je fd2

    fd1:
      mov edx, '3'
      jmp final

    fd2:
      mov edx, '4'
      jmp final

    paredDer:
      dec ax
      dec ax
      cmp edx, '3'
      je fdm1

      cmp edx, '2'
      je fdm2

    fdm1:
      mov edx, '4'
      jmp final

    fdm2:
      mov edx, '1'
      jmp final

    paredAbj:
      dec bx
      dec bx
      mov dx, [coordY]
      cmp ax, dx
      jge bmt
      ;fin juego
      jmp finProg

    bmt:
      add dx, 20
      cmp ax, dx
      jle restoBajo

      xor dx, dx
      jmp finProg



    restoBajo:
      xor dx, dx
      mov edx, [movimiento]

      cmp edx, '4'
      je fdx1

      cmp edx, '3'
      je fdx2

    fdx1:
      mov edx, '1'
      jmp final

    fdx2:
      mov edx, '2'
      jmp final


    final:
      mov [pelotaX], ax
      mov [pelotaY], bx
      mov [movimiento], edx
      jmp calcobs



    
  MOV3: 
    cmp al, 'a'
    jne MOV4
    mov bx,[coordY]

    cmp bx, 0
    je mainLoop

    dec bx
    dec bx
    dec bx
    dec bx
    dec bx
    mov [coordY],bx
    jmp mainLoop      
    
  MOV4: 
    cmp al, 'd'
    jne mainLoop
    mov bx,[coordY]
    
    cmp bx, 300
    je mainLoop

    inc bx
    inc bx
    inc bx
    inc bx
    inc bx

    mov [coordY],bx        
  
  
  jmp mainLoop





  
;==========================================================================  
    ;bx= coordenada x
    ;ax= coordenada y
DibujarNave:
  mov cx, bx
  shl cx,8
  shl bx,6
  
  add bx,cx   ;bx = 320
  add ax,bx   ;sumar x
  
  mov di,ax   ;di = y (10,10)
  MDibujarNave barra 
  ret

DibujarPoll:
  mov cx, bx
  shl cx,8
  shl bx,6
  
  add bx,cx   ;bx = 320
  add ax,bx   ;sumar x
  
  mov di,ax   ;di = y (10,10)
  MDibujarNave barra1

  add ax, 30
  MDibujarNave barra2

  add ax, 30
  MDibujarNave barra3

  add ax, 30
  MDibujarNave barra4

  add ax, 30
  MDibujarNave barra5

  add ax, 30
  MDibujarNave barra6

  add ax, 30
  MDibujarNave barra7

  add ax, 30
  MDibujarNave barra8

  add ax, 30
  MDibujarNave barra9

  add ax, 30
  MDibujarNave barra10

  ret


DibujarBola:
  mov cx, bx
  shl cx,8
  shl bx,6
  
  add bx,cx   
  add ax,bx   
  
  mov di,ax   
  MdibujarBola pelota  
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
;procedimiento con la funcion 0, int 10, al = modo en el que estamos
ClearScreen:
  mov ah,0
  mov al, 13h
  int 10h
  
  ret
  
;======================================================================

    ;wait for vsync ( retraso vertical ) 


VSync: 

    mov dx,03dah
    WaitNotVSync: ;wait to be out of vertical sync
    in al,dx
    and al,08h
    jnz WaitNotVSync
    WaitVSync: ;wait until vertical sync begins
    in al,dx
    and al,08h
    jz WaitVSync

    ret     
;==========================================================================
    ; funcion HasKey
    ; hay una tecla presionada en espera?
    ; zf = 0 => Hay tecla esperando 
    ; zf = 1 => No hay tecla en espera     
    
HasKey:
    push ax            

    mov ah, 01h        ; funcion 1
    int 16h            ; interrupcion bios

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
    barra DB 5 , 15 , 15 , 15 , 15 , 15 , 15 , 15 , 15 , 15 , 15 , 15 , 15 , 15 , 15 , 15, 15, 15, 15, 5

    barra1  DB 9 , 9 , 9 , 9 , 9 , 9 , 9 , 9 , 9 , 9 , 9 , 9 , 9 , 9 , 9 , 9, 9, 9, 9, 9
    barra2  DB 9 , 9 , 9 , 9 , 9 , 9 , 9 , 9 , 9 , 9 , 9 , 9 , 9 , 9 , 9 , 9, 9, 9, 9, 9
    barra3  DB 9 , 9 , 9 , 9 , 9 , 9 , 9 , 9 , 9 , 9 , 9 , 9 , 9 , 9 , 9 , 9, 9, 9, 9, 9
    barra4  DB 9 , 9 , 9 , 9 , 9 , 9 , 9 , 9 , 9 , 9 , 9 , 9 , 9 , 9 , 9 , 9, 9, 9, 9, 9
    barra5  DB 9 , 9 , 9 , 9 , 9 , 9 , 9 , 9 , 9 , 9 , 9 , 9 , 9 , 9 , 9 , 9, 9, 9, 9, 9
    barra6  DB 9 , 9 , 9 , 9 , 9 , 9 , 9 , 9 , 9 , 9 , 9 , 9 , 9 , 9 , 9 , 9, 9, 9, 9, 9
    barra7  DB 9 , 9 , 9 , 9 , 9 , 9 , 9 , 9 , 9 , 9 , 9 , 9 , 9 , 9 , 9 , 9, 9, 9, 9, 9
    barra8  DB 9 , 9 , 9 , 9 , 9 , 9 , 9 , 9 , 9 , 9 , 9 , 9 , 9 , 9 , 9 , 9, 9, 9, 9, 9
    barra9  DB 9 , 9 , 9 , 9 , 9 , 9 , 9 , 9 , 9 , 9 , 9 , 9 , 9 , 9 , 9 , 9, 9, 9, 9, 9
    barra10 DB 9 , 9 , 9 , 9 , 9 , 9 , 9 , 9 , 9 , 9 , 9 , 9 , 9 , 9 , 9 , 9, 9, 9, 9, 9

    encabezado db 'Universidad de San Carlos de Guatemala', 0xa,'Facultad de Ingenieria', 0xa,'arquitectura de computadores y ensambladores 1', 0xa,'Nombre: Carlos Tenes', 0xa, 'Carnet: 201700317',0xa,' ', '$'   
    _menu      db '1) ir al juego', 0xa, '2) ver puntos', 0xa,'3) Salir',0xa,' ','$'
    blanco     db 0ah,0dh,'$'


    pelota DB 5,5,5,5

    lv1 DB 3, 3, 3, 3, 3, 3, 3, 3
    lv2 DB 3, 3, 3, 3, 3, 3, 3, 3
    lv3 DB 3, 3, 3, 3, 3, 3, 3, 3

    puntos DW 0

    p1 DW 0
    p2 DW 0
    p3 DW 0
    p4 DW 0
    p5 DW 0
    p6 DW 0
    p7 DW 0
    p8 DW 0
    p9 DW 0
    p10 DW 0

    n1   db '1', 10, 13, '$'
    n2   db '2', 10, 13, '$'
    n3   db '3', 10, 13, '$'
    n4   db '4', 10, 13, '$'
    n5   db '5', 10, 13, '$'
    n6   db '6', 10, 13, '$'
    n7   db '7', 10, 13, '$'
    n8   db '8', 10, 13, '$'
    n9   db '9', 10, 13, '$'
    n0   db '0', 10, 13, '$'
    n10   db '10', 10, 13, '$'



    
    coordX DW 199        ; posicion X de la nave
    coordY DW 130        ; posicion Y de la nave

    pelotaX DW 140
    pelotaY DW 80

    obsX DW 10
    obsY DW 20

    movimiento dd '1'


    uni				db 0,"$"
    dece			db 0,"$"
    
    micsegundos		dw 0
    segundos		  dw 0
    minutos		  	dw 0
    intArray db 20 dup (0)