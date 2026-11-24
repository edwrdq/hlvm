default rel
%include "src/tokens.inc"
%include "src/lib.asm"

section .bss
    statbuf resb 144

section .data
    eof_msg db "EOF", 10
    eof_len equ $ - eof_msg
    tok_lparen db "LPAREN", 10
    tok_lparen_len equ $ - tok_lparen 
    tok_rparen db "RPAREN", 10
    tok_rparen_len equ $ - tok_rparen
    tok_question db "QUESTION", 10
    tok_question_len equ $ - tok_question


section .text
    global _start 

_start:

    ;open (argv[1], 0)
    ; same as cat
    mov rdi, [rsp + 16]
    mov rsi, 0
    mov rax, 2
    syscall

    ;save fd in r12
    mov r12, rax

    ;fstat(fd, statbuf)
    ; rax = 5, rdi = fd, rsi =statbuf 
    mov rax, 5 
    mov rdi, r12 
    mov rsi, statbuf 
    syscall

    ; size = [statbuf + 48], r15 
    mov r15, [statbuf + 48]

    ; if size == 0, jump to .eof 
    test r15, r15
    jz .eof

    ; mmap (0, addy, length, 2, fd, 0)
    ; 4th arg is r10 for some weird reason
    mov rax, 9
    mov rdi, 0
    mov rsi, r15
    mov rdx, 1
    mov r10, 2
    mov r8, r12 
    mov r9, 0
    syscall

    ; r13 = start (rax) , r14 = start + size 
    ; lea r14, [rax + r15]
    mov r13, rax
    lea r14, [rax + r15]

    ; close (fd), keep mapping valid 
    mov rax, 3
    mov rdi, r12 
    syscall

.loop: 

    ; r13 == r14 -> jump to .eof
    cmp r13, r14
    je .eof

    ;update: lexing logic now here
    ; non ascii -> we crash dis bih 
    mov al, [r13]
    cmp al, 127
    ja .crash 

    ; whitespace -> skip 
    cmp al, ' '
    je .next 
    cmp al, 9
    je .next
    cmp al, 10
    je .next
    cmp al, 13
    je .next

    ;single char tok 
    cmp al, '(' 
    je .lparen 
    cmp al, ')'
    je .rparen 
    cmp al, '?'
    je .question 

    jmp .next 

.lparen: 
    mov rsi, tok_lparen
    mov rdx, tok_lparen_len
    call print_str
    jmp .next 

.rparen: 
    mov rsi, tok_rparen
    mov rdx, tok_rparen_len
    call print_str
    jmp .next 

.question:
    mov rsi, tok_question
    mov rdx, tok_question_len
    call print_str
    jmp .next 

.next:
    inc r13
    jmp .loop

.eof: 

    ; write (1, eof msg, eof len)
    mov rax, 1
    mov rdi, 1
    mov rsi, eof_msg
    mov rdx, eof_len 
    syscall 

    ;exit 
    mov rax, 60
    mov rdi, 0
    syscall

.crash: 
    mov byte [abs 0], 0
