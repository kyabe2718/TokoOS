
; \brief 現在時刻の取得
; \param dst 保存先アドレス
; \return 成功（0以外） or 失敗（0）
rtc_get_time: ; (dst)
    push ebp
    mov ebp, esp

    ; 0x70にコードを出力し，0x71から取得する
    ; コードは0x00（秒），0x02（分），0x04（時）など

    mov al, 0x04
    out 0x70, al
    in al, 0x71

    shl eax, 8

    mov al, 0x02
    out 0x70, al
    in al, 0x71

    shl eax, 8

    mov al, 0x00
    out 0x70, al
    in al, 0x71

    and eax, 0x00FFFFFF ; 下位3byteのみ有効

    mov ebx, [ebp + 8]
    mov [ebx], eax  ; *dst = 時刻

    mov esp, ebp
    pop ebp
    ret



draw_time: ;(row, col, color, time)
    ret
