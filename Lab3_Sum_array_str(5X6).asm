.model small                                                    
    
.stack 100h                                                     ; 256B fo stack
   
.data
    msg_inp    db 0Dh, 0Ah, 'Input array: ', '$'
    msg_result db 0Dh, 0Ah, 'Result: ', '$'
    msg_col    db 0Dh, 0Ah, 'Columns: ', '$'
    msg_row    db 0Dh, 0Ah, 'Rows: ', '$' 
    msg_invld  db 0Dh, 0Ah, 'Incorrectly, Enter again. ', '$' 
    msg_overfl db 0Dh, 0Ah, 'Overflow! Enter again. ', '$'
    msg_sum_of db 0Dh, 0Ah, 'OFS', '$'
    endl       db 0Dh, 0Ah, '$'
    
    columns    db 0
    rows       db 0
    
    number     db 7, 0, 7 dup ('$')
                  
    array      dw 30 dup (0)
    result     dw 6 dup (0)            
     
.code

START:     
    mov   AX, @data                                 ; SET DATA SEGMENT
    mov   DS, AX                                    ; 

    quantityCols:
        mov   AH, 09h            
        lea   DX, msg_col        
        int   21h                
           
        xor   AX, AX                                ; Read one symbol(result in AL)
        mov   AH, 01h                               ; 
        int   21h                                   ;
   
        mov   AH, 0                                 ; !< 1 && !>5               
        cmp   AL, '1'                               ;
        jl    inp_col_error                         ;
        cmp   AL, '5'                               ;
        jg    inp_col_error            
   
        and   AX, 0Fh                               ; char to int(AX -= 48)
        mov   columns, AL                           ; 
        jmp   quantityRows                          ; 
   
    inp_col_error:                                  ; error of input                     ;
        mov   AH, 09h            
        lea   DX, msg_invld       
        int   21h                
        jmp   quantityCols          
   
    quantityRows:
        mov   AH, 09h            
        lea   DX, msg_row       
        int   21h                
           
        xor   AX, AX                                ; read one sumbol(result in AL)
        mov   AH, 01h                               ; 
        int   21h                                   ; 
   
        mov   AH, 0                                 ; !< 1 && !>6
        cmp   AL, '1'                               ;   
        jl    hrerror                               ;   
        cmp   AL, '6'                               ;       
        jg    hrerror                               ; 
   
        and   AX, 0Fh                               ; char to int(AX -= 48)
        mov   rows, AL                              ; 
        jmp   INPUT_ARRAY                           ;   

    hrerror:                                        ; error of input                    ;
        mov   AH, 09h                               ;
        lea   DX, msg_invld                         ;
        int   21h                                   ;
        jmp   quantityRows                          ; 
                                           
                                                                  

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;   
INPUT_ARRAY:
    mov   AH, 09h            
    lea   DX, msg_inp       
    int   21h                
   
    xor   CX, CX             
    mov   CL, rows           
    xor   SI, SI                                                  
      
    loop1:                      
        push  CX                
                            
        mov   AH, 09h                               ;   cout << endl
        lea   DX, endl                              ;
        int   21h                                   ;
                            
        xor   CX, CX            
        mov   CL, columns       
                            
        loop2:                    
            call  get_number                        ; AX get_number() 
            mov   array[SI], AX                     ;
            add   SI, 2                             ;

            mov   AH, 09h                           ; cout << endl;
            lea   DX, endl                          ;
            int   21h                               ;
                                  
        loop  loop2
                                 
        pop   CX                      
    loop  loop1                         
                                                                                     
   

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;   
SUM:
    xor   CX, CX             
    mov   CL, rows                                  ; CL = rows
    xor   SI, SI             
    xor   DI, DI             

    sum_loop1:                                     
        push  CX                 
        xor   CX, CX             
        mov   CL, columns        
                            
        sum_loop2:                                     
            mov   AX, array[SI]                     ; AX = array[SI]
            add   result[DI], AX                    ; result[DI] += AX
                jo    sum_error                     ; ? OF==1 (overflow flag) - set sum in row = 0        
                
            add   SI, 2                 
        loop  sum_loop2 
        
        out_row_sum:
            mov  AX, result[DI]      
            call OutInt
                                                    
        to_next_row:
            mov  AH, 02h                            ; print ' '
            mov  DL, ' '                            ;
            int 21h                                 ;
                    
            pop   CX                 
            add   DI, 2
    loop  sum_loop1
             
    jmp exit                 
   
    sum_error:
        mov   AX, 2                                 ; move SI to next row
        mul   CX                                    ;  
        add   SI, AX                                ;
        
        mov   AH, 09h            
        lea   DX, msg_sum_of        
        int   21h
          
        jmp  to_next_row                                                                                                                                                               
           
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;          
get_number proc          
    push  CX                        
    push  BX                        
    push  SI                        
    push  DI                        
    
    num_inp:                         
        mov   AH, 0Ah                               ; input number     
        lea   DX, number                            ; 
        int   21h                                   ; 
      
    check:                                
        xor   CX, CX              
        mov   CL, number[1]                         ; CL = len of string with number
        cmp   CX, 0                                 ; string not empty                                   !!!!!!!
            jle   inp_num_err                       ; 
   
        mov   SI, 2                                 ; 2(start real string index)
        mov   AH, 00h                                
        mov   AL, number[SI]                         
        
        cmp   AL, '-'                               ; sting != "-"
            jne   check_loop                        ;
        cmp   CL, 1                                 ;  
            jle   inp_num_err                       ;
            
        inc   SI                                                    
        dec   CX
                                 
    check_loop:                                     
        mov   AL, number[SI]                        ; > 0 && < 9
        cmp   AL, '0'                               ;
        jl    inp_num_err                           ;   
        cmp   AL, '9'                               ;      
        jg    inp_num_err                           ;
        inc   SI                                      
    loop check_loop               
    jmp   converting              

    inp_num_err:                    
        mov   AH, 09h                                                       
        lea   DX, msg_invld        
        int   21h                 
        jmp   num_inp            
                             

    converting:                                     ; convert string to int                          
        xor   CX, CX                                
        mov   CL, number[1]                         ; real string len
        
        mov   SI, CX                                ; set on last sumbol of sting                           
        inc   SI                                    ; 
        
        xor   BX, BX                                                                
        mov   DX, 1                                 ; DX = 1 - discharge multiplier
        push  DX                                    
        xor   AX, AX                                ; value of discharge
                                   
        converting_loop:              
            mov   AL, number[SI]      
            cmp   AL, '-'                   
                je    to_neg
                              
            and   AX, 0Fh                           ; char to int(-48)
    
            mul   DX                                ; AX *= DX, DX=0
            pop   DX                  
                jo    overflow                      ; ? OF==1 goto overflow (overflow flag)
   
            add   BX, AX                            ; BX +=AX
                js    overflow                      ; ? SF==1 goto overflow (sign flag)
                jo    overflow                      ; ? OF==1 goto overflow (overflow flag) 
   
            cmp   SI, 02h                           
                je    end_get              
   
            mov   AX, 10                            
            mul   DX                                ; AX *= DX 
                jo    overflow                      ; ? OF==1 goto overflow (overflow flag)
   
            xchg  DX, AX                            
            push  DX                  
            dec   SI                
        loop  converting_loop     
        jmp   end_get             
                            
    to_neg:                      
        pop   DX                   
        neg   BX                                    ; BX = -BX conversion to reverse code
            jo    overflow                          ; ? OF==1 goto overflow (overflow flag)
            jmp   end_get            

    overflow:                    
        mov   AH, 09h             
        lea   DX, msg_overfl       
        int   21h                 
        jmp   num_inp            

    end_get:                     
        mov   AX, BX                                ; result to AX  
        
        pop   DI                                    ; recover DI, SI, BX. CX
        pop   SI                                    ;
        pop   BX                                    ;
        pop   CX                                    ;
        ret
                              
