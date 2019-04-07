
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



drawAxes proc        
    mov ah, 0
    mov al, 18
    int 16 
    
    
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
    
    mov x1, -3
    mov y1, 3
    
    mov x2, 2
    mov y2, 2
    
    mov al, y1
    mov ah, y2
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
          
          test ah, al
          jz notEqual
          jnz equal
          
          equal: 
                mov signM, 0
                jmp return
          
          notEqual: mov signM, 1 
       
    return: ret
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
    
    ;mov al, 1
    ;mov bl, 2
    ;div bl
    
    ;call drawAxes

ret




