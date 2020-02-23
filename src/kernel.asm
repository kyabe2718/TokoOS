%include "include/define.asm"
%include "include/macro.asm"


ORG KERNEL_LOAD

[BITS 32]   ; 32bitコードを生成する

; エントリポイント
kernel:

    mov esi, BOOT_LOAD + SECT_SIZE
    movzx eax, word [esi + 0]   ; FONT.seg
    movzx ebx, word [esi + 2]   ; FONT.off
    ; リアルモードでのセグメント:オフセット形式を普通のアドレスに
    shl eax, 4
    add eax, ebx
    mov [FONT_ADR], eax ; FONT_ADRに保存し直す

    mov ah, 0x07    ; 書き込みプレーンを 赤+緑+青 に
    mov al, 0x02    ; マップマスクレジスタ 全ての書き込みプレーンから出力
    mov dx, 0x03C4  ; シーケンサ制御ポート
    out dx, ax

    mov [0x000A_0000 + 0], byte 0xFF

    mov ah, 0x04
    out dx, ax
    mov [0x000A_0000 + 1], byte 0xFF

    mov ah, 0x02
    out dx, ax
    mov [0x000A_0000 + 2], byte 0xFF

    mov ah, 0x01
    out dx, ax
    mov [0x000A_0000 + 3], byte 0xFF

    ; 画面を横切る橫線
    mov ah, 0x02
    out dx, ax
    lea edi, [0x000A_0000 + 80] ; edi = 0x000A_0000 + 80
    mov ecx, 80
    mov al, 0xFF
    rep stosb

    ; 2行目に8ドットの矩形
    ; 白色に設定
    mov ah, 0x07
    mov al, 0x02    ; マップマスクレジスタ 全ての書き込みプレーンから出力
    out dx, ax

    mov edi, 1  ; 行数
    shl edi, 8
    lea edi, [edi * 4 + edi + 0xA_0000] ; VRAMアドレス n行目に出力するときのオフセットは640*n．（画面サイズが640*480なので）

    mov [edi + (80 * 0)], word 0xFF
    mov [edi + (80 * 1)], word 0xFF
    mov [edi + (80 * 2)], word 0xFF
    mov [edi + (80 * 3)], word 0xFF
    mov [edi + (80 * 4)], word 0xFF
    mov [edi + (80 * 5)], word 0xFF
    mov [edi + (80 * 6)], word 0xFF
    mov [edi + (80 * 7)], word 0xFF

    ; 3行目に文字を描画
    mov esi, 'A'
    shl esi, 4
    add esi, [FONT_ADR] ; 一つのフォントは16byte

    mov edi, 2
    shl edi, 8
    lea edi, [edi * 4 + edi + 0xA_0000]

    mov ecx, 16
.10L:
    movsb   ; *edi++ <- *esi++
    add edi, 80 - 1
    loop .10L   ; while(--ecx)

    cdecl draw_char, 0, 0, 0x010F, 'A'
    cdecl draw_char, 1, 0, 0x010F, 'B'
    cdecl draw_char, 2, 0, 0x010F, 'C'

    cdecl draw_char, 0, 0, 0x010F, '0'
    cdecl draw_char, 1, 0, 0x010F, '1'
    cdecl draw_char, 2, 0, 0x010F, '-'

    jmp $


ALIGN 4, db 0
FONT_ADR: dd 0

%include "modules/protect/vga.asm"
%include "modules/protect/draw_char.asm"

; パディング
times KERNEL_SIZE - ($ - $$) db 0
