
BOOT_SIZE equ (1024 * 8)    ; ブートコードサイズ
KERNEL_SIZE equ (1024 * 8)    ; カーネルサイズ

BOOT_LOAD equ 0x7C00    ; ブートプログラムのロード位置
BOOT_END equ (BOOT_LOAD + BOOT_SIZE)

SECT_SIZE equ (512)         ; セクタサイズ
BOOT_SECT equ (BOOT_SIZE / SECT_SIZE)   ; ブートプログラムのセクタ数
KERNEL_SECT equ (KERNEL_SIZE / SECT_SIZE)

E820_RECORD_SIZE equ 20 ; BIOSから取得したメモリ情報を格納する領域のサイズ

KERNEL_LOAD equ 0x0010_1000

VECT_BASE equ 0x0010_0000   ; 1つの割り込みゲートディスクリプタは8byte，255個，0x0010_0000から0x0010_07FFまで

