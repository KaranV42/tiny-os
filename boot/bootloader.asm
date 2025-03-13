[bits 16] ; Start in 16-bit real mode

start:
    cli                                 ; Disable interrupts
    cld                                 ; Clear direction flag

    ; setting up registers

    xor ax, ax                          ; Zero out AX register
    mov cs, ax                          ; Set code segment to zero
    mov ds, ax                          ; Set data segment to zero
    mov es, ax                          ; Set extra segment to zero
    mov ss, ax                          ; Set stack segment to zero (important)
    mov sp, 0x7C00                      ; Initialize stack
    jmp 0x0000:$+2                      ; Far jump to reset CS

    call enable_a20
    mov si, hello_msg
    call print_string
    hello_msg db 'Hello, World!', 0     ; Null-terminated string

    jmp $                               ; Infinite loop (halt execution)

    ;fuction for enabling a20 line
        enable_a20:
        cli
        ;Check if the input buffer is empty.
            .wait_input:
                in   al, 0x64           ; Read status from keyboard controller
                test al, 2              ; Check if input buffer is full
                jnz  .wait_input        ; If full, wait until it’s empty
            ;Send command 0xD1 to port 0x64
                mov  al, 0xD1           ; Command: Write to output port
                out  0x64, al           ; Send to keyboard controller
        ;Check if the input buffer is empty.
            .wait_input2:
                in   al, 0x64           ; Read status from keyboard controller
                test al, 2              ; Check if input buffer is full
                jnz  .wait_input2       ; If full, wait until it’s empty
            ;Send command 0xDF to port 0x60
                mov  al, 0xDF           ; Command: Write to output port
                out  0x60, al           ; Send to keyboard controller
        ;Re-enable interrupts
            sti                  
            ret
 
    ;fuction for printing "hello world"
        print_string:
            lodsb                       ; Load next character from [SI] into AL
            or al, al                   ; Check if null terminator (AL == 0)
            jz .done                    ; If zero, stop printing
            mov ah, 0x0E                ; BIOS teletype mode (print character)
            mov bh, 0x00                ; Page number (default = 0)
            mov bl, 0x07                ; Text color attribute (white on black)
            int 0x10                    ; BIOS interrupt to print character
            jmp print_string            ; Continue printing next character
            .done:
                ret                     ; Return to caller

times 510-($-$$) db 0                   ; Fill boot sector to 512 bytes
dw 0xAA55                               ; Boot signature
