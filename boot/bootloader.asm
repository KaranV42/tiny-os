bits 16                     ; 16-bit real mode

start:
    cli                     ; Clear all interrupts
    cld                     ; Clear the direction flag (string instructions will increment)

    xor ax, ax              ; Set AX to 0
    mov ds, ax              ; Set DS segment register to 0
    mov es, ax              ; Set ES segment register to 0
    mov ss, ax              ; Set SS segment register to 0
    mov sp, 0x7C00          ; Set stack pointer to just below where we're loaded (0x7C00)

    mov si, hello_msg       ; Load the address of the message into SI
    call print_string       ; Call our string-printing routine

    hlt                     ; Halt the CPU

; Function: print_string
;           Displays a zero-terminated string on the screen using BIOS interrupt
print_string:
    lodsb                   ; Load the next byte from string into AL
    or al, al               ; Check if we've hit the end of the string
    jz .done                ; If so, we're done

    mov ah, 0x0E            ; BIOS teletype function
    mov bh, 0x00            ; Page number
    mov bl, 0x07            ; Text attribute (white on black)
    int 0x10                ; Call BIOS interrupt to print character

    jmp print_string        ; Loop back to print the next character

.done:
    ret                     ; Return from the function

; Data section
hello_msg db 'Hello, World!', 0   ; Null-terminated string

times 510 - ($ - $$) db 0         ; Pad the rest of the sector with zeros
boot_signature dw 0xAA55          ; Boot signature (required for BIOS to recognize this as bootable)
