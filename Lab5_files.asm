.model small
.stack 100h
.data

start_message                   db "Program is started", '$'
bad_cmd_message                 db "Bad cmd arguments", '$'
file_not_open_message           db "Cannot open file", '$'
file_not_found_message          db "File not found", '$'
error_closing_file_message      db "Cannot close file", '$'
end_text_message                db "Program is ended", '$'
error_read_file_text_message    db "Error reading from file", '$'
file_is_empty_message           db "File is empty", '$' 
result_message                  db "Number of lines: ", '$'

space_char        equ 32
enter_char        equ 13
next_line_char    equ 10
tabulation        equ 9
endl_char         equ 0

max_size          equ 126 
cmd_size          db  ?
cmd_text          db  max_size + 2 dup(0)
file_path         db  max_size + 2 dup(0) 

file_descriptor   dw  0
empty_line_count  dw  0
buffer            db  max_size + 2 dup(0)

empty_line_flag   db  0
end_of_file_flag  db  0 

.code 



print_result proc
    pusha           
    
    mov cx, 10         
    xor di, di    
    
;string->int    
conversion:       
    xor dx, dx
    div cx              
    add dl, '0'         
    inc di
    push dx              
    or ax, ax
    jnz conversion 
 
    
show:
    pop dx              
    mov ah, 2           
    int 21h
    dec di              
        jnz show
    
    mov dl, 13     ;new line
	mov ah, 2h
	int 21h    
	          
	mov dl, 10     ;start of line
	mov ah, 2h
	int 21h   
    
    popa
    ret    
endp 



macro exit_app
    
   mov ax,4C00h
   int 21h  
   
endm


      
macro print_message out_str
    
	push ax
	push dx
	
	mov ah, 9h
	mov dx, offset out_str
	int 21h          
	
	mov dl, 13    ;new line
	mov ah, 2h
	int 21h      
	
	mov dl, 10    ;begin of line
	mov ah, 2h
	int 21h    
	
	pop dx
	pop ax
	
endm
    
    
    
strlen proc
	push bx
	push si  
	
	xor ax, ax 
    start_calculation:   
    
	    mov bl, ds:[si] 
	    cmp bl, endl_char
	        je end_calculation 
	
	    inc si
	    inc ax                          ;counter
	    
	jmp start_calculation
	
    end_calculation:
    
	    pop si 
	    pop bx
	    ret
endp
 


macro is_empty text_line, marker  
    
	push si
	
	mov si, offset text_line
	call strlen
	
	pop si
	cmp ax, 0                           ;ax-result of strlen
	    je marker 
endm
    
    
        
start: 

	mov ax, @data
	mov es, ax 
	read_cmd 
	mov ds, ax
	
	print_message start_message                   
	
	call read_from_cmd				
    call open_file
	call file_handling
	
	end_prog:			
	call close_file	
				     
    mov ah, 9h                      ;result:
	mov dx, offset result_message
	int 21h                     
	
	mov ax, empty_line_count     
    call print_result    
	
end_main: 

	print_message end_text_message  
	exit_app	
   

    
macro read_cmd  
    
    xor ch, ch
	mov cl, ds:[80h]	                    ;80h - command line	length	
	mov cmd_size, cl 		
	mov si, 81h                             ;81h - comand line
	mov di, offset cmd_text
	rep movsb
	                                        ;repeat send byte while not end
endm
    


rewrite_word proc 
    
	push ax
	push cx
	push di        
	
    loop_parse_word:    
    
	    mov al, ds:[si]                     ;some checks 
	    
	    cmp al, space_char        
	        je is_stopped_char
	        
	    cmp al, enter_char
	        je is_stopped_char
	        
	    cmp al, tabulation
	        je is_stopped_char 
	        
	    cmp al, next_line_char
	        je is_stopped_char 
	        
	    cmp al, endl_char
	        je is_stopped_char
	        
	    mov es:[di], al
	    
	    inc di
	    inc si 
	    
	loop loop_parse_word 
	
    is_stopped_char:  
    
	    mov al, endl_char
	    mov es:[di], al
	    
	    inc si 
	
	    pop di
	    pop cx
	    pop ax  
	    
	ret
