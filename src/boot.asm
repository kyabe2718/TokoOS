BOOT_LOAD equ 0x7C00    ; ブートプログラムのロード位置
ORG BOOT_LOAD           ; ロードアドレスをアセンブラに指示

; include マクロ
%include "include/macro.asm"

entry:
    ; BIOS Parameter Block
    ; とりあえず90バイトのNOP
    jmp  ipl  ; iplへ
    times   90 - ($ - $$) db 0x90  ;

    ; Initial Program Loader
ipl:
    ; スタックポインタや割り込みの設定をしている最中に割り込みされると上手く動かない
    cli     ; 割り込みの禁止

    mov ax, 0x0000
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, BOOT_LOAD

    sti     ; 割り込みの許可

    mov [BOOT.DRIVE], dl; ブートドライブを保存

    cdecl itoa, 8086, .buf, 8, 10, 0b0001
    cdecl puts, .buf

    cdecl itoa, 8086, .buf, 8, 10, 0b0011
    cdecl puts, .buf


    cdecl itoa, -8086, .buf, 8, 10, 0b0001
    cdecl puts, .buf

    cdecl itoa, -8086, .buf, 8, 10, 0b0011
    cdecl puts, .buf

    ; 処理の終了
    jmp $   ; while(1)


.BootMessage: db "Booting...", 0x0A, 0x0D, 0 ; 0x0AはLF, 0x0DはCR
.buf: db "--------", 0x0A, 0x0D, 0

ALIGN 2, db 0
BOOT:
.DRIVE: dw 0


; モジュール
%include "modules/real/libio.asm"

    ; boot flag
    times   510 - ($ - $$) db 0x00  ;
    db      0x55, 0xAA              ; BIOSの開始フラグ



