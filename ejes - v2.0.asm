
; You may customize this and other start-up templates; 
; The location of this template is c:\emu8086\inc\0_com_template.txt

org 100h

jmp main 

mx1: db "Ingresa x1", 0Dh, 0Ah, 24h 
my1: db "Ingresa y1", 0Dh, 0Ah, 24h

mx2: db "Ingresa x2", 0Dh, 0Ah, 24h 
my2: db "Ingresa y2", 0Dh, 0Ah, 24h


;Variables
;MSG2 DB 13,10, ' YOUR STRING IS  :-----> :  $'
;valX1 db 4 dup
str db  255 dup('$')
x1 db 0
x2 db 0
y1 db 0
y2 db 0
 
m db 0
mDot db 0

signY db 0  ; 1 = -1 : 0 = 1
signX db 0
signM db 0

b db 0
bDot db 0
signB db 0

temp db 0
tempDot db 0 
tempSign db 0 

once db 0

calculateB db 1
currentCoord dw 0  
currentScreenCord dw 0 
isNegativeCurrentCoord db 1 ; para que el se va generando
 
;tempCoord dw 0
;tempCoordDot dw 0 
;isNegativeCoord db 1 ; Para el 230

;plus dw 0
;plusDot dw 0

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


drawAxes proc        
    ;mov ah, 0
    ;mov al, 18
    ;int 16 
    
    
    mov cx, 320 ; columna
    mov dx, 10   ; fila
    mov al, 15  ; color        
        
    u2:
    
        mov ah, 0ch
        int 10h 
        
        inc dx
        
        cmp dx, 470
        jbe u2    
    
    xor dx, dx
    xor cx, cx
    mov cx, 628 ; columna
    mov dx, 240 ; row
    
    u1: 
        mov ah, 0ch
        int 10h
        
        dec cx
        
        cmp cx, 10
        jae u1
              
    ret      
    
endp

ask proc 
        
    mov dx, mx1
    mov ah, 09h
    int 21h
    
    lea si, str
    mov cx, 3
    
    askForx1:
        mov ah, 1
        int 21h 
        
        cmp al, 2Dh
        je saveSignX1
        
        cmp al, 13
        je breakX1
        
        mov [si], al
        inc si
        
    continueloopX1:
        loop askForx1 
    
    saveSignX1:
        mov signX, 1
        lea si, str
        jmp continueloopX1
        
        
    breakX1:    
        call newLine
        
        lea si, str
        call atoi
        
        
        
        mov dx, my1
        mov ah, 09h
        int 21h
        
        mov x1, bl
        lea si, str
        
        cmp signX, 1
        jne askForY1
        
        mov al, bl
        mov bl, -1
        imul bl
        xchg al, bl
        
        mov x1, bl
        lea si, str    
                            
    
    askForY1:
    
        mov signX, 0
    
        mov ah, 1
        int 21h 
        
        cmp al, 2Dh
        je saveSignY1
        
        cmp al, 13
        je breakY1
        
        mov [si], al
        inc si
        
    continueloopY1:
        loop askForY1 
    
    saveSignY1:
        mov signY, 1
        lea si, str
        jmp continueloopY1
        
        
    breakY1:    
        call newLine
        
        lea si, str
        call atoi
        
        cmp signY, 1
        
        mov dx, mx2
        mov ah, 09h
        int 21h
        
        mov y1, bl
        
        lea si, str
        
        jne askForX2
        
        mov al, bl
        mov bl, -1
        imul bl
        xchg al, bl
        
        mov y1, bl
        
        lea si, str
        
    
    
    askForX2:
    
        mov signY, 0
    
        mov ah, 1
        int 21h 
        
        cmp al, 2Dh
        je saveSignX2
        
        cmp al, 13
        je breakX2
        
        mov [si], al
        inc si
        
    continueloopX2:
        loop askForx2 
    
    saveSignX2:
        mov signX, 1
        lea si, str
        jmp continueloopX2
        
        
    breakX2:    
        call newLine
        
        lea si, str
        call atoi
        
        cmp signX, 1
        
        mov dx, my2
        mov ah, 09h
        int 21h
        
        mov x2, bl
        
        jne askForY2
        
        mov al, bl
        mov bl, -1
        imul bl
        xchg al, bl
        
        mov x2, bl
        
    askForY2:    
    
        mov ah, 1
        int 21h 
        
        cmp al, 2Dh
        je saveSignY2
        
        cmp al, 13
        je breakY2
        
        mov [si], al
        inc si
        
    continueloopY2:
        loop askForY2 
    
    saveSignY2:
        mov signY, 1
        lea si, str
        jmp continueloopY2
        
        
    breakY2:    
        call newLine
        
        lea si, str
        call atoi
        
        cmp signY, 1
        
        mov y2, bl
        
        lea si, str 
        
        jne endAsk
        
        mov al, bl
        mov bl, -1
        imul bl
        xchg al, bl
        
        mov y2, bl
        
        lea si, str
    
endAsk: 
    mov signX, 0
    mov signY, 0
    
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
    
    call ask 
    
    ;LEA DX,MSG2
    ;MOV AH,09H
    ;INT 21H

    ;LEA DX,str
    ;MOV AH,09H
    ;INT 21H
    
    call pending
    call getB 
    
    cmp calculateB, 0
    je isNotB
    
    isB: call getB
    
    ;mov al, 1
    ;mov bl, 2
    ;div bl
    
    isNotB:
            
            
            
        continueDraw:
 
        mov ah, 0
        mov al, 18
        int 16    
        
        call drawAxes
        call dibujar

ret




