
putc:
    ; スタックフレームの構築
    push bp
    mov bp, sp

    ; レジスタの保存
    push ax
    push bx

    ; 処理
    mov al, [bp+4]
    mov ah, 0x0E
    mov bx, 0x0000
    int 0x10

    ; レジスタの復帰
    pop bx
    pop ax

    ; スタックフレームの破棄
    mov sp, bp
    pop bp

    ret


puts:

    push bp
    mov bp, sp

    push ax
    push bx
    push si

    mov si, [bp+4]  ;表示させたい文字列の先頭アドレス
    mov ah, 0x0E
    mov bx, 0x0000
    cld ; EFLAGSレジスタのDFフラグを0に．ストリング命令でポインタがインクリメントされる．

.10L:
    lodsb ; 文字列を読み取る．暗黙で読み取りアドレスをsiレジスタ，格納先をalレジスタとする． al <- *si++

    cmp al, 0    ; null終端でbreak
    je .10E

    int 0x10
    jmp .10L
.10E:

    pop si
    pop bx
    pop ax

    mov sp, bp
    pop bp

    ret


