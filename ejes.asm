
; You may customize this and other start-up templates; 
; The location of this template is c:\emu8086\inc\0_com_template.txt

org 100h

jmp main 

mx1: db "Ingresa x1", 0Dh, 0Ah, 24h 
my1: db "Ingresa y1", 0Dh, 0Ah, 24h

mx2: db "Ingresa x2", 0Dh, 0Ah, 24h 
my2: db "Ingresa y2", 0Dh, 0Ah, 24h


;Variables
MSG2 DB 13,10, ' YOUR STRING IS  :-----> :  $'
valX1 db 4 dup
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
    
    mov dx, my1
    mov ah, 09h
    int 21h
    
    mov dx, mx2
    mov ah, 09h
    int 21h
    
    mov dx, my2
    mov ah, 09h
    int 21h      
            
    lea si,str        
    
    call read
    
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
    
    mov x1, -5
    mov y1, 4
    
    mov x2, 2
    mov y2, -3
    
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
    
        cmp mDot, 0
        je cero
    
        xor ah, ah
        mov al, x1
        mov cl, mDot 
        mul cl  
         
        cmp al, 10
        jge separate
        
        mov tempDot, al
        mov bl, m
        mov temp, bl 
          
        jmp next            
    
          
    
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
            
        call changeNegativeValueOfY     
     
        verify: 
            mov bl, y1
            mov ch, temp
            mov cl, tempDot
            
            mov ah, tempSign
            mov al, signM 
            
            test ah, al
            jz notEqualSign
            jnz equalSign
      
        equalSign:
        
            mov ah, temp
            mov al, y1
        
            cmp ah, al
            jg mayor
            jng less
            je equalValue
        
            mayor:
                mov signB, 1
                
                mov ah, tempDot
                mov bDot, ah
                
                mov dl, temp
                sub dl, y1
                mov b, dl
                
                jmp end
            
            equalValue: 
                mov b, 0
                mov bDot, 0
                jmp end
            
            less:
                mov bDot, 0
                cmp cl, 0
                jne subs
                je subsNormal
                 
                subs: 
                    mov dl, 10 
                    sub dl, cl
                    mov bDot, dl
                    sub bl, 1
                    
                subsNormal:    
                    sub bl, temp
                
                    mov b, bl
                
                jmp end 
      
        notEqualSign:
        
            cmp signB, 1
            je less 
                      
            mov bDot, cl
            add bl, temp
            mov b, bl
        
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
    
    mov currentCoord, 320
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
        mov al, m
        cbw
        mul bx ; se queda el resultado en ax
        
        mov bx, currentCoord
        add ax, bx
        
        
        
    
    ecuation:
    
        mov bl, signM
        mov bh, isNegativeCurrentCoord  
    
        test bl, bh
        jz multAx
        jnz y
        
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
        
        mov ax, 320 
        add ax, dx
        mov dx, ax
          
            
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
          
    ret
    endp

main:
    
    ;call ask 
    
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
            
        cmp bDot, 5
        ja addOneB 
        jbe isNegativeB
        
        addOneB:
            mov al, b
            inc al 
            mov b, al
            
        isNegativeB:
        
            cmp signB, 1
            jne continueDraw
            
        multB: 
        
            mov al, b
            mov bl, -1
            imul bl
            mov b, al
            
            
        continueDraw:
        
    
 
        mov ah, 0
        mov al, 18
        int 16    
        
        call drawAxes
        call dibujar

ret




