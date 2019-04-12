
; You may customize this and other start-up templates; 
; The location of this template is c:\emu8086\inc\0_com_template.txt

org 100h ; Indicamos que el programa seguira la estructura .com

jmp main ; Hacemos un salto incodicional a main para ingresar al programa

mx1: db "Ingresa x1", 0Dh, 0Ah, 24h ; Etiqueta que sirve para solicitar X1
my1: db "Ingresa y1", 0Dh, 0Ah, 24h ; Etiqueta que sirve para solicitar Y1

mx2: db "Ingresa x2", 0Dh, 0Ah, 24h ; Etiqueta que sirve para solicitar X2
my2: db "Ingresa y2", 0Dh, 0Ah, 24h ; Etiqueta que sirve para solicitar Y2

; Etiqueta para mostrar mensaje de bienvenida
initMessage: db "Bienvenido, para graficar una recta", 0Dh, 0Ah, 24h 

; Etiqueta para indicar como ingresar las coordenadas  
initMessage2: db "Ingrese las coordenadas, de entre -10 a 10", 0Dh, 0Ah, 24h 


str db  255 dup('$')  ; Almacenara el dato que el usuario va ingresando por teclado
x1 db 0               ; Almacenara el valor de X1
x2 db 0               ; Almacenara el valor de Y2
y1 db 0               ; Almacenara el valor de X1
y2 db 0               ; Almacenara el valor de Y2

; m y mDot almaceneran el valor de la pendiente, ejemplo: 1.2                     
m db 0                ; Almacenara la parte entera de la pendiente (1)
mDot db 0             ; Almacenara la parte flotante de la pendiente (2)

; 1 = -1 : 0 = 1
signY db 0            ; Almacenara el valor de del signo de X
signX db 0            ; Almacenara el valor de del signo de Y
signM db 0            ; Almacenara el valor de del signo de M (pendiente)

b db 0                ; Almacenara la parte entera de la variable B de la formula y = mx + b
bDot db 0             ; Almacenara la parte decimal de la variable B
signB db 0            ; Almacenara el signo de B

temp db 0             ; Servira como apuntador auxiliar guardando una parte entera
tempDot db 0          ; Servira como apuntador auxiliar guardando una parte decimal 
tempSign db 0         ; Servira como apuntador auxiliar guardando el signo

once db 0             ; Acumulador, para verificar si la recta ya paso por el cero

calculateB db 1       ; Sirve para verificar si es necesario calcular la B
currentCoord dw 0     ; Coordenada actual en relacion a X y Y del plano
currentScreenCord dw 0 ; Coordenada actual en relacion a la pantalla 
isNegativeCurrentCoord db 1 ; Para verificar en que parte (positiva o negativa) estamos de eje x


atoi proc
  xor bx,bx   ;BX = 0

atoi_1:
  lodsb       ;carga byte apuntado por SI en AL e incrementa si
  cmp al,'0'  ;es numero ascii? [0-9]
  jb noascii  ;no, salir
  cmp al,'9'
  ja noascii  ;no, salir

  sub al,30h  ;ascii '0'=30h, ascii '1'=31h...etc.
  cbw         ;byte a word
  push ax
  mov ax,bx   ;BX tendra el valor final
  mov cx,10
  mul cx      ;AX=AX*10
  mov bx,ax
  pop ax
  add bx,ax
  jmp atoi_1  ;seguir mientras SI apunte a un numero ascii
  noascii:
  ret         ;BX tiene el valor final
atoi endp

;Este procedimiento sirve para graficar los ejes X y Y

drawAxes proc        
    ;mov ah, 0
    ;mov al, 18
    ;int 16 
    
    
    mov cx, 320 ; indicamos la columna para comenzar a graficar el eje Y (mitad de la pantalla horizontal)
    mov dx, 10  ; indicamos la fila para comenzar a graficar el eje Y (iniciamos en el pixel 10)
    mov al, 15  ; indicamos el color del pixel a dibujar
        
    u2:
    
        mov ah, 0ch ; cargamos la funcion, para dibujar un pixel en pantalla
        int 10h     ; ejecutamos la funcion
        
        inc dx      ; Incrementamos dx para bajar un punto 
        
        cmp dx, 470 ; Verificamos que no hemos llegado al final de la pantalla de forma vertical
        jbe u2      ; Si aun es menor la fila a al final (470), brincamos a u2 para dibujar el siguiente punto
    
    xor dx, dx      ; Limpiamos dx
    xor cx, cx      ; Limpiamos cx
    mov cx, 628     ; indicamos la columna para dibujar el eje X (mitad de la pantalla vertical)
    mov dx, 240     ; indicamos la fila para dibujar el eje X (iniciamos en el pixel 240), pixel mas a la derecha
    
    u1: 
        mov ah, 0ch ; cargamos la funcion, para dibujar un pixel en pantalla
        int 10h     ; ejecutamos la funcion
        
        dec cx      ; decrementamos la columna para dibujar el siguiente punto a la izquierda
        
        cmp cx, 10  ; verificamso que si hemos llegado al pixel 10
        jae u1      ; si aun estamos por arriba del 10 dibujams el siguiente punto
              
    ret             ; regresamos a donde fue llamado
                    
