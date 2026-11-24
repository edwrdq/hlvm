%include "src/lib.asm"

section .bss

section .data 
    a db "*AND*" 
    a_len equ $ - a
    b db "*AND*"
    b_len equ $ - b
    c db "meow"
    c_len equ $ - c
    match_msg db "match", 10
    match_len equ $ - match_msg 
    nomatch_msg db "no match", 10
    nomatch_len equ $ - nomatch_msg 

section .text 
    global _start

_start: 
    ; test 1 - a vs b (SHOULD match) 
    mov rsi, a 
    mov rdi, b 
    mov rdx, a_len 
    call mem_eq 
    test rax, rax 
    jz .t1_no
    ; print match
    mov rsi, match_msg
    mov rdx, match_len 
    call print_str
    jmp .t2 
.t1_no: 
    mov rsi, nomatch_msg
    mov rdx, nomatch_len
    call print_str
.t2: 
    ; test 2 - a vs c (shouldNT match)
    mov rsi, a 
    mov rdi, c 
    mov rdx, a_len 
    call mem_eq 
    test rax, rax 
    jz .t2_no 
    mov rsi, match_msg
    mov rdx, match_len 
    call print_str
    jmp .done
    
.t2_no:
    mov rsi, nomatch_msg
    mov rdx, nomatch_len
    call print_str 

.done: 
    call exit_ok 