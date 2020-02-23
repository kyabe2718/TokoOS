
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

