
; 再起動
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

; セクタ読み出し
read_chs:   ;(パラメータバッファ（アドレス）, セクタ数, コピー先)
    ;コピー先                   ; bp + 8
    ;セクタ数                   ; bp + 6
    ;パラメタバッファ           ; bp + 4
    push bp                     ; bp + 2
    mov bp, sp                  ; bp
    push 3  ; retry数           ; bp - 2
    push 0  ; 読み込みセクタ数  ; bp - 4

    push bx
    push cx
    push dx
    push es
    push si

    mov si, [bp + 4]    ; パラメータバッファ

    ; cxレジスタの設定
    ; ch tttttttt   シリンダの下位8ビット
    ; cl ttssssss   tt:シリンダの上位2ビット ssssss:セクタ番号
    mov ch, [si + drive.cyln + 0]   ; シリンダの下位8ビット（1バイト）
    mov cl, [si + drive.cyln + 1]   ; シリンダの上位バイト
    shl cl, 6
    or cl, [si + drive.sect]

    ; セクタ読み込み
    mov dh, [si + drive.head]
    mov dl, [si + 0]
    mov ax, 0x0000
    mov es, ax
    mov bx, [bp + 8]
    ;es:bx 読み込んだセクタを格納するバッファの先頭アドレス

.10L:
    mov ah, 0x02        ; セクタ読み込み
    mov al, [bp + 6]    ; セクタ数

    int 0x13
    ; cf: 成功なら0，失敗なら1
    ; ah: エラーコード
    ; al: 実際に読み込んだセクタ数
    jnc .11E    ; cf == 0

    mov al, 0
    jmp .10E

.11E:
    cmp al, 0   ; 読み込んだセクタがあれば.10Eへ
    jne .10E

    mov ax, 0
    dec word[bp - 2]    ; リトライ回数をデクリメント
    jnz .10L

.10E:
    mov ah, 0   ; エラーコードを破棄

    pop si
    pop es
    pop dx
    pop cx
    pop bx

    mov sp, bp
    pop bp

    ret
