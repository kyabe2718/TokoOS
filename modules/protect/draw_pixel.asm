
; \brief 画面上にピクセルを表示
; \param X X座標      ; ebp + 8
; \param Y Y座標      ; ebp + 12
; \param color 描画色 ; ebp + 16
draw_pixel: ; (X, Y, color)
    push ebp     ; ebp + 4
    mov ebp, esp ; ebp + 0

    push edi
    push eax
    push ebx
    push ecx

    mov ebx, [ebp + 8]
    mov ecx, [ebp + 12]

    mov edi, ecx
    shl edi, 4
    lea edi, [edi * 4 + edi + 0xA0000]

    mov ecx, ebx
    shr ebx, 3
    add edi, ebx    ; この時点でediはVRAMのアドレスを指す

    ; VRAMのアドレッシングが1byteなので，アクセスするbit位置を特定する
    and ecx, 0x07   ; ecxはediの指す1byte中の何bit目かを示す
    mov ebx, 0x80   ; 0x80 == 0b10000000
    shr ebx, cl     ; bxの8桁のうち該当bitだけ1が立つ．つまりマスクデータ

    mov ecx, [ebp + 16]

    ; プレーン毎に出力
    cdecl vga_set_read_plane, 0x03
    cdecl vga_set_write_plane, 0x08
    cdecl vram_bit_copy, ebx, edi, 0x08, ecx

    cdecl vga_set_read_plane, 0x02
    cdecl vga_set_write_plane, 0x04
    cdecl vram_bit_copy, ebx, edi, 0x04, ecx

    cdecl vga_set_read_plane, 0x01
    cdecl vga_set_write_plane, 0x02
    cdecl vram_bit_copy, ebx, edi, 0x02, ecx

    cdecl vga_set_read_plane, 0x00
    cdecl vga_set_write_plane, 0x01
    cdecl vram_bit_copy, ebx, edi, 0x01, ecx

    pop ecx
    pop ebx
    pop eax
    pop edi

    mov esp, ebp
    pop ebp
    ret