endp    


  
read_from_cmd proc  
    
	push bx 
	push cx
	push dx 
	     
	xor ch, ch
	mov cl, cmd_size 
	mov si, offset cmd_text
	mov di, offset buffer
		         
	call rewrite_word                        ;read cmd parameters before filePath               
	
        
	mov di, offset file_path
	call rewrite_word
	is_empty file_path, bad_cmd              ;check cmd file name 
	
	mov di, offset buffer
	call rewrite_word
	is_empty buffer, cmd_is_good             ;check cmd after file name 
	
    bad_cmd:                  
    
	    print_message bad_cmd_message
	    mov ax, 1
	    jmp endproc                   
	
    cmd_is_good:
	    mov ax, 0                       
	
    endproc:    

	    pop dx
	    pop cx
	    pop bx
	    
	    cmp ax, 0                            ;check if good cmd params
	        jne end_main
	ret	
endp    
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;     


             
open_file proc
	
	mov ah, 3Dh                                 ;open existing file		
	mov al, 0 	                                ;for reading	
	mov dx, offset file_path          
	int 21h                       
	    jnb file_was_open	                    ;cf = 1 error            		 
	
     

	print_message file_not_open_message
	    
	cmp ax, 02h                                 ;ax - mistake code 
	    jne end_main
	        
	print_message file_not_found_message   
	    jmp end_main    
		
    file_was_open:
    
        mov file_descriptor, ax	                ;ax - file id   
	
	ret
endp


   
read_from_file proc
    
	push bx
	push cx
	push dx                        
	
	mov ah, 3Fh                                     ;3Fh - read from file
	mov bx, file_descriptor                         ;file id
	mov cx, max_size                                ;number of bytes for read
	mov dx, offset buffer                           ;receiver buffer
	int 21h
	    jnb buffer_processing		                ;cf=0 - successfully readed
	    		
	print_message error_read_file_text_message
	mov ax, 0
	
	buffer_processing:
	
	    mov bx, ax                                  ;ax - number of readed bytes
	    mov buffer[bx], endl_char                   ;need to put endline
	
	    mov si, offset buffer
	
	    cmp ax, max_size
	        je good_read
	    
	    mov end_of_file_flag, 1                                
	
    good_read:
    
	    pop dx
	    pop cx
	    pop bx
	       
	ret
endp


        
file_handling proc
    
    pusha
    
    call read_from_file	           
    
    line_processing:
    
        cmp empty_line_flag, 1
            jne reset_empty_line_flag
        
        inc empty_line_count    
        
        reset_empty_line_flag:
            mov empty_line_flag, 1                      
        
        processing_loop:                                ;check character of line
    
            mov al, ds:[si]
            inc si
                     
            cmp al, enter_char
                je processing_loop 
            
            cmp al, space_char
                je processing_loop
                
            cmp al, next_line_char
                je line_processing 
                
            cmp al, endl_char
                je read_piece_of_file
                 
            mov empty_line_flag, 0
                jmp processing_loop
            
            read_piece_of_file:
            
                cmp end_of_file_flag, 1
                    je last_line_check 

                call read_from_file
            
        jmp processing_loop
        
        
        last_line_check:
        
            cmp empty_line_flag, 1
                jne end_line_processing
            
            inc empty_line_count
     
    end_line_processing:
   	
    popa
	    
	ret
endp
        

                                 
close_file proc
	push bx
	push cx  
	
	xor cx, cx
	mov ah, 3Eh       
	mov bx, file_descriptor   
	int 21h
	    jnb good_close		                    ;cf = 0 - successfully closed    
	
	print_message error_closing_file_message
	inc cx 	
			
good_close:
	mov ax, cx 		
	pop cx
	pop bx 
	
	cmp ax, 0
	    jne end_main 
	    
	ret 
endp 

end start
