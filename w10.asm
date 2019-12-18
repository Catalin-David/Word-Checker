bits 32 ; assembling for the 32 bits architecture

; declare the EntryPoint (a label defining the very first instruction of the program)
global start        

; declare external functions needed by our program
extern exit, fopen, fclose, scanf, fprintf
import exit msvcrt.dll    ; exit is a function that ends the calling process. It is defined in msvcrt.dll
import fopen msvcrt.dll   ; msvcrt.dll contains exit, printf and all the other important C-runtime specific functions
import fclose msvcrt.dll
import scanf msvcrt.dll
import fprintf msvcrt.dll
; our data is declared here (the variables needed by our program)
segment data use32 class=data
    ; ...
    file_name db "output.txt", 0
    access_mode db "w", 0
    file_descriptor dd -1
    s times 254 db "0", 0
    endl db 10, 0
    format db "%s", 0
; our code starts here
segment code use32 class=code
    start:
        ; read words from keyboard until $ is met, for each word check if there are any uppercase letter, in which case print it in file
        ; open file and check for errors
        push dword access_mode
        push dword file_name
        call [fopen]
        add esp, 4*2
        mov [file_descriptor], eax
        cmp eax, 0
        je final
        ; loop until $ is met
    myLoop:
        ; read word
        push dword s
        push dword format
        call [scanf]
        add esp, 4*2
        ; compare to $
        cmp byte[s], 36
        je final
        ; Find length of string
        mov edi, s
        sub ecx, ecx
        sub al, al
        not ecx
        cld
        repne scasb
        not ecx
        dec ecx
        ; check for uppercase letters
        mov edx, 0
        iterate:
            cmp byte[s+ecx], 65
            jl noAdd
            cmp byte[s+ecx], 90
            ja noAdd
            inc edx
            noAdd: 
        loop iterate
        cmp edx, 1
        jl nextWord
        ; print if it has uppercase
        push dword s
        push dword [file_descriptor]
        call [fprintf]
        add esp, 4*2
        push dword endl
        push dword[file_descriptor]
        call [fprintf]
        add esp, 4*2
        nextWord:    
            jmp myLoop
        
    final    
        push dword [file_descriptor]
        call [fclose]
        add esp, 4
        
        ; exit(0)
        push    dword 0      ; push the parameter for exit onto the stack
        call    [exit]       ; call exit to terminate the program
