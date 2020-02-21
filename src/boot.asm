
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

; 最初の512bytesに含めるモジュール
%include "modules/real/puts.asm"
%include "modules/real/reboot.asm"
%include "modules/real/read_chs.asm"

    ; boot flag
    times   510 - ($ - $$) db 0x00  ;
    db      0x55, 0xAA              ; BIOSの開始フラグ

; リアルモード時に取得した情報
FONT:
.seg: dw 0
.off: dw 0
ACPI_DATA:
.adr: dd 0
.len: dd 0

; 最初の512bytesに含めなくてもよいモジュール
%include "modules/real/itoa.asm"
%include "modules/real/get_drive_param.asm"
%include "modules/real/get_font_adr.asm"
%include "modules/real/get_mem_info.asm"
%include "modules/real/kbc.asm"
%include "modules/real/read_lba.asm"

stage_2:
    cdecl puts,  .Message

    ; ドライブ情報を取得
    cdecl get_drive_param, BOOT
    cmp ax, 0
    jne .10E
    cdecl puts, .GetDriveParameterError
    call reboot
    .10E:

    ; ドライブ情報の表示
    mov ax, [BOOT + drive.no]
    cdecl itoa, ax, .p2, 2, 16, 0b0100
    mov ax, [BOOT + drive.cyln]
    cdecl itoa, ax, .p3, 4, 16, 0b0100
    mov ax, [BOOT + drive.head]
    cdecl itoa, ax, .p4, 2, 16, 0b0100
    mov ax, [BOOT + drive.sect]
    cdecl itoa, ax, .p5, 2, 16, 0b0100
    cdecl puts, .p1

    jmp stage_3rd

.p1: db " Drive:0x"
.p2: db "  , C:0x"
.p3: db "    , H:0x"
.p4: db "  , S:0x"
.p5: db "  ", 0x0A, 0x0D, 0
.Message: db"2nd Stage...", 0x0A, 0x0D, 0
.GetDriveParameterError: db"Can't get drive parameter", 0x0A, 0x0D, 0

stage_3rd:
    cdecl puts, .Message

    ; BIOSのフォントアドレスの取得
    cdecl get_font_adr, FONT

    ; フォントアドレスの表示
    cdecl itoa, word[FONT.seg], .p1, 4, 16, 0b0100
    cdecl itoa, word[FONT.off], .p2, 4, 16, 0b0100
    cdecl puts, .s1

    ; メモリ情報の取得と表示
    cdecl get_mem_info

    mov eax, [ACPI_DATA.adr]
    cmp eax, 0
    je .10E

    cdecl itoa, ax, .p4, 4, 16, 0b0100
    shr eax, 16
    cdecl itoa, ax, .p3, 4, 16, 0b0100

    cdecl puts, .s2
.10E:

    jmp stage_4

.Message: db"3rd Stage...", 0x0A, 0x0D, 0

.s1: db" Font Address="
.p1: db"    :"
.p2: db"    ", 0x0A, 0x0D, 0

.s2: db" ACPI data="
.p3: db"    "
.p4: db"    ", 0x0A, 0x0D, 0

stage_4:
    cdecl puts, .Message

    ; A20の有効化
    cli ; 割り込み禁止

    cdecl KBC_Cmd_Write, 0xAD ; disable keyboard

    cdecl KBC_Cmd_Write, 0xD0 ; read from input
    cdecl KBC_Data_Read, .key ; get data

    mov bl, [.key]
    or bl, 0x02

    cdecl KBC_Data_Write, bx  ;
    cdecl KBC_Cmd_Write, 0xD1 ; write to output

    cdecl KBC_Cmd_Write, 0xAE ; enable keyboard

    sti ; 割り込み許可

    cdecl puts, .Enabled

    jmp stage_5

.Message: db"4th Stage...", 0x0A, 0x0D, 0
.Enabled: db" A20 Gate Enabled.", 0x0A, 0x0D, 0

.key: dw 0

stage_5:
    cdecl puts, .Message

    cdecl read_lba, BOOT, BOOT_SECT, KERNEL_SECT, BOOT_END
    cmp ax, KERNEL_SECT
    jz .10E
    cdecl puts, .Error
    call reboot
    .10E:

    jmp stage_6

.Message: db"5th Stage...", 0x0A, 0x0D, 0
.Error: db"Failed to load kernel...", 0x0A, 0x0D, 0

stage_6:
    cdecl puts, .Message

    cdecl puts, .KeyWait

    ; キー入力待ち（space）
    .10L:
    mov ah, 0x00
    int 0x16
    cmp al, ' '
    jne .10L

    ; ビデオモードの設定
    mov ax, 0x0012
    int 0x10

    jmp $

.Message: db"6th Stage...", 0x0A, 0x0D, 0
.KeyWait: db"Please press space key to change to video mode...", 0x0A, 0x0D, 0

EndMessage: db "End...", 0x0A, 0x0D, 0


; パディング
times   BOOT_SIZE - ($ - $$) db 0x00  ;8Kバイト

