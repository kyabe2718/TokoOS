
get_drive_param:

    push bp
    mov bp, sp

    push bx
    push cx
    push es
    push si
    push di

    mov si, [bp + 4]
    mov ax, 0
    ; es:di set to 0000h:0000h to work around some buggy BIOS
    mov es, ax
    mov di, ax

    ; int 0x13の引数
    mov ah, 8   ; read drive parameter
    mov dl, [si + drive.no] ; 読み込むドライブの番号
    int 0x13
    jc .10F
    ; 返り値
    ; EFLAGSのCFビットは成功なら0，失敗なら1
    ; ah: エラーコード．成功なら0x00
    ; dl: ドライブ数
    ; dh: 最終ヘッドのインデックス．（ヘッド数-1）
    ; ch: tttttttt  最大トラック数-1の下位8ビット
    ; cl: ttssssss  最大トラック数-1の上位2ビット/最大セクタ数（6ビット）
    ; bh: 0x00固定
    ; bl: drive type（フロッピーのみ）
    ; es:dl ドライブパラメータへのポインタ（フロッピーのみ）

    mov al, cl
    and ax, 0x3F ; マスクして最大セクタ数のみ取得

    shr cl, 6   ; 論理シフトなので，空いたビットは0埋めされる
    ror cx, 8   ; ビットを右回りに回転させる
    inc cx      ; 最大トラック数-1を最大トラック数に

    movzx bx, dh; 符号拡張
    inc bx      ; dhはヘッド数-1だからヘッド数にする

    mov [si + drive.cyln], cx
    mov [si + drive.head], bx
    mov [si + drive.sect], ax

    jmp .10E

    .10F:
    mov ax, 0   ; 失敗
    .10E:

    pop di
    pop si
    pop es
    pop cx
    pop bx

    mov sp, bp
    pop bp

    ret

