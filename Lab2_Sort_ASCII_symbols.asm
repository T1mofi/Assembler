.model small                                        ;.com programm     
    
.stack 100h                                         ;256 Byte fo stack
    
.data                                               ;data initialization
    string db 200, 0, 200 dup ('$') 
    msg_inp db 'input string: ', '$'
    msg_out db 0Ah, 0Dh, 'sort sring: ','$'
    msg_empty db 0Ah, 0Dh,'string is empty','$' 
        
.code                                               ; code segment 
    

    
    
START:    
    mov AX, @data
    mov DS, AX                                      ; set data segment pointer
                                       
INPUT:
    mov AH, 09h
    mov DL, offset msg_inp                           
    int 21h
        
    mov AH, 0Ah
    mov DX, offset string
    int 21h    
    
    size EQU string[1]
     
    cmp size, 0
    je EMPTY
    
    cmp size, 1
    je OUTPUT
    
 
SORT:     
    loop1:
        xor SI,SI
        mov SI, 2                                   ;stsrt string  
        xor CX,CX
        mov CL, size 
        dec CL
        mov DL, 1                                   ;changes flag = 1(not change)
        
        loop2:
            mov AL, string[SI]
            cmp AL, string[SI+1]
            jng nxt
            
            xchg AL, string[SI+1]
            mov string[SI], AL
            xor DL,DL                               ;changes flag = 0(change)
             
            nxt:    
            inc SI
        loop loop2
        
        or DL,DL                                    ;change or not(answer in ZF)?   
    jz loop1                                        ;iterate if changes flag = 0(change)
    
    jmp OUTPUT
    
EMPTY:
    mov AH, 09h
    mov DL, offset msg_empty                           
    int 21h
    
    jmp END           
     
OUTPUT:       
    mov AH, 09h
    mov DL, offset msg_out                           
    int 21h  
    
    mov AH, 09h
    mov DX, [(offset string)] + 2                        ;skip 2 service byte from string
    int 21h 
    
END: 

end START    
