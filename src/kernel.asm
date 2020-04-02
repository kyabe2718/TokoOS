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

    cdecl init_int  ; 割り込みベクタの初期化
    cdecl init_pic  ; 割り込みコントローラの初期化

    set_vect 0x00, int_zero_div ; 0除算の割り込みを設定
    set_vect 0x21, int_keyboard ; KBC割り込み
    set_vect 0x28, int_rtc  ; RTC割り込み

    ; デバイスの割り込み許可
    cdecl rtc_int_en, 0x10  ; 更新サイクル終了割り込み許可

    ; 割り込みマスクレジスタの設定
;    outp 0x21, 0b1111_1011  ; 割り込みの有効化 slave PIC
    outp 0x21, 0b1111_1001  ; 割り込みの有効化 slave PIC / KBC
    outp 0xA1, 0b1111_1110  ; 割り込みの有効化 RTC

    sti

    ; 色々描いてみる
    cdecl draw_font, 63, 13
    cdecl draw_str, 25, 14, 0x010F, .s0
;    cdecl draw_line, 0, 0, 500, 100, 0x0F

    ; 時刻の表示
.10L:
    mov eax, [RTC_TIME]
    cdecl draw_time, 72, 0, 0x0700, eax

    cdecl ring_rd, _KEY_BUF, .int_key
    cmp eax, 0
    je .10E
    cdecl draw_key, 2, 29, _KEY_BUF
.10E:
    jmp .10L

.s0: db " Hello, Kernel! ", 0

ALIGN 4, db 0
.int_key: dd 0

ALIGN 4, db 0
FONT_ADR: dd 0
RTC_TIME: dd 0

%include "modules/protect/vga.asm"
%include "modules/protect/draw_char.asm"
%include "modules/protect/draw_str.asm"
%include "modules/protect/draw_pixel.asm"
%include "modules/protect/draw_line.asm"
%include "modules/protect/itoa.asm"
%include "modules/protect/rtc.asm"
%include "modules/protect/draw_time.asm"
%include "modules/protect/interrupt.asm"
%include "modules/protect/pic.asm"
%include "modules/protect/int_rtc.asm"
%include "modules/protect/ring_buf.asm"
%include "modules/protect/int_keyboard.asm"

; パディング
times KERNEL_SIZE - ($ - $$) db 0
