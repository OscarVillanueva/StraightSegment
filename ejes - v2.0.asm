
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

; Este procedimiento sirve para imprimir un salto de linea \n

newline proc

    mov dl, 10              ; cargamos \r (regresamos el cursor al inicio de la linea) 
    mov ah, 02h             ; cargamos la funcion 02h para actualizar el posicion del cursor
    int 21h                 ; ejecutamos la funcion
    
    mov dl, 13              ; cargamos \n (cargamos un 13 para hacer el salto de linea) 
    mov ah, 02h             ; cargamos la funcion 02h para actualizar el posicion del cursor
    int 21h                 ; ejecutamos la funcion 
    
    
    ret
    
endp 

; Procedimiento para calcular la pendiente 
; para cualcular la formula m = (y2 - y1) / (x2 - x1)

pending proc
    
    mov al, x1    ; cargamos el valor de x1
    mov ah, x2    ; cargamos el valor de x2
    
    cmp al, ah    ; verificamos si son iguales para verificar si es una linea recta 
    je equalX     ; si son iguales saltamos a equal X
    
    mov al, y1    ; cargamos el valor de y1
    mov ah, y2    ; cargamos el valor de y2
    
    cmp al, ah    ; comparamos los valores
    je equalY     ; si son iguales saltamos
    
    sub ah, al    ; restamos y2 - y1 
    
    js signOfY    ; verificamos si la resta nos dio un valor negativo
    mov bl, ah    ; cargamos el resultado de la resta en bl
    
    
    continue: 
           
           mov al, x1           ; cargamos el valor de x1 
           mov ah, x2           ; cargamos el valor de x2
           sub ah, al           ; hacemos la resta 
           
           js signOfX           ; verificamos si nos dio como resultado un valor negativo
           mov dl, ah           ; cargamos el resultado los en dl
             
           calc: 
                   
                   mov al, bl   ; cargamos el resultado de y2 - y1 en al
                   
                   xor ah, ah   ; limpiamos ah
                   
                   div dl       ; divimos residuo ah resultado al (y2 - y1) / (x2 - x1)
                   mov bh, ah   ; cargamos el residuo en bh
                   
                   mov m, al    ; guardamos la parte entera en m
                   
                   xor ax, ax   ; limpiamos ax
                   mov al, 10   ; cargamos un 10 
                   mul bh       ; multiplicamos el residuo por 10 para sacar el decimal 
                   
                   div dl       ; dividimos por el resultado de (x2 - x1)
                   mov mDot, al ; guardamos el resultado en mDot
           
           
           
           jmp sigOfM
           
    equalX:
    
        call changeNegativeValueOfX ; procedimiento para cambiar el valor de x1
        
        mov calculateB, 0           ; actualizamos el valor de B para no calcular el b, ya que no se presentan cambios en x
        
        mov al, x1                  ; cargamos el valor de x1
        mov b, al                   ; guardamos el valor de x1 en B 
        mov bDot, 0
        mov m, 0
        mov mDot, 0
                                    ; salimos del procedimiento
        jmp return
            
    equalY:
    
        call changeNegativeValueOfY ; procedimiento para cambiar el valor de y1
        
        mov calculateB, 0           ; actualizamos el valor de B para no calcular el b, ya que no se presentan cambios en x
        
        mov al, y1                  ; cargamos el valor de y1 en al
        mov b, al                   ; guardamos en b el valor de y1 
        mov bDot, 0
        mov m, 0
        mov mDot, 0
        
        jmp return                  ; salimos del procedimineto 
                
    
    signOfY:                        ; Esta etiqueta sirve para cambiar el valor de y2 - y1 de negativo a positivo
           mov al, ah               ; cargamos el resultado de la resta en al
           mov cl, -1               ; cargamos en cl -1
           imul cl                  ; multiplicamos considerando el signo
           mov bl, al               ; movemos el resultado en bl
           mov signY, 1             ; actualizamos el valor de signY para indicar que el resultado es negativo
           jmp continue             ; regresamos a continue
                                    
    signOfX:                        ; Esta etiqueta sirve para cambiar el valor de x2 - x1 de negativo a positivo
           mov al, ah               ; cargamos el resultado de la resta en al
           mov cl, -1               ; cargamos en cl -1
           imul cl                  ; multiplicamos considerando el signo
           mov dl, al               ; movemos el resultado en bl
           mov signX, 1             ; actualizamos el valor de signX para indicar que el resultado es negativo
           jmp calc                 ; regresamos a calc
            
    sigOfM:                         ; esta etiqueta sirve para indicar el vlaor final 
    
          mov al, signX             ; cargamos el signo de X
          mov ah, signY             ; cargamos el signo de Y
          
          cmp ah, 0                 ; verificamos si ah (signX) es cero
          jne comp                  ; si no es cero nos vamos a comp
          
          cmp al, 0                 ; verificamos si ah (signY) es cero 
          je equal                  ; si son iguales nos vamos a iguales
          
          comp:                     ; verificamos si son iguales 
            test ah, al             ; si no son iguales nos vamos a notEqual
            jz notEqual             ; si son iguales a equal
            jnz equal
          
          equal:                    
                mov signM, 0        ; indicamos que el signo de la pendiente es 0 (positiva)
                jmp return          ; salimos del procedimiento
          
          notEqual: mov signM, 1    ; indicamos que el signo de la pendiente es 1 (negativa)
       
    return: ret