endp                ; fin procedimiento

; Este procedimiento sirve para solicitarle al usuario las coordenadas, por separado

ask proc 
        
    mov dx, mx1     ; cargamos el mensaje para solicitar X1
    mov ah, 09h     ; cargamos la funcion para imprimir
    int 21h         ; imprimimos el mensaje
    
    lea si, str     ; cargamos la direccion efectiva del apuntador que guardara lo ingresado por teclado
    mov cx, 3       ; cargamos 3 en cx para limitar a solo 3 caracteres por entrada
    
    askForx1:
        mov ah, 1   ; cargamos la funcion echo para leer de teclado
        int 21h     ; ejecutamos la funcion 
        
        cmp al, 2Dh ; Verificamos si lo ingresado es un guion indicando el signo
        je saveSignX1 ; Si es un signo bricamos  
        
        cmp al, 13    ; Verificamos si lo ingresado es enter
        je breakX1    ; si es asi salimos el ciclo
        
        mov [si], al  ; Cargamos el nuevo caracter en el buffer
        inc si        ; incremtamos el apuntador
        
    continueloopX1:
        loop askForx1 
    
    saveSignX1:        ; Etiqueta para almacenar el signo de X1
        mov signX, 1   ; Actualizamos el valor de signX para indicar que X1 es negativo 
        lea si, str    ; regresamos el apuntador al inicio del buffer 
        jmp continueloopX1 ; regresamos al ciclo
        
        
    breakX1:           ; Etiqueta para romper el ciclo
        call newLine   ; imprimimos una nueva linea
        
        lea si, str    ; retornamos el apuntador al inicio del buffer
        call atoi      ; convertimos el numero ingresado de ASCII a Entero
        
        
        
        mov dx, my1    ; cargamos el mensaje para solicitar X1 
        mov ah, 09h    ; cargamos la funcion para imprimir
        int 21h        ; imprimimos el mensaje
        
        mov x1, bl     ; guardamos el valor ingresado 
        lea si, str    ; regresamos el apuntador al inicio del buffer
        
        mov cx, 3      ; cargamos 3 en cx para el siguiente ciclo
        
        cmp signX, 1   ; Verificamos si se ingreso un signo
        jne askForY1   ; si no es preguntamos por Y1
        
        mov al, bl     ; movemos el nuevo valor a al
        mov bl, -1     ; cargamos un -1 en bl para hacer negativa la nueva x1
        imul bl        ; multiplicamos considerando el signo
        xchg al, bl    ; intercambiamos el valor entre al y bl
        
        mov x1, bl     ; guardamos el resultado 
        lea si, str    ; regresamos el apuntador al inicio del buffer
                            
    
    askForY1:
    
        mov signX, 0   ; cambiamos el valor del signo
    
        mov ah, 1      ; cargamos la funcion echo para leer de teclado
        int 21h        ; ejecutamos la funcion 
        
        cmp al, 2Dh    ; Verificamos si lo ingresado es un guion indicando el signo
        je saveSignY1  ; Si es un signo bricamos 
        
        cmp al, 13     ; Verificamos si lo ingresado es enter
        je breakY1     ; si es asi salimos el ciclo
        
        mov [si], al   ; guardamos el nuevo valor
        inc si         ; incrementamos el apuntador
        
    continueloopY1:
        loop askForY1 
    
    saveSignY1:             ; Etiqueta para almacenar el signo de X1
        mov signY, 1        ; cambiamos el valor del signY
        lea si, str         ; regresamos el apuntador al inicio del buffer
        jmp continueloopY1  ; regresamos al ciclo
        
        
    breakY1:    
        call newLine        ; imprimimos un salto de linea
        
        lea si, str         ; regresamos el apuntador al inicio del buffer
        call atoi           ; convertimos el valor de ASCII a Entero
        
        mov cx, 3           ; cargamos 3 para el nuevo ciclo
         
        mov dx, mx2         ; cargamos el siguiente mensaje para solicitar x2
        mov ah, 09h         ; cargamos la funcion para imprimir
        int 21h             ; imprimimos el mensaje
        
        mov y1, bl          ; Movemos el nuevo valor a y1
        
        lea si, str         ; regresamos el apuntador al inicio del buffer
        
        cmp signY, 1        ; comparamos si Y es negativa
        jne askForX2        ; si no es igual saltamos para solicitar Y1
        
        mov al, bl          ; cargamos el valor de y1 a al
        mov bl, -1          ; cargamos un -1
        imul bl             ; multiplicamos considerando el nuevo signo para hacer negativa a y1
        xchg al, bl         ; intercambiamos el valor 
        
        mov y1, bl          ; guardamos y1
        
        lea si, str         ; regresamos el apuntador al inicio del buffer
        
    
    
    askForX2:
    
        mov signY, 0        ; reiniciamos el valor del signo de y
    
        mov ah, 1           ; cargamos la funcion echo
        int 21h             ; ejecutamos la funcion echo
        
        cmp al, 2Dh         ; verificamos si lo ingresado es un signo
        je saveSignX2       ; si es un signo saltamos para guardarlo
        
        cmp al, 13          ; verificamos si es un enter
        je breakX2          ; si es asi rompemos el ciclo
        
        mov [si], al        ; guardamos el valor en el buffer
        inc si              ; incrementamos el valor del apuntador
        
    continueloopX2:
        loop askForx2 
    
    saveSignX2:             ; Etiqueta para almacenar el signo
        mov signX, 1        ; actualizamos el valor del signo de x 
        lea si, str         ; regresamos el apuntador al inicio del buffer
        jmp continueloopX2  ; regresamos al ciclo
        
        
    breakX2:    
        call newLine        ; imprimimos un salto de linea
        
        lea si, str         ; regresamos el apuntador al inicio del buffer
        call atoi           ; convertimos el valor de ASCII a entero
        
        mov cx, 3           ; reiniciamos el cilo
        
        mov dx, my2         ; imprimimos el mensaje para y2
        mov ah, 09h         ; cargamos la funcion para imprimir
        int 21h             ; imprimimos el mensaje
        
        mov x2, bl          ; guardamos el valor de x2
        
        cmp signX, 1        ; comparamos si hay signo 
        jne askForY2        ; si no brincamos para solicitar x2
        
        mov al, bl          ; cambiamos el valor de x2 a bl
        mov bl, -1          ; cargamos un -1 para hacer negativa a x2
        imul bl             ; multiplicamos considerando el signo
        xchg al, bl         ; intercambiamos valores
        
        mov x2, bl          ; guardamos el valor el valor de x2
        
    askForY2:    
    
        mov ah, 1           ; cargamos la funcion para leer de teclado
        int 21h             ; ejecutamos la funcion
        
        cmp al, 2Dh         ; verificamos si es un guion
        je saveSignY2       ; si es un guion saltamos
        
        cmp al, 13          ; comparamos para saber si se ingreso un enter
        je breakY2          ; si es un enter rompemos el ciclo
        
        mov [si], al        ; cargamos el valor en el buffer
        inc si              ; incrementamos el apuntador
        
    continueloopY2:
        loop askForY2 
                             
    saveSignY2:             ; Etiqueta para almancenar el signo de y2
        mov signY, 1        ; actualizamos el valor del signo
        lea si, str         ; regresamos el apuntador al inicio del buffer
        jmp continueloopY2  ; regresamos al ciclo
        
        
    breakY2:    
        call newLine        ; Imprimimos una nueva linea
        
        lea si, str         ; regresamos el apuntador al inicio del buffer
        call atoi           ; convertimos el valor de ASCII a Entero
        
        mov y2, bl          ; guardamos el nuevo valor de y2
        
        lea si, str         ; regresamos el apuntador al inicio del buffer  
        
        cmp signY, 1        ; verifiamos si la y2 ingresada es negativa
        jne endAsk          ; si no es salimos del procedimiento
        
        mov al, bl          ; guardamos el nuevo valor en al
        mov bl, -1          ; cargamos un -1 para hacer negativa a y2
        imul bl             ; multiplicamos considierando el signo
        xchg al, bl         ; intercambiamos el valor 
        
        mov y2, bl          ; guardamos el valor en y2
        
        lea si, str         ; regresamso el apuntador  al inicio del buffer
    
