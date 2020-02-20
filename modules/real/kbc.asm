; kbcにデータを書き込む
KBC_Data_Write:; (data)
    push bp
    mov  bp, sp
    push cx
    mov cx, 0

.10L:
    ; kbcとの通信用8bitレジスタが0x60, 0x64にマップされる
    ; 0x60  データのやり取りを行なう
    ; 0x64  ステータス情報を得たり，制御コマンドを送る
    in   al, 0x64   ; kbcのステータスコードをalに
    test al, 0x02   ; 書き込み可能？
    loopnz  .10L

    cmp cx, 0   ; リトライ数+1，0なので最大回数
    jz  .20E

    mov al, [bp + 4]    ; データ
    out 0x60, al    ; out(port=0x60, data=al)
.20E:

    mov ax, cx  ; return cx

    pop cx
    mov sp, bp
    pop bp
    ret

KBC_Data_Read: ; (data)
    push bp
    mov  bp, sp
    push cx
    push di

    mov cx, 0

.10L:
    in   al, 0x64
    test al, 0x01 ; readable?
    loopz .10L

    cmp cx, 0
    jz .20E

    mov ah, 0x00
    in  al, 0x60    ; al = in(port=0x60)

    mov di, [bp + 4]
    mov [di + 0], ax
.20E:

    mov ax, cx  ; return cx

    pop di
    pop cx
    mov sp, bp
    pop bp
    ret

KBC_Cmd_Write: ;(cmd)
    push bp
    mov  bp, sp
    push cx

    mov cx, 0
.10L:
    ; kbcとの通信用8bitレジスタが0x60, 0x64にマップされる
    ; 0x60  データのやり取りを行なう
    ; 0x64  ステータス情報を得たり，制御コマンドを送る
    in   al, 0x64   ; kbcのステータスコードをalに
    test al, 0x02   ; 書き込み可能？
    loopnz  .10L

    cmp cx, 0   ; リトライ数+1，0なので最大回数
    jz  .20E

    mov al, [bp + 4]    ; データ
    out 0x64, al    ; out(port=0x64, data=al)
.20E:

    mov ax, cx  ; return cx

    pop cx
    mov sp, bp
    pop bp
    ret

