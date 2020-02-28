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
;    cdecl draw_char, 1, 0, 0x010F, 'B'
;    cdecl draw_char, 2, 0, 0x020F, 'C'

    cdecl draw_font, 63, 13

    cdecl draw_str, 25, 14, 0x010F, .s0

;    cdecl draw_char, 0, 0, 0x0402, '0'
;    cdecl draw_char, 1, 0, 0x0212, '1'
;    cdecl draw_char, 2, 0, 0x0212, '-'

;    cdecl draw_pixel, 8, 4, 0x01
;    cdecl draw_pixel, 9, 5, 0x01
;    cdecl draw_pixel, 10, 6, 0x02
;    cdecl draw_pixel, 11, 7, 0x02
;    cdecl draw_pixel, 12, 8, 0x03
;    cdecl draw_pixel, 13, 9, 0x03
;    cdecl draw_pixel, 14, 10, 0x04
;    cdecl draw_pixel, 15, 11, 0x04
;
;
;    cdecl draw_pixel, 15, 4, 0x01
;    cdecl draw_pixel, 14, 5, 0x01
;    cdecl draw_pixel, 13, 6, 0x02
;    cdecl draw_pixel, 12, 7, 0x02
;    cdecl draw_pixel, 11, 8, 0x03
;    cdecl draw_pixel, 10, 9, 0x03
;    cdecl draw_pixel, 9, 10, 0x04
;    cdecl draw_pixel, 8, 11, 0x04

    cdecl draw_line, 0, 0, 500, 100, 0x0F

    jmp $

.s0: db " Hello, Kernel! ", 0


ALIGN 4, db 0
FONT_ADR: dd 0

%include "modules/protect/vga.asm"
%include "modules/protect/draw_char.asm"
%include "modules/protect/draw_str.asm"
%include "modules/protect/draw_pixel.asm"
%include "modules/protect/draw_line.asm"

; パディング
times KERNEL_SIZE - ($ - $$) db 0
