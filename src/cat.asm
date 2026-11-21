section .bss
    buffer resb 4096

section .text
    global _start

_start:

    ; open file
    mov rdi, [rsp + 16]
    mov rsi, 0
    mov rax, 2
    syscall

    ; read file
    mov r12, rax ;save fd
    mov rdi, r12 
    mov rsi, buffer
    mov rdx, 4096
    mov rax, 0
    syscall

    ;write
    mov rdx, rax
    mov rdi, 1
    mov rsi, buffer
    mov rax, 1
    syscall

    ;close fd
    mov rdi, r12
    mov rax, 3
    syscall

    ;exit 
    mov rax, 60
    mov rdi, 0
    syscall