get_number endp           
   

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
 
 
OutInt proc                                         ;void output_int(AX = intNumber)
                             
    push CX                   
    test AX, AX                                     ; if (AX>=0)
        jns  oi1               
                             
    mov  BX, AX              
    mov  AH, 02h             
    mov  DL, '-'             
    int  21h                 
    mov  AX, BX              
    neg  AX                                         ; AX = -AX
    
    oi1:                         
        xor  CX, CX              
        mov  BX, 10
                      
        oi2:                         
            xor  DX,DX               
            div  BX                                 ;  AX /= BX, DX = AX % BX
            push DX                  
            inc  CX                  
            test AX, AX               
                jnz  oi2 
                                
            mov  AH, 02h 
                        
        oi3:                         
            pop  DX                   
            add  DL, '0'                            ;  DL += (48) - char to int
            int  21h                 
        loop oi3                 
    
    pop  CX                  
    ret                     
                             
OutInt endp                  
       
   
exit:  
       
end START   

        ;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! 
        ;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
        ;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
        ;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
        ;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
        ;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
        ;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
        ;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
        ;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
        ;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
        ;!!!!!!!!!!!!!!!!!!!!!!!!!!!! !!!!!!!!!!!!! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
        ;!!!!!!!!!!!!!!!!!!!!!!!!!!!!  !!!!!!!!!!!  !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
        ;!!!!!!!!!!!!!!!!!!!!!!!!!!!!  !!!!!!!!!!!  !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
        ;!!!!!!!!!!!!!!!!!!!!!!!!!                     !!!!!!!!!!!!!!!!!!!!!!!!!!!!
        ;!!!!!!!!!!!!!!!!!!!!!!!!    0             0    !!!!!!!!!!!!!!!!!!!!!!!!!!!
        ;!!!!!!!!!!!!!!!!!!!!!!!                         !!!!!!!!!!!!!!!!!!!!!!!!!!
        ;!!!!!!!!!!!!!!!!!!!!!!!!                       !!!!!!!!!!!!!!!!!!!!!!!!!!!
        ;!!!!!!!!!!!!!!!!!!!!!!!!!        \___/        !!!!!!!!!!!!!!!!!!!!!!!!!!!!
        ;!!!!!!!!!!!!!!!!!!!!!!!!!!                  !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
        ;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!  !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
        ;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!  !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
        ;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!  !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
        ;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!      !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
        ;!!!!!!!!!!!!!!!!!!!!!!!!!!!!  !        !  !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
        ;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! !!    !! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
        ;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!    !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
        ;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!    !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
        ;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
        ;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
        ;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
        ;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
        ;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!