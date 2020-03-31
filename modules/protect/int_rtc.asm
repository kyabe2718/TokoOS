
; RTC_TIMEにrtcを保存する
; rtcが更新された割り込みで呼ばれるように設定する
int_rtc:
    pusha
    push ds
    push es

    ; セグメントディスクリプタをグローバルセグメントディスクリプタテーブル(GDT)の0x0010番目（データ用セグメントディスクリプタ）に
    mov ax, 0x0010
    mov ds, ax
    mov es, ax

    cdecl rtc_get_time, RTC_TIME

    ; RTCのレジスタC（割り込み要因）を読み出す
    ; 読み出すことで同時にRTCのレジスタCはクリアされる
    outp 0x70, 0x0C
    in al, 0x71

    ; 割り込みフラグをクリア
    ; 忘れると2回目以降の割り込みが発生しない
    mov al, 0x20    ; EOI (End Of Interrupt) コマンド
    out 0xA0, al    ; slave PIC
    out 0x20, al    ; master PIC

    pop es
    pop ds
    popa

    iret

; \brief RTCの割り込み有効化
; \param bit        ; ebp + 8
rtc_int_en:
    push ebp        ; ebp + 4
    mov ebp, esp    ; ebp + 0

    outp 0x70, 0x0B

    in al, 0x71
    or al, [ebp + 8]

    out 0x71, al

    mov esp, ebp
    pop ebp
    ret

