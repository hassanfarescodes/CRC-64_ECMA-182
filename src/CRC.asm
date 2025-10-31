; ==========================================
; File: CRC.asm
; Author: Hassan Fares
; Description: CRC Source File
; Assembler: NASM
; Architecture: x86-64
; ==========================================

BITS 64

%include "../include/syscalls.inc"

section .data

    prompt db "CRC: "
    prompt_len equ $ - prompt

    exception db "Feed me a file! :(", 10, "Usage: ./crc <filename>", 10, 10
    exception_len equ $ - exception

section .bss

    ascii_buf   resb    128
    stat_buf    resb    144

section .text
global _start

arg_exc:
    mov rax, SYS_write
    mov rdi, 1
    lea rsi, [rel exception]
    mov rdx, exception_len

    syscall

    jmp exit

_start:

    mov rax, [rsp]
    cmp rax, 2
    jne arg_exc

    mov rax, SYS_open
    mov rdi, [rsp + 16]
    xor rsi, rsi
    xor rdx, rdx

    syscall

    test rax, rax
    js open_error

    mov rbx, rax    ; FD

    mov rax, SYS_fstat
    mov rdi, rbx
    lea rsi, [rel stat_buf]
    
    syscall

    js fstat_error

    mov rax, [stat_buf + 0x30]
    mov r12, rax    ; File size

    mov rax, SYS_mmap
    xor rdi, rdi
    mov rsi, r12
    mov rdx, 3
    mov r10, 0x22
    mov r8, -1
    xor r9, r9

    syscall

    js mmap_error

    mov r13, rax    ; Pointer to allocated memory

    mov rax, SYS_read
    mov rdi, rbx
    mov rsi, r13
    mov rdx, r12

    syscall

    test rax, rax
    js read_error

close_file:

    mov rax, SYS_close
    mov rdi, rbx
    syscall


CRC_setup:

    mov rdi, r13
    mov rsi, r13
    add rsi, r12

    mov r14, 0x0000000000000000 ;    <----- CRC-64 ECMA182 Initial CRC
    mov r10, 0x42F0E1EBA9EA3693 ;    <----- CRC-64 ECMA182 Initial Generator

CRC_algorithm:

    ; for each byte b in message:
    ;     crc = crc XOR (b << 56)
    ;     repeat 8 times:
    ;         if (crc & & 0x8000000000000000) != 0:
    ;             crc = (crc << 1) XOR 0x42F0E1EBA9EA3693
    ;         else
    ;             crc = crc << 1
    
    cmp rdi, rsi
    je done

    movzx rax, byte [rdi]
    shl rax, 56
    xor r14, rax

    mov rcx, 8

    MSB_loop:
        shl r14, 1
        jnc skip_xor
        xor r14, r10

    skip_xor:
        loop MSB_loop

    next_byte:
        inc rdi
        jmp CRC_algorithm

done:

    lea rsi, [rel ascii_buf]
    mov rax, r14
    mov rcx, 10
    xor r8, r8

    get_length:
        
        xor rdx, rdx
        div rcx
        cmp rax, 0
        je setup_ascii
        inc r8
        cmp rax, 0
        jmp get_length

    setup_ascii:

        mov rax, r14
        inc r8

        lea rdi, [rel ascii_buf]
        add rdi, r8
        mov byte [rdi], 10

        dec r8
        lea rsi, [rel ascii_buf]
        add rsi, r8

    ascii_algorithm:
        
        xor rdx, rdx
        div rcx
        add dl, '0'
        mov [rsi], dl
        dec rsi
        cmp rax, 0
        jne ascii_algorithm

    print:

        mov rax, SYS_write
        mov rdi, 1
        lea rsi, [rel prompt]
        mov rdx, prompt_len
        
        syscall

        mov rax, SYS_write
        mov rdi, 1
        lea rsi, [rel ascii_buf]
        mov rdx, r8
        add rdx, 2

        syscall

clean:

    mov rax, SYS_munmap
    mov rdi, r13
    mov rsi, r12
    syscall

    xor rdi, rdi ; Success code 0

    jmp exit


mmap_error:
    mov rdi, 1

    jmp exit

open_error:
    mov rdi, 2

    jmp exit

read_error:
    mov rdi, 3

    jmp exit

fstat_error:
    mov rdi, 4

exit:
    mov rax, SYS_exit
    ; rdi is already set
    syscall