endp

; Procedimeinto para calulcar el valor de la equacion y = mx + b 

getB proc
        
    call changeNegativeValueOfX   ; Procedimiento para cambiar el valor de x de negativo a positivo  
    
    while:
    
        xor ah, ah                ; limpiamos el registro ah
        mov al, x1                ; cargamos el valor de x1 
        mov cl, mDot              ; cargamos el valor decimal de m (mDot)
        mul cl                    ; multiplicamos 
         
        cmp al, 10                ; si el resultado de la division es mayor a 10 
        jge separate              ; si es superior saltamos a separate
        
        mov tempDot, al           ; guardamos el resultado de la multiplicacion 
        mov bl, m                 ; cargamos el valor de m (parte entera en) 
        mov temp, bl              ; guardamos el valor de m en nuestra variable auxiliar
                                   
          
    
    separate:
    
        xor ah, ah                ; limipiamos el registro ah  
        mov dl, 10                ; cargamos un 10 en dl
        div dl                    ; dividimos el valor el resultado de la multiplicacion mDot * x1
        
        mov tempDot, ah           ; guardamos el residuo en tempDot
        mov temp, al              ; guardamos el resultado en temp
        
        mov al, x1                ; cargamos el valor de x1
        xor ah, ah                ; limpiamos el valor del registro de ah
        mov dl, m                 ; cargamos el valor de la parte entera de la pendiente
        mul dl                    ; hacemos la multiplicacion
        add al, temp
        
        mov temp, al              ; y le sumamos el resultado al resultado de la division previa 
    
     next:                        ; esta etiqueta nos sirve para redondear el valor de B
        
        cmp tempDot, 5            ; si es valor decimal es mayor a 5
        ja addOneB                ; ei es mayor brincamos a addOneB
        jbe isNegativeB           ; si no es brincamos a isNegativeB
        
        addOneB:
            mov al, temp          ; cargamos la parte entera de la b temporal
            inc al                ; y le agregamos uno 
            mov b, al             ; cargamos el valor final en b
            
        isNegativeB:
        
            cmp tempSign, 1       ; verificamos si tempSign si es 1 (este valor cambia en changeNegativeValueOfX)
            jne verify            ; si no esta en 1 saltamos a verify
            
        multB: 
        
            mov al, temp          ; cargamos el valor 
            mov bl, -1            ; cargamos un -1
            imul bl               ; multiplicamos considuerando el signo
            mov b, al             ; guardamos el resultado en b
            
                                     
        verify:
        
            mov ah, y1            ; cargamos el valor de y1 
            mov al, b             ; cargamos el valor de b
            add ah, al            ; hacemos la suma
            mov b, ah             ; cargamos en B el resultado
            
            jmp end
            
                              
     
    end: ret
endp

; Este procedimiento sirve para cambiar el valor de y1 de negativo a positivo

changeNegativeValueOfY proc
    
    cmp y1, 0                       ; comprobamos si es un valor negativo
    jl changeY1                     ; si es negativo brincamos a changeY1
    jnl endchangeNegativeValueOfY   ; si no  salimos el procedimiento
    
    ;y1 * -1
    changeY1:
        mov signB, 1                ; cambiamos el valor de signB a uno para indicar que se hizo el cambio
        mov al, y1 
        mov dl, -1
        imul dl
    
        mov y1, al
    
    endchangeNegativeValueOfY: ret
endp
    
; Este procedimiento sirve para cambiar el valor de x1 de negativo a positivo    
    
changeNegativeValueOfX proc
    
    cmp x1, 0                      ; comprobamos si es un valor negativo
    jl change                      ; si es negativo brincamos a changeX1
    jnl endchangeNegativeValueOfX  ; si no  salimos el procedimiento
    
    ;x1 * -1
    change:
        mov tempSign, 1 
        mov al, x1 
        mov dl, -1
        imul dl
    
        mov x1, al 
        
    endchangeNegativeValueOfX: ret    
endp    

; Este procedimiento sirve para dibujar los puntos de la recta en pantalla 
; sustituyendo los valores previos en la formula y = mx + b 

; Pantalla
; ------------------------------------------------------------
; |                             0px                          |
; |                                                          |
; |                                                          |
; |                                                          |
; |                                                          |
; |                                                          |
; |                                                          |
; |                                                          |
; |                                                          |
; |-321                         0                         321|
; |0px                                                  628px|
; |                                                          |
; |                                                          |
; |                                                          |
; |                                                          |
; |                                                          |
; |                                                          |
; |                                                          |
; |                                                          |
; |                                                          |
; |                                                          |
; |                             480px                        |
; |----------------------------------------------------------|

dibujar proc
    
    mov currentCoord, 321          ; coordenada actual en relacion al plano
    mov currentScreenCord, 0       ; coordenada actual en relacion a la pantalla
    mov isNegativeCurrentCoord, 1  ; marcamos que vamos por el lado negativo de x
    
    newPoint:
    mov al, mDot                   ; cargamos la parte decimal de la pendiente
    cbw                            ; cambiamos de 8 bit a 16 bits el valor de ax
    mov bx, currentCoord           ; cargamos el valor de currentCoord
    mul bx                         ; multiplicamos por el la parte decimal
    
    mov cl, 10                     ; cargamos un 10 en cl
    div cl                         ; dividimos por 10 el resultado de la multiplicacion
    mov cl, al                     ; parte entera de la division (resultado)
    mov ch, ah                     ; parte decimal de la division (residuo)
    
    cmp ch, 5                      ; verificamos si el punto decimal es mayor a 5 para redondear
    ja addOne                      ; si es mayor brincamos a addOne
    
    xor ch, ch                     ; limpiamos la parte alta de ch
    
    mov al, m                      ; cargamos la parte entera de la pendiente 
    cbw                            ; cambiamos de 8 bit a 16 bits el valor de ax 
    mov bx, currentCoord           ; cargamos el valor de la posicion en x en bx
    mul bx                         ; multiplicamos por ax
    
    add ax, cx                     ; sumamos el acarreo o el resultado de la multiplicacion previa de currentCoord con mDot
    
    jmp ecuation                   ; saltamos a la sustitucion
    
    addOne: 
        inc al                     ; aumentamos en una unidad la parte entera por el redondeo
        mov bl, al                 ; movemos la parte entera a bl
        mov cl, al                 ; movemos la parte entera a bl
        mov al, m                  ; cargamos en al la parte entera de m
        xor bh, bh                 ; limpiamos la parte alta del registro bx
        cbw                        ; cambiamos de 8 bit a 16 bits el valor de ax
        mul bx                     ; se queda el resultado en ax
        xor ch, ch                 ; limpiamos la parte alta del registro cx
        mov bx, currentCoord       ; cargamos el valor de la coordenada actual en bx
        add ax, cx                 ; sumamos el incremento al resultado de la multiplicacion 
        
        
        
    
    ecuation:
    
        mov bl, signM                  ; movemos en bl el signo de la pendiente 
        mov bh, isNegativeCurrentCoord ; movemos en bh el signo de la coordenada actual 
        
        cmp bl, bh                     ; comparamos si son iguales
        jne multAx                     ; si no son iguales nos vamos a multAx
        je y                           ; si son iguales brincamos a y
        
    multAx:
                                       
        mov bx, -1                     ; cargamos en bx un -1
        imul bx                        ; multiplicamos considerando el signo
        
    y:  
    
        mov cx, ax                     ; movemos a cx el resultado de m * x
        mov al, b                      ; movemos a al el valor de b
        cbw                            ; cambiamos de 8 bit a 16 bits el valor de ax
        add cx, ax                     ; hacemos la suma mx + b
        
        mov ax, -1                     ; movemos a ax -1
        imul cx                        ; multiplicamos -(mx + b)
        mov dx, ax                     ; movemos el resultado a dx
                                        
        mov ax, 240                    ; cargamos la posicion del eje y en relacion a la pantalla en ax
        add ax, dx                     ; sumamos 240 + -(mx + b)
        mov dx, ax                     ; movemos a dx (fila) 
        
        cmp dx, 480                    ; si la fila es mayor 480
        jg noChange                    ; si es superior brincamos a noChange
        
        cmp dx, 0                      ; si la fila es menor a 0
        jl noChange                    ; brincamos a noChange
          
            
    mov cx, currentScreenCord          ; cargamos en cx (fila) la coordenada Actual de la pantalla
     

    mov al, 0011b                      ; indicamos el color cyan en el sistema de colores del 8086 
    mov ah, 0ch                        ; cargamos la funcion para dibujar un pixel
    int 10h                            ; ejecutamos
      
    cmp currentScreenCord, 320         ; comprobamos si currentScreenCord cruzo el eje Y
    ja changeNegative                  ; si ya cruzo brincamos a changeNegative
    jna noChange                       ; si aun no cruza nos vamos a noChange
  
    changeNegative:
  
        cmp once, 0                    ; verificamos que sea la primera vez que llegamos aqui
        je setNewValues                ; si es la primera vez brincamos a setNewValues
        ja increment                   ; si es no es la primera vez pero ya a llegado al menos una vez brincamos a increment
        jne noChange                   ; si no nos vamos a noChange

    setNewValues:  
        mov isNegativeCurrentCoord, 0  ; indicamos que ya estamos en el lado positivos de las x positivas
        mov currentCoord, 1            ; cambiamos la coordenada actual a 1 
        inc once                       ; aumentamos one para indicar que ya se llego una vez
        jmp drawNext                   ; brincamos a drawNext
        
    increment:
        inc currentCoord               ; incrementamos en uno la coordenada Actual en relacion al plano
        inc currentScreenCord          ; incrementamos en uno la coordenada Actual en relacion a la pantalla
        jmp drawNext                   ; brincamos a drawNext
  
    
    noChange:
        inc currentScreenCord          ; incrementamos en uno la coordenada Actual en relacion a la pantalla 
        dec currentCoord               ; decrementamos en uno la coordenada actual en relacion al plano
  
    drawNext:
        cmp currentScreenCord, 628     ; comprobamos si currentScreenCord es 628
        jb  newPoint                   ; si aun esta por debajo brincamos a dibujar el siguiente pixel
          
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




