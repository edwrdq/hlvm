default rel 
%include "tokens.inc"
%include "lib.asm"
%include "lexer.asm"

section .text
    global _start 

_start: 
    mov rdi, [rsp + 16] ;argv[1]
    call lexer_init
.loop: 
    call next_token
    call print_token
    cmp qword [ cur_tok + TOKEN_TYPE], TOK_EOF 
    jne .loop 
    call exit_ok