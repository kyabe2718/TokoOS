reboot:

    cdecl puts, .message

.Loop:
    mov ah, 0x10
    int 0x16

    cmp al, ' '
    jne .Loop

    ; 改行
    cdecl puts, .newline

    ; 再起動
    int 0x19


    .message: db 0x0A, 0x0D, "Push Space key to reboot...", 0
    .newline: db 0x0A, 0x0D, 0x0A, 0x0D, 0
