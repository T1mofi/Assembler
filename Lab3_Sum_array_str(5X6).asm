.model small                                                    
    
.stack 100h                                                     ; 256B fo stack
   
.data
    msg_inp    db 0Dh, 0Ah, 'Input array: ', '$'
    msg_result db 0Dh, 0Ah, 'Result: ', '$'
    msg_col    db 0Dh, 0Ah, 'Columns: ', '$'
    msg_row    db 0Dh, 0Ah, 'Rows: ', '$' 
    msg_invld  db 0Dh, 0Ah, 'Incorrectly, Enter again. ', '$' 
    msg_overfl db 0Dh, 0Ah, 'Overflow! Enter again. ', '$'
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
            call  get_number                        ; get_number() - result in AX
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

    sum_loop1:                                      ; do{
        push  CX                 
        xor   CX, CX             
        mov   CL, columns        
                            
        sum_loop2:                                  ;   do{
            mov   AX, array[SI]                     ;       AX = array[SI]
            add   result[DI], AX                    ;       result[DI] += AX
            jo    sum_error                         ;       ? OF==1 goto sum_error (overflow flag) - set sum in row = 0
            add   SI, 2                 
        loop  sum_loop2
                                                    ;   }while(--CX!=0)
        to_next_row:            
        pop   CX                 
        add   DI, 2
    loop  sum_loop1
             
    jmp   OutputResult                 
   
    sum_error:                                      ; sum error
        mov  result[DI], 00h                        ; 
        jmp  to_next_row                            ; 
   
                                                                      
                                                                      
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;                                                                                                                                                                                                                                                     
OutputResult: 
    mov  AH, 09h             
    lea  DX, msg_result        
    int 21h                  
                            
    xor  CX, CX                                     
    mov  CL, rows                                   
    xor  SI, SI                                     
    
    output_loop:                
        mov  AX, result[SI]      
        call OutInt              
        add  SI, 2                     
                
        mov  AH, 02h                                ; print ' '
        mov  DL, ' '                                ;
        int 21h                                     ;
                            
    loop output_loop         
    jmp exit                 
                                                                                                                                     
           
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
                             

    converting:                                     ; form string to int                          
        xor   CX, CX                                ; CX = 0
        mov   CL, number[1]                         ; CL = len of string with number
        mov   SI, CX                                ; SI = CX
        inc   SI                                    ; ++SI - set on last sumbol of sting
        xor   BX, BX                                ; BX = 0 - stores the result                                
        mov   DX, 1                                 ; DX = 1 - discharge multiplier
        push  DX                                    ; push DX to stack
        xor   AX, AX                                ; AX = 0 - value of discharge
                                   
        converting_loop:              ; do{
            mov   AL, number[SI]      ;      AL = number[SI]
            cmp   AL, '-'             ;      
            je    to_neg              ;
            and   AX, 0Fh             ;      char to int(-48)
    
            mul   DX                  ;      AX = AX*DX, DX=0
            pop   DX                  ;      pop DX from stack
            jo    overflow            ;      ? OF==1 goto overflow (overflow flag)
   
            add   BX, AX              ;      BX +=AX
            js    overflow            ;      ? SF==1 goto overflow (sign flag)
            jo    overflow            ;      ? OF==1 goto overflow (overflow flag) 
   
            cmp   SI, 02h             ;      ? SI==02h goto end_get
            je    end_get             ;      02h - start of number 
   
            mov   AX, 10              ;      DX = 10
            mul   DX                  ;      AX = AX*DX 
            jo    overflow            ;      ? OF==1 goto overflow (overflow flag)
   
            xchg  DX, AX              ;      AX <-> DX
            push  DX                  ;      push DX to stack
            dec   SI                  ;      --SI
        loop  converting_loop     ; } while(CX--!=0)
        jmp   end_get             ; goto end_get
                             ;
                             ;
    to_neg:                      ; convert to neg
        pop   DX                  ; pop form stack 
        neg   BX                  ; BX = -BX conversion to reverse code
        jo    overflow            ; ? OF==1 goto overflow (overflow flag)
        jmp   end_get             ; goto end_get
                             ;

    overflow:                    ; overflow
        mov   AH, 09h             ;
        lea   DX, msg_overfl        ;
        int   21h                 ;
        jmp   num_inp            ; enter again

    end_get:                     ;
        mov   AX, BX              ; result to AX
        pop   DI                  ; recovery DI, SI, BX. CX
        pop   SI                  ;
        pop   BX                  ;
        pop   CX                  ;
        ret
                               ; return
get_number endp          ; }  
   

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
 
 
OutInt proc                  ;void output_int(AX = intNumber)
                             ;{
    push CX                  ; push CX to stack
    test AX, AX              ; if(AX>=0)
    jns  oi1                 ;  goto oi1
                             ;
    mov  BX, AX              ; BX = AX
    mov  AH, 02h             ; {
    mov  DL, '-'             ;  cout << '-'
    int  21h                 ; }
    mov  AX, BX              ; AX = BX
    neg  AX                  ; AX = -AX
    
    oi1:                         ;
        xor  CX, CX              ; CX = 0
        mov  BX, 10              ; BX = 10
    oi2:                         ; do{
        xor  DX,DX               ;  DX = 0
        div  BX                  ;  AX /= BX, DX = AX % BX
        push DX                  ;  push DX to stack
        inc  CX                  ;  ++CX
        test AX, AX              ; 
        jnz  oi2                 ; }while(AX!=0)
        mov  AH, 02h             ; AH = O2h - output one sumbol
    oi3:                         ; do{
        pop  DX                  ;  pop DX from stack 
        add  DL, '0'             ;  DL += '0' (48) - char to int
        int  21h                 ;  interrupt for implementation
    loop oi3                 ; }while(CX--!=0)
    
    pop  CX                  ; pop CX from stack
    ret                      ; return
                             ;
OutInt endp                  ;}
       
   
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
        ;!!!!!!!!!!!!!!!!!!!!!!!!!       ___           !!!!!!!!!!!!!!!!!!!!!!!!!!!!
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