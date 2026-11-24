section .bss
    statbuf resb 144
    cur_tok resb TOKEN_SIZE

section .data
    tok_eof db "EOF", 10
    tok_eof_len equ $ - tok_eof
    tok_lparen db "LPAREN", 10
    tok_lparen_len equ $ - tok_lparen 
    tok_rparen db "RPAREN", 10
    tok_rparen_len equ $ - tok_rparen
    tok_question db "QUESTION", 10
    tok_question_len equ $ - tok_question
    tok_bang db "BANG" , 10
    tok_bang_len equ $ - tok_bang
    tok_string db "STRING", 10
    tok_string_len equ $ - tok_string
    err_unclosed db "make up your mind", 10 
    err_unclosed_len equ $ - err_unclosed 
    tok_ident db "IDENT", 10
    tok_ident_len equ $ - tok_ident
    tok_equals db "EQUALS", 10
    tok_equals_len equ $ - tok_equals
    tok_and db "AND", 10 
    tok_and_len equ $ - tok_and 
    kw_and db "*AND*"
    kw_comment db "**excuse me " ;trailing space btw


section .text

lexer_init: 
    ;open (argv[1], 0)
    ; same as cat
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
    jz .empty

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
    mov r15, 1

    ; close (fd), keep mapping valid 
    mov rax, 3
    mov rdi, r12 
    syscall
    ret

.empty:
    ; empty file
    xor r13, r13
    xor r14, r14
    mov r15, 1
    ret

next_token: 
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
    je .newline
    cmp al, 13
    je .next

    ;single char tok 
    cmp al, '(' 
    je .lparen 
    cmp al, ')'
    je .rparen 
    cmp al, '?'
    je .question 

    ;bang comparison 
    cmp al, '!'
    je .bang

    ;double quotes (string)
    cmp al, '"'
    je .string

    ;comments
    cmp al, '*'
    je .maybe_comment

    jmp .ident 

.maybe_comment: 
    ;enough bytes for a phrase ? 
    mov rcx, r14 
    sub rcx, r13 ; bytes remaining
    cmp rcx, 12
    jb .ident ;too short, identifier 

    ;match **excuse me ?
    mov rsi, r13 
    mov rdi, kw_comment
    mov rdx, 12 
    call mem_eq
    test rax, rax
    jz .ident ;no match, identifier

.skip_comment: 
    inc r13
    cmp r13, r14 
    je .eof
    cmp byte [r13], 10
    jne .skip_comment
    jmp .loop

.newline:
    inc r15 
    jmp .next

.lparen: 
    mov qword [cur_tok + TOKEN_TYPE], TOK_LPAREN
    mov [cur_tok + TOKEN_START], r13
    mov qword [cur_tok + TOKEN_LEN], 1
    mov qword [cur_tok + TOKEN_LINE], r15
    inc r13 ;(consume)
    ret

.rparen: 
    mov qword [cur_tok + TOKEN_TYPE], TOK_RPAREN
    mov [cur_tok + TOKEN_START], r13
    mov qword [cur_tok + TOKEN_LEN], 1
    mov qword [cur_tok + TOKEN_LINE], r15
    inc r13 ;(consume)
    ret

.question:
    mov qword [cur_tok + TOKEN_TYPE], TOK_QUESTION
    mov [cur_tok + TOKEN_START], r13
    mov qword [cur_tok + TOKEN_LEN], 1
    mov qword [cur_tok + TOKEN_LINE], r15
    inc r13 ;(consume)
    ret 

.string:
    lea rbx, [r13 + 1]
.string_loop: 
    inc r13 
    cmp r13, r14
    je .unclosed ; if eof is hit without closing "
    cmp byte [r13], 10
    jne .string_check_quote
    inc r15
    jmp .string_loop
.string_check_quote:
    cmp byte [r13], '"'
    jne .string_loop
    ; r13 is on closing "
    mov rcx, r13
    sub rcx, rbx
    mov qword [cur_tok + TOKEN_TYPE], TOK_STRING
    mov [cur_tok + TOKEN_START], rbx 
    mov [cur_tok + TOKEN_LEN], rcx 
    mov [cur_tok + TOKEN_LINE], r15
    inc r13
    ret

.unclosed: 
    mov rsi, err_unclosed
    mov rdx, err_unclosed_len 
    call die 

.bang: 
    mov rbx, r13 ; first ! location 
.bang_loop: 
    inc r13 
    cmp r13, r14 
    je .bang_done ; out of file 
    cmp byte [r13], '!'
    je .bang_loop ; theres another ! so we keep going 
.bang_done: 
    ; define count as being r13 - rbx (amount of !) 
    mov rcx, r13 ; rcx is location where ! ended
    sub rcx, rbx ; rcx = end - start = number of ! there = our count !!
    mov qword [cur_tok + TOKEN_TYPE], TOK_BANG
    mov [cur_tok + TOKEN_START], rbx 
    mov [cur_tok + TOKEN_LEN], rcx
    mov [cur_tok + TOKEN_LINE], r15
    ret

.ident: 
    mov rbx, r13  ; we r starting 
.ident_loop: 
    inc r13 
    cmp r13, r14 
    je .ident_done ;eof
    mov al, [r13]
    ; stop on whitespace 
    cmp al, ' '
    je .ident_done
    cmp al, 9
    je .ident_done
    cmp al, 10 
    je .ident_done
    cmp al, 13 
    je .ident_done
    ; stop on reserved
    cmp al, '!'
    je .ident_done
    cmp al, '?'
    je .ident_done
    cmp al, '('
    je .ident_done 
    cmp al, ')'
    je .ident_done
    cmp al, '"'
    je .ident_done 
    ; non ascii -> crash
    cmp al, 127 
    ja .crash  
    jmp .ident_loop 
.ident_done:
    mov rcx, r13 ; length = r13 - rbx
    sub rcx, rbx

    ; is it "="?
    cmp rcx, 1
    jne .check_and
    cmp byte [rbx], '='
    je .equals

.check_and:
    ; is it "*AND*"
    cmp rcx, 5
    jne .plain_ident
    mov rsi, rbx      ; start of identifier
    mov rdi, kw_and      ; keyword to compare against
    mov rdx, 5      ; how many bytes
    call mem_eq
    test rax, rax
    jnz .and_tok      

.plain_ident:
    mov rcx, r13
    sub rcx, rbx
    mov qword [cur_tok + TOKEN_TYPE], TOK_IDENT
    mov [cur_tok + TOKEN_START], rbx 
    mov [cur_tok + TOKEN_LEN], rcx
    mov [cur_tok + TOKEN_LINE], r15
    ret

.equals:
    mov qword [cur_tok + TOKEN_TYPE], TOK_EQUALS
    mov [cur_tok + TOKEN_START], rbx 
    mov [cur_tok + TOKEN_LEN], rcx
    mov [cur_tok + TOKEN_LINE], r15
    ret

.and_tok:
    mov rcx, r13
    sub rcx, rbx
    mov qword [cur_tok + TOKEN_TYPE], TOK_AND
    mov [cur_tok + TOKEN_START], rbx 
    mov [cur_tok + TOKEN_LEN], rcx
    mov [cur_tok + TOKEN_LINE], r15
    ret 

.next:
    inc r13
    jmp .loop
 
.eof:
    mov qword [cur_tok + TOKEN_TYPE], TOK_EOF
    mov [cur_tok + TOKEN_START], r13
    mov qword [cur_tok + TOKEN_LEN], 0
    mov [cur_tok + TOKEN_LINE], r15
    ret

.crash: 
    mov byte [abs 0], 0

print_token: 
    mov rax, [cur_tok + TOKEN_TYPE]
    cmp rax, TOK_LPAREN
    je .lparen
    cmp rax, TOK_RPAREN
    je .rparen
    cmp rax, TOK_QUESTION
    je .question
    cmp rax, TOK_BANG
    je .bang
    cmp rax, TOK_STRING 
    je .string
    cmp rax, TOK_EQUALS
    je .equals
    cmp rax, TOK_IDENT
    je .ident 
    cmp rax, TOK_AND
    je .and_tok 

    mov rsi, tok_eof
    mov rdx, tok_eof_len 
    jmp .print

.lparen:
    mov rsi, tok_lparen
    mov rdx, tok_lparen_len
    jmp .print
.rparen:
    mov rsi, tok_rparen
    mov rdx, tok_rparen_len
    jmp .print
.question: 
    mov rsi, tok_question
    mov rdx, tok_question_len
    jmp .print
.bang: 
    mov rsi, tok_bang
    mov rdx, tok_bang_len
    jmp .print
.string: 
    mov rsi, tok_string
    mov rdx, tok_string_len
    jmp .print
.ident:
    mov rsi, tok_ident
    mov rdx, tok_ident_len
    jmp .print
.equals:
    mov rsi, tok_equals
    mov rdx, tok_equals_len
    jmp .print 
.and_tok: 
    mov rsi, tok_and
    mov rdx, tok_and_len
    jmp .print

.print:
    call print_str
    ret