
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


; \brief 時刻の描画
; \param row 列 ebp + 8
; \param col 行 ebp + 12
; \param color 描画色 ebp + 16
; \param time 時刻データ ebp + 20
draw_time: ;(row, col, color, time)
    push ebp
    mov ebp, esp

    mov eax, [ebp + 20] ; 時刻データ
    movzx ebx, al
    cdecl itoa, ebx, .sec, 2, 16, 0b0100

    mov bl, ah
    cdecl itoa, ebx, .min, 2, 16, 0b0100

    shr eax, 16
    cdecl itoa, eax, .hour, 2, 16, 0b0100

    cdecl draw_str, dword[ebp + 8], dword[ebp + 12], dword[ebp + 16], .hour

    mov esp, ebp
    pop ebp
    ret

.hour: db "ZZ:"
.min:  db "ZZ:"
.sec:  db "ZZ:"
