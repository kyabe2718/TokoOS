int_keyboard:
    pusha
    push ds
    push es

    ; データ用セグメントセレクタ
    mov ax, 0x0010
    mov ds, ax
    mov es, ax

    in al, 0x60 ; alにキーコードの取得

    cdecl ring_wr, _KEY_BUF, eax

    outp 0x20, 0x20 ; マスタPICにEOI

    pop es
    pop ds
    popa

    iret

ALIGN 4, db 0
_KEY_BUF: times ring_buf_size db 0  ; sizeof(ring_buf) * sizeof(byte)

