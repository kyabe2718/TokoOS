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

;    cdecl draw_char, 0, 0, 0x010F, 'A'
    cdecl draw_char, 1, 0, 0x010F, 'B'
    cdecl draw_char, 2, 0, 0x020F, 'C'

    cdecl draw_font, 63, 13

    cdecl draw_char, 0, 0, 0x0402, '0'
    cdecl draw_char, 1, 0, 0x0212, '1'
    cdecl draw_char, 2, 0, 0x0212, '-'

    jmp $


ALIGN 4, db 0
FONT_ADR: dd 0

%include "modules/protect/vga.asm"
%include "modules/protect/draw_char.asm"

; パディング
times KERNEL_SIZE - ($ - $$) db 0
