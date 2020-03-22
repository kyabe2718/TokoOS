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

    cdecl draw_font, 63, 13
    cdecl draw_str, 25, 14, 0x010F, .s0
    cdecl draw_line, 0, 0, 500, 100, 0x0F

    cdecl itoa, 1234, .s1, 5, 10, 0b100
    cdecl draw_str, 25, 16, 0x010F, .s1

    jmp $

.s0: db " Hello, Kernel! ", 0
.s1: db "      ", 0


ALIGN 4, db 0
FONT_ADR: dd 0

%include "modules/protect/vga.asm"
%include "modules/protect/draw_char.asm"
%include "modules/protect/draw_str.asm"
%include "modules/protect/draw_pixel.asm"
%include "modules/protect/draw_line.asm"
%include "modules/protect/itoa.asm"

; パディング
times KERNEL_SIZE - ($ - $$) db 0
