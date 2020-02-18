
; include マクロ
%include "include/define.asm"
%include "include/macro.asm"

; BIOSはブートプログラムをBOOT_LOAD(0x7C00)に展開するので，それをアセンブラに指示
ORG BOOT_LOAD

entry:
    ; BIOS Parameter Block
    ; とりあえず90バイトのNOP
    jmp  ipl  ; iplへ
    times   90 - ($ - $$) db 0x90  ; 0x90はnop命令

    ; Initial Program Loader
ipl:
    ; スタックポインタや割り込みの設定をしている最中に割り込みされると上手く動かない
    cli     ; 割り込みの禁止

    ; スタックポインタやレジスタの設定
    mov ax, 0x0000
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, BOOT_LOAD

    sti     ; 割り込みの許可

    mov [BOOT + drive.no], dl; ブートドライブを保存

    ; BootMessageを表示
    cdecl puts, .BootMessage

    ; 残りのセクタを読み込む
    mov bx, BOOT_SECT - 1
    mov cx, BOOT_LOAD + SECT_SIZE

    cdecl read_chs, BOOT, bx, cx

    cmp ax, bx
    jz .10E
    cdecl puts, .SectorReadError
    call reboot
    .10E:

    ; 次のステージへ移行
    jmp stage_2

.BootMessage: db "Boot...", 0x0A, 0x0D, 0 ; 0x0AはLF, 0x0DはCR
.SectorReadError: db "Error:sector read", 0 ; 0x0AはLF, 0x0DはCR

ALIGN 2, db 0
BOOT:
    istruc drive
       at  drive.no,      dw 0
       at  drive.cyln,    dw 0
       at  drive.head,    dw 0
       at  drive.sect,    dw 2 ; セクタは1-index
    iend

; モジュール
%include "modules/real/libio.asm"
%include "modules/real/libsystem.asm"

    ; boot flag
    times   510 - ($ - $$) db 0x00  ;
    db      0x55, 0xAA              ; BIOSの開始フラグ


stage_2:
    cdecl puts,  .Message

    jmp $   ; while(1)

.Message: db"2nd Stage...", 0x0A, 0x0D, 0

    times   BOOT_SIZE - ($ - $$) db 0x00  ;8Kバイト
