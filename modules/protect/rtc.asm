
; \brief 現在時刻の取得
; \param dst 保存先アドレス
; \return 成功（0以外） or 失敗（0）
; \note dstには 0*:hour[12-8]:min[7-4]:sec[3-0]が格納される．
rtc_get_time: ; (dst)
    push ebp
    mov ebp, esp

    ; 時刻データが更新中や更新予定であれば失敗
    mov al, 0x0A
    out 0x70, al
    in al, 0x71
    test al, 0x80

    je .10F
    mov eax, 1
    jmp .10E

.10F:
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

    mov eax, 0
.10E:

    mov esp, ebp
    pop ebp
    ret


