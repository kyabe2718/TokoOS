; タイマ割り込み
int_timer:
    pusha   ; pushad
    push ds
    push es

    mov ax, 0x0010
    mov ds, ax
    mov es, ax

    ; TICK
    inc dword [TIMER_COUNT]  ; TIMER_CUNT++

    ; 割り込みフラグをクリア
    outp 0x20, 0x20 ; master PIC

    pop es
    pop ds
    popa    ; popad

    iret

ALIGN 4, db 0
TIMER_COUNT: dq 0

; タイマICのカウンタ0を設定
timer0_int_en:
    push eax

    ; カウンタ０ / 下位->上位で書き込み / 動作モード2 / 16bitバイナリカウンタ
    outp 0x43, 0b_00_11_010_0

    ; カウンタを0x2E9C(=11932)に設定
    outp 0x40, 0x9C
    outp 0x40, 0x2E

    pop eax

    ret
