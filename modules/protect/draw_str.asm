
; \brief 文字列を描画
; \param col    ebp + 8
; \param row    ebp + 12
; \param color  描画色 ebp + 16
; \param str    文字列のアドレス ebp + 20
draw_str:   ; (row, col, color, str)
    push ebp        ; ebp + 4
    mov ebp, esp    ; ebp + 0

    push esi
    push eax
    push ebx
    push ecx
    push edx

    mov ecx, [ebp + 8]  ; x
    mov edx, [ebp + 12] ; y
    movzx ebx, word[ebp + 16]
    mov esi, [ebp + 20]

    cld ; df = 0
.10L:
    lodsb       ; al = *esi++
    cmp al, 0   ; if(al == 0) break;
    je .10E

    cdecl draw_char, ecx, edx, ebx, eax

    ; 表示位置更新
    inc ecx
    cmp ecx, 80
    jl .12E
    mov ecx, 0
    inc edx
    cmp edx, 30
    jl .12E
    mov edx, 0
.12E:

    jmp .10L
.10E:

    pop edx
    pop ecx
    pop ebx
    pop eax
    pop esi

    mov esp, ebp
    pop ebp
    ret
