
; \param row   列（0~79） ; + 8
; \param col   行（0~29） ; + 12
; \param color 色 ; + 16
; \param ch    文字コード ; + 20
draw_char: ; (row, col ,color, ch)
    push ebp        ; + 4
    mov ebp, esp    ; + 0

    push esi
    push edi
    push ebx

    movzx esi, byte[ebp + 20]
    shl esi, 4
    add esi, [FONT_ADR]

    mov edi, [ebp + 12] ; 行
    shl edi, 8
    lea edi, [edi * 4 + edi + 0xA0000]
    add edi, [ebp + 8]  ; 列
    ; edi = 640 * 行 + 列

    movzx ebx, word [ebp + 16]
    cdecl vga_set_read_plane, 0x03
    cdecl vga_set_write_plane, 0x08
    cdecl vram_font_copy, esi, edi, 0x08, ebx

    cdecl vga_set_read_plane, 0x02
    cdecl vga_set_write_plane, 0x04
    cdecl vram_font_copy, esi, edi, 0x04, ebx

    cdecl vga_set_read_plane, 0x01
    cdecl vga_set_write_plane, 0x02
    cdecl vram_font_copy, esi, edi, 0x02, ebx

    cdecl vga_set_read_plane, 0x00
    cdecl vga_set_write_plane, 0x01
    cdecl vram_font_copy, esi, edi, 0x01, ebx

    pop ebx
    pop edi
    pop esi

    mov esp, ebp
    pop ebp
    ret

; \param row 列 + 8
; \param col 行 + 12
draw_font:  ; (row, col)
    push ebp        ; + 4
    mov ebp, esp    ; + 0

    push esi
    push edi
    push eax
    push ebx
    push ecx
    push edx

    mov esi, [ebp + 8]
    mov edi, [ebp + 12]

    mov ecx, 0
.10L:
    cmp ecx, 256
    jae .10E

    mov eax, ecx
    and eax, 0x0F   ; 16x16で表示するため，eaxのhex表示で下一桁を列に
    add eax, esi

    mov ebx, ecx
    shr ebx, 4  ; hex表示で二桁目
    add ebx, edi

    cdecl draw_char, eax, ebx, 0x0007, ecx

    inc ecx
    jmp .10L
.10E:

    pop edx
    pop ecx
    pop ebx
    pop eax
    pop edi
    pop esi

    mov esp, ebp
    pop ebp
    ret
