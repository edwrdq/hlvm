;imwarmim up
section .data

    message db "hi", 10
    len equ $ - message

section .bss

section .text
    global _start

_start:
    ;writing
    mov rax, 1
    mov rdi, 1
    mov rsi, message
    mov rdx, len
    syscall

    ;exit
    mov rax, 60
    mov rdi, 0
    syscall 