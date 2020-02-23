
; \brief 読み込むプレーンを設定する
; \param plane 読み込みプレーン
vga_set_read_plane:
    push ebp
    mov ebp, esp
    push eax
    push edx

    mov ah, [ebp + 8]
    and ah, 0x03    ; 余計なビットをマスク
    mov al, 0x04    ; 読み込みマップ選択レジスタ
    mov dx, 0x03CE  ; グラフィックス制御ポート
    out dx, ax

    pop edx
    pop eax
    mov esp, ebp
    pop ebp
    ret


; \brief 書き込むプレーンを設定する
; \param plane 書き込みプレーン
vga_set_write_plane:
    push ebp
    mov ebp, esp
    push eax
    push edx

    mov ah, [ebp + 8]
    and ah, 0x0F    ; 余計なビットをマスク
    mov al, 0x02    ; マップマスクレジスタ
    mov dx, 0x03C4  ; シーケンサ制御ポート
    out dx, ax

    pop edx
    pop eax
    mov esp, ebp
    pop ebp
    ret


; \brief フォントデータをvramに書き込む
; \param font フォントアドレス                  ; + 8
; \param vram VRAMアドレス                      ; + 12
; \param plane 出力プレーン 下位1byteのみ有効   ; + 16
; \param color 描画色       （背景色2byte:前景色2byte）   ; + 20
vram_font_copy: ; (font, vram, plane, color)
    push ebp        ; + 4
    mov ebp, esp    ; + 0

    push esi
    push edi
    push eax
    push ebx
    push ecx
    push edx

    mov esi, [ebp + 8]  ; font
    mov edi, [ebp + 12] ; vram
    movzx eax, byte[ebp + 16]
    movzx ebx, word[ebp + 20]

    test bh, al ; zf = 背景色 & プレーン
    setz dh     ; dh = zf ? 0x01 : 0x00
    dec dh      ; 0x00 or 0xFF

    test bl, al ; zf = 前景色 & プレーン
    setz dl     ; dl = zf ? 0x01 : 0x00
    dec dl      ; 0x00 or 0xFF

    ; 16バイトフォントのコピー
    cld         ; df = 0
    mov ecx, 16 ; 縦16ドット
.10L:

    lodsb       ; al = *esi++
    mov ah, al
    not ah      ; ah = ~al

    ; 前景色
    and al, dl  ; al = 前景色 & フォント

    ; 背景色
    test ebx, 0x0010    ; if 透過モード
    jz .11F
    and ah, [edi]       ; ah = !フォント & [edi]（現在色）
    jmp .11E
    .11F:
    and ah, dh          ; ah = !フォント & 背景色
    .11E:

    or al, ah       ; 背景と前景を合成
    mov [edi], al   ; プレーンに出力

    add edi, 80 ; 1行が80byte
    loop .10L   ; while(--ecx)

    pop edx
    pop ecx
    pop ebx
    pop eax
    pop edi
    pop esi

    mov esp, ebp
    pop ebp
    ret
