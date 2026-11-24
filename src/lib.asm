;lib.asm hlvm util functions

;calling rules: 
; arguments in: rdi, rsi, rdx (like syscalls)
; return value in rax
; may clobber: rax, rcx, rdx, rsi, rdi, r8-r11 
; must not touch: rbx, r12-r15 

section .text

; print_str: write rdx bytes from rsi to std out 
; in: rsi = pointer, rdx = length 
print_str: 
    mov rax, 1
    mov rdi, 1
    syscall
    ret 

; print_newline: write a single "\n" 
print_newline: 
    mov rsi, newline_char 
    mov rdx, 1
    call print_str
    ret 

; exit_ok: exit(0)
exit_ok: 
    mov rax, 60
    mov rdi, 0
    syscall

; die: print error to stderr, exit(1) 
; in: rsi = message, rdx = length 
die: 
    mov rax, 1
    mov rdi, 2
    syscall
    mov rax, 60
    mov rdi, 1
    syscall

; mem_eq: compare two byte ranges
; in: rsi = a, rdi = b, rdx = length 
; out: rax = 1 if equal, 0 if !
mem_eq: 
    .loop:
        test rdx, rdx
        jz .equal
    
        mov al, [rsi]
        mov cl, [rdi]
        cmp al, cl
        jne .not_equal

        inc rsi
        inc rdi
        dec rdx 
        jmp .loop
    .equal: 
        mov rax, 1
        ret 
    .not_equal: 
        mov rax, 0
        ret

section .data
    newline_char db 10