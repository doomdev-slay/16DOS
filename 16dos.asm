bits 16
org 0x7c00

xor ax, ax
mov ds, ax
mov es, ax

mov ss, ax  ; AX je 0
mov sp, 0x7c00


start:
    ; 1. MODRÉ POZADÍ
    mov ah, 0x06
    mov al, 0
    mov bh, 0x1F    ; Bílá na modré
    mov cx, 0
    mov dx, 0x184F
    int 0x10

    ; 2. NÁPIS "16DOS" nahoře
    mov ah, 0x02    ; Nastavit kurzor
    mov bh, 0
    mov dx, 0x0000  ; Řádek 0, sloupec 0
    int 0x10

    mov si, title_msg
    call print_string

main_loop:
    ; Prompt
    mov si, prompt_msg
    call print_string

    ; Čekání na klávesu
    mov ah, 0x00
    int 0x16

    cmp al, 'd'     ; DATUM
    je get_date
    cmp al, 'a'     ; SOUČET
    je do_sum
    cmp al, 'r'     ; REBOOT
    je reboot_sys
    jmp main_loop

do_sum:
    ; První číslo
    mov ah, 0x00
    int 0x16        ; Načti znak
    mov cl, al      ; Schovej si ho do CL
    mov ah, 0x0e    ; Vypiš ho
    int 0x10

    mov al, '+'     ; Vypiš plus
    int 0x10

    ; Druhé číslo
    mov ah, 0x00
    int 0x16
    mov bl, al      ; Schovej si ho do BL
    mov ah, 0x0e
    int 0x10

    mov al, '='     ; Vypiš rovná se
    int 0x10

    ; VÝPOČET: (CL - '0') + (BL - '0') + '0'
    sub cl, '0'
    sub bl, '0'
    add cl, bl
    add cl, '0'
    
    mov al, cl      ; Výsledek do AL pro tisk
    mov ah, 0x0e
    int 0x10
    jmp main_loop

get_date:
    mov ah, 0x04
    int 0x1a
    mov al, dl      ; Vypíše den v BCD
    call print_bcd
    jmp main_loop

reboot_sys:
    jmp 0xFFFF:0

print_string:
    mov ah, 0x0e
.loop:
    lodsb
    cmp al, 0
    je .done
    int 0x10
    jmp .loop
.done:
    ret

print_bcd:
    push ax
    shr al, 4
    add al, '0'
    mov ah, 0x0e
    int 0x10
    pop ax
    and al, 0x0F
    add al, '0'
    int 0x10
    ret

title_msg  db '*** 16DOS v1.0 ***', 0
prompt_msg db 13, 10, '> ', 0

times 510-($-$$) db 0
dw 0xaa55