endAsk: 
    mov signX, 0            ; reiniciamos el valor del signo de X
    mov signY, 0            ; reiniciamos el valor del signo de Y
    
endp

newline proc

    mov dl, 10
    mov ah, 02h
    int 21h
    mov dl, 13
    mov ah, 02h
    int 21h
    
    
    ret
    
endp
   
read proc
    
    mov cx, 4
    
    init:
          
          mov ah,01h  
          INT 21H
          
          CMP AL, 0Dh ;;;;;;;;;;;cariage return = 0dh   
          JE terminate 
          
          MOV [SI],AL
          INC SI
            
          cmp cx, 0
          je terminate  
          
          dec cx
          
          jmp init
    
    terminate:
    ret
         
endp 


pending proc
    
    ;mov x1, -5
    ;mov y1, 4
    
    ;mov x2, 1
    ;mov y2, -2
    
    mov al, x1
    mov ah, x2
    
    cmp al, ah
    je equalX 
    
    mov al, y1
    mov ah, y2
    
    cmp al, ah
    je equalY
    
    ;mov al, y1
    ;mov ah, y2
    sub ah, al 
    
    js signOfY
    mov bl, ah
    
    
    continue: 
           
           mov al, x1
           mov ah, x2
           sub ah, al
           
           js signOfX
           mov dl, ah 
             
           calc: 
                   ;xchg bl, dl 
                   mov al, bl
                   
                   xor ah, ah
                   
                   div dl    ; residuo ah resultado al
                   mov bh, ah
                   
                   mov m, al
                   
                   xor ax, ax
                   mov al, 10
                   mul bh
                   
                   div dl
                   mov mDot, al
           
           
           
           jmp sigOfM
           
    equalX:
    
        call changeNegativeValueOfX
        
        mov calculateB, 0
        
        mov al, x1
        mov b, al
        mov bDot, 0
        mov m, 0
        mov mDot, 0
        
        jmp return
            
    equalY:
    
        call changeNegativeValueOfY
        
        mov calculateB, 0
        
        mov al, y1
        mov b, al
        mov bDot, 0
        mov m, 0
        mov mDot, 0
        
        jmp return        
                
    
    signOfY: 
           mov al, ah
           mov cl, -1
           imul cl 
           mov bl, al
           mov signY, 1
           jmp continue
           
    signOfX: 
           mov al, ah
           mov cl, -1
           imul cl 
           mov dl, al
           mov signX, 1
           jmp calc       
            
    sigOfM:
    
          mov al, signX
          mov ah, signY
          
          cmp ah, 0
          jne comp
          
          cmp al, 0
          je equal
          
          comp: 
            test ah, al
            jz notEqual
            jnz equal
          
          equal: 
                mov signM, 0
                jmp return
          
          notEqual: mov signM, 1 
       
    return: ret
endp 

getB proc
    
    ;mov tempSign, 0
    ;mov x1, -3
    ;mov m, 0
    ;mov mDot, 2
    ;mov signM, 1
    ;mov y1, 3
    
    ;cmp x1, 0
    ;jl change
    ;jnl while
    
    ;x1 * -1
    ;change:
        ;mov tempSign, 1 
        ;mov al, x1 
        ;mov dl, -1
        ;imul dl
    
        ;mov x1, al
        
    call changeNegativeValueOfX     
    
    while:
    
        ;cmp mDot, 0
        ;je cero
    
        xor ah, ah
        mov al, x1
        mov cl, mDot 
        mul cl  
         
        cmp al, 10
        jge separate
        
        mov tempDot, al
        mov bl, m
        mov temp, bl
 
        ;jmp next            
    
          
    
    separate:
    
        xor ah, ah
        mov dl, 10
        div dl
        
        mov tempDot, ah
        mov temp, al
        
        mov al, x1 
        xor ah, ah
        mov dl, m
        mul dl
        add al, temp
        
        mov temp, al               
    
     next:
     
        ;cmp y1, 0
        ;jl changeY1
        ;jnl verify
        
        ;y1 * -1
        ;changeY1:
            ;mov signB, 1 
            ;mov al, y1 
            ;mov dl, -1
            ;imul dl
        
            ;mov y1, al
        
        cmp tempDot, 5
        ja addOneB 
        jbe isNegativeB
        
        addOneB:
            mov al, temp
            inc al 
            mov b, al
            
        isNegativeB:
        
            cmp tempSign, 1
            jne verify
            
        multB: 
        
            mov al, temp
            mov bl, -1
            imul bl
            mov b, al
            
        
            
        ;call changeNegativeValueOfY     
     
        verify:
        
            mov ah, y1
            mov al, b
            add ah, al
            mov b, ah
            
            jmp end
            
        cero:
            cmp m, 0
            je isCero
            
            mov tempDot, 0
            mov bl, x1
            mov temp, bl
            jmp next 
            
            isCero:
                call changeNegativeValueOfY 
                mov bl, y1 
                mov b, bl
                mov bDot, 0                      
     
    end: ret
endp

changeNegativeValueOfY proc
    
    cmp y1, 0
    jl changeY1
    jnl endchangeNegativeValueOfY
    
    ;y1 * -1
    changeY1:
        mov signB, 1 
        mov al, y1 
        mov dl, -1
        imul dl
    
        mov y1, al
    
    endchangeNegativeValueOfY: ret
endp

changeNegativeValueOfX proc
    
    cmp x1, 0
    jl change
    jnl endchangeNegativeValueOfX
    
    ;x1 * -1
    change:
        mov tempSign, 1 
        mov al, x1 
        mov dl, -1
        imul dl
    
        mov x1, al 
        
    endchangeNegativeValueOfX: ret    
endp    



dibujar proc
    
    mov currentCoord, 321
    mov currentScreenCord, 0
    mov isNegativeCurrentCoord, 1
    
    newPoint:
    mov al, mDot
    cbw
    mov bx, currentCoord
    mul bx
    
    mov cl, 10
    div cl
    mov cl, al ; parte entera
    mov ch, ah ; parte decimal
    
    cmp ch, 5
    ja addOne  
    
    xor ch, ch 
    
    mov al, m
    cbw
    mov bx, currentCoord
    mul bx
    
    add ax, cx
    
    jmp ecuation
    
    addOne: 
        inc al 
        mov bl, al
        mov cl, al
        mov al, m
        xor bh, bh
        cbw
        mul bx ; se queda el resultado en ax
        xor ch, ch
        mov bx, currentCoord
        add ax, cx
        
        
        
    
    ecuation:
    
        mov bl, signM
        mov bh, isNegativeCurrentCoord  
        
        ;test bl, bh
        
        cmp bl, bh
        jne multAx
        je y
        
    multAx:
    
        mov bx, -1
        imul bx 
        
    y:  
    
        mov cx, ax
        mov al, b
        cbw
        add cx, ax
        
        mov ax, -1
        imul cx
        mov dx, ax
        
        mov ax, 240 
        add ax, dx
        mov dx, ax
        
        cmp dx, 480
        jg noChange
        
        cmp dx, 0
        jl noChange
          
            
    mov cx, currentScreenCord   ; fila
    ;mov al, 1100b  ; color
    
    
    
    ;prueba:
        mov al, 0011b; 
        mov ah, 0ch
        int 10h 
    
        ;dec cx
        ;cmp cx, 0
        ;jne prueba
      
      cmp currentScreenCord, 320
      ja changeNegative
      jna noChange
      
      changeNegative:
      
      
        cmp once, 0
        je setNewValues
        ja increment
        jne noChange
        
        
        
        setNewValues:  
            mov isNegativeCurrentCoord, 0
            mov currentCoord, 1
            inc once
            jmp drawNext
            
        increment:
            inc currentCoord
            inc currentScreenCord
            jmp drawNext    
      
        
      noChange:
        inc currentScreenCord
        dec currentCoord
      
      drawNext:
      cmp currentScreenCord, 628
      jb  newPoint
          
    endDibujar: ret
    endp

main:

    lea dx,initMessage
    mov ah,09h
    int 21h
    
    lea dx,initMessage2
    mov ah,09h
    int 21h
    
    call ask
    
    call pending
    call getB 
    
    cmp calculateB, 0
    je isNotB
    
    isB: call getB
    
    isNotB:     
 
        mov ah, 0
        mov al, 18
        int 16    
        
        call drawAxes
        call dibujar

ret




