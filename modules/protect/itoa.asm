
; \param value  値                 ebp + 8
; \param buf    バッファアドレス   ebp + 12
; \param size  バッファサイズ     ebp + 16
; \param base   基数               ebp + 20
; \param flag 下のビットから，符号付き整数として扱うか，"+/-"を付加するか，空白を0で埋めるか ebp + 24
itoa:   ; (value, buf, size, word flag)
    push ebp        ; ebp + 4
    mov ebp, esp    ; ebp + 0

    push eax
    push ebx
    push ecx
    push edx
    push esi
    push edi

    mov eax, [ebp + 8]  ; 変換元数値
    mov esi, [ebp + 12]  ; buf
    mov ecx, [ebp + 16]  ; size ひと桁ずつ表示するloopのカウンタになる

    mov edi, esi  ;
    add edi, ecx  ;
    dec edi      ; edi = &buf[size-1]; （この時点でesiはもう不要）

    mov ebx, [ebp + 24]   ; flag

    ; 符号付き判定
    test ebx, 0b001 ; if (flags & 0x01 != 0) // 値を符号付き整数として扱う
    je .END1       ; {
    cmp eax, 0      ;     if(val < 0)        // かつ，値が負である
    jge .END1      ;      {
    or ebx, 0b0010  ;          flags = flags | 0x02   // なら，必ず+/-を付加する
    .END1:         ;  }}

    ; 符号出力判定
    test ebx, 0b0010
    je .END2
        cmp eax, 0
        jge .ELSE3
            neg eax ; 符号反転
            mov [esi], byte'-' ;バッファの先頭に'-'を入れる
            jmp .END3
        .ELSE3:
            mov [esi], byte'+'
        .END3:
        dec ecx ; size--; バッファサイズを符号の分だけ減らす
    .END2:

    ; ASCII変換
    mov ebx, [ebp + 20]   ; 基数
    .LOOP1:
        mov edx, 0
        div ebx  ; eedxを上位，eeaxを下位とする64bitの値を引数で割って，商をeeaxに，余りをeedxに入れる

        mov esi, edx
        mov dl, byte[.ascii + esi]   ; その桁の数値に対応するasciiコード

        mov [edi], dl
        dec edi

        cmp eax, 0
    loopnz .LOOP1   ; ecx(eecx)をカウンタとしてデクリメントし，ecx!=0かつZF=0の場合にジャンプ

     ; 空欄を埋める
     cmp ecx, 0
     je .END4
        mov al, ' '
        cmp [ebp + 12], word 0b0100
        jne .END5
        mov al, '0'
        .END5:
        std ; ストリング命令のときのアドレス進行方向を示すDFレジスタを1（減算方向）に
        ; repプレフィックス：ecx==0となるまで，ecxのデクリメントと直後の命令を繰り返す
        ; stosb命令：alの値を[edi]に書き込み，ediを1バイト分だけ加算
        rep stosb
    .END4:

    pop edi
    pop esi
    pop edx
    pop ecx
    pop ebx
    pop eax

    mov esp, ebp
    pop ebp
    ret

.ascii: db "0123456789ABCDEF"

