
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

itoa:   ; (value, buf, size, word flag)
    ; flagは下のビットから，符号付き整数として扱うか，"+/-"を付加するか，空白を0で埋めるか
    push bp
    mov bp, sp

    push ax
    push bx
    push cx
    push dx
    push si
    push di

    mov ax, [bp+4]  ; 変換元数値
    mov si, [bp+6]  ; buf
    mov cx, [bp+8]  ; size ひと桁ずつ表示するloopのカウンタになる

    mov di, si  ;
    add di, cx  ;
    dec di      ; di = &buf[size-1]; （この時点でsiはもう不要）

    mov bx, word[bp + 12]   ; flag

    ; 符号付き判定
    test bx, 0b001 ; if (flags & 0x01 != 0) // 値を符号付き整数として扱う
    je .END1       ; {
    cmp ax, 0      ;     if(val < 0)        // かつ，値が負である
    jge .END1      ;      {
    or bx, 0b0010  ;          flags = flags | 0x02   // なら，必ず+/-を付加する
    .END1:         ;  }}

    ; 符号出力判定
    test bx, 0b0010
    je .END2
        cmp ax, 0
        jge .ELSE3
            neg ax ; 符号反転
            mov [si], byte'-' ;バッファの先頭に'-'を入れる
            jmp .END3
        .ELSE3:
            mov [si], byte'+'
        .END3:
        dec cx ; size--; バッファサイズを符号の分だけ減らす
    .END2:

    ; ASCII変換
    mov bx, [bp + 10]   ; 基数
    .LOOP1:
        mov dx, 0
        div bx  ; edxを上位，eaxを下位とする64bitの値を引数で割って，商をeaxに，余りをedxに入れる

        mov si, dx
        mov dl, byte[.ascii + si]   ; その桁の数値に対応するasciiコード

        mov [di], dl
        dec di

        cmp ax, 0
        loopnz .LOOP1   ; cx(ecx)をカウンタとしてデクリメントし，cx!=0かつZF=0の場合にジャンプ

     ; 空欄を埋める
     cmp cx, 0
     je .END4
        mov al, ' '
        cmp [bp+12], word 0b100
        jne .END5
        mov al, '0'
        .END5:
        std ; ストリング命令のときのアドレス進行方向を示すDFレジスタを1（減算方向）に
        ; repプレフィックス：cx==0となるまで，cxのデクリメントと直後の命令を繰り返す
        ; stosb命令：alの値を[di]に書き込み，diを1バイト分だけ加算
        rep stosb
    .END4:

    pop di
    pop si
    pop dx
    pop cx
    pop bx
    pop ax

    mov sp, bp
    pop bp
    ret

.ascii: db "0123456789ABCDEF"

