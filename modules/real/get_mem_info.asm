
; void -> void
get_mem_info:
    push eax
    push ebx
    push ecx
    push edx
    push si
    push di
    push bp

    cdecl puts, .s0

    mov bp, 0   ; 取得情報表示のときに使う．行数
    mov ebx, 0  ; 情報取得のためのインデックス．このインデックスに応じて取得できる情報がかわる

.10L:
    mov eax, 0x0000E820
    mov ecx, E820_RECORD_SIZE   ; buffer size 最小で20
    mov edx, 'PAMS' ; 'SMAP'  system mapの情報取得のための呼び出しであることをBIOSが確認するのに用いる
    mov di, .b0 ; es:di バッファ
    int 0x15    ; INT15h, ax=E820h

    cmp eax, 'PAMS' ; BIOSが未対応なら'SMAP'にはならない
    je .12E
    jmp .10E    ; break
.12E:
    jnc .14E    ; 成功ならcf==0
    jmp .10E    ; break
.14E:

    cdecl put_mem_info, di  ; 1レコード分のメモリ情報を表示

    mov eax, [di + 16]
    cmp eax, 3
    jne .15E

    mov eax, [di + 0]
    mov [ACPI_DATA.adr], eax

    mov eax, [di + 8]
    mov [ACPI_DATA.len], eax
.15E:

    cmp ebx, 0
    jz .16E

    inc bp  ; 行数++
    and bp, 0x07
    jnz .16E

    ; 表示行数が8の倍数になったら，一旦止める（みやすさのため）
    cdecl puts, .s2 ; 中断メッセージを表示
    mov ah, 0x10
    int 0x16    ; キー入力待ち
    cdecl puts, .s3 ; 中断メッセージの削除

.16E:
    cmp ebx, 0  ; 次のメモリ情報のインデックス．最終レコードなら0
    jne     .10L

.10E:
    cdecl puts, .s1 ; フッタの表示

    pop bp
    pop di
    pop si
    pop edx
    pop ecx
    pop ebx
    pop eax

    ret

.s0:	db " E820 Memory Map:", 0x0A, 0x0D
		db " Base_____________ Length___________ Type____", 0x0A, 0x0D, 0
.s1:	db " ----------------- ----------------- --------", 0x0A, 0x0D, 0
.s2:	db " <more...>", 0
.s3:	db 0x0D, "          ", 0x0D, 0

ALIGN 4, db 0
.b0:	times E820_RECORD_SIZE db 0

put_mem_info:
    push bp
    mov bp, sp

    push bx
    push si

    mov si, [bp + 4]    ; バッファアドレス
    ; Base
    cdecl itoa, word[si + 6], .p2 + 0, 4, 16, 0b0100
    cdecl itoa, word[si + 4], .p2 + 4, 4, 16, 0b0100
    cdecl itoa, word[si + 2], .p3 + 0, 4, 16, 0b0100
    cdecl itoa, word[si + 0], .p3 + 4, 4, 16, 0b0100

    ; Length
    cdecl itoa, word[si + 14], .p4 + 0, 4, 16, 0b0100
    cdecl itoa, word[si + 12], .p4 + 4, 4, 16, 0b0100
    cdecl itoa, word[si + 10], .p5 + 0, 4, 16, 0b0100
    cdecl itoa, word[si +  8], .p5 + 4, 4, 16, 0b0100

    ; Type
    cdecl itoa, word[si + 18], .p6 + 0, 4, 16, 0b0100
    cdecl itoa, word[si + 16], .p6 + 4, 4, 16, 0b0100

    ; 表示
    cdecl puts, .s1

    mov bx, [si + 16]
    and bx, 0x07
    shl bx, 1
    add bx, .t0
    cdecl puts, word [bx]

    pop si
    pop bx

    mov sp, bp
    pop bp
    ret

.s1: db " "
.p2: db "        _"
.p3: db "         "
.p4: db "        _"
.p5: db "         "
.p6: db "        ", 0

.s4: db " (Unknown)", 0x0A, 0x0D, 0
.s5: db " (usable)", 0x0A, 0x0D, 0
.s6: db " (reserved)", 0x0A, 0x0D, 0
.s7: db " (ACPI data)", 0x0A, 0x0D, 0
.s8: db " (ACPI NVS)", 0x0A, 0x0D, 0
.s9: db " (bad memory)", 0x0A, 0x0D, 0

.t0: dw .s4, .s5, .s6, .s7, .s8, .s9, .s4, .s4

