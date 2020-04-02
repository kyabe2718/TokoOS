; \brief リングバッファからデータを読み出す
; \param buf リングバッファ    ebp + 8
; \param data 読み出したデータの保存先アドレス  ebp + 12
; \return データありorなし (1 or 0)
ring_rd:
    push ebp        ; ebp + 4
    mov ebp, esp    ; ebp + 0

    push ebx
    push esi
    push edi

    mov esi, [ebp + 8]  ; buf
    mov edi, [ebp + 12] ; data

    ; 読み込み位置確認
    mov eax, 0
    mov ebx, [esi + ring_buf.rp]
    cmp ebx, [esi + ring_buf.wp]        ; if(rp != wp)
    je .10E                             ; {

    mov al, [esi + ring_buf.item + ebx] ;   al = buf[rp]

    mov [edi], al                       ;   *data = al

    inc ebx                             ;   rp++
    and ebx, RING_INDEX_MASK            ;   rp %= RING_ITEM_SIZE
    mov [esi + ring_buf.rp], ebx        ;   buf.rp = rp

    mov eax, 1                          ;   return 1
.10E:                                   ; }

    pop edi
    pop esi
    pop ebx

    mov esp, ebp
    pop ebp

    ret

; \brief リングバッファに書き込む
; \param buf リングバッファ    ebp + 8
; \param data 書き込むデータ   ebp + 12
; \return 成功or失敗 (1 or 0)
ring_wr:
    push ebp        ; ebp + 4
    mov ebp, esp    ; ebp + 0

    push ebx
    push ecx
    push esi

    mov eax, 0
    mov ebx, [esi + ring_buf.wp]

    ; 次の書き込み位置を計算
    mov ecx, ebx
    inc ecx
    and ecx, RING_INDEX_MASK

    cmp ecx, [esi + ring_buf.rp]
    je .10E ; if(rp == wp) return 0;  // 書き込み失敗

    mov al, [ebp + 12]
    mov [esi + ring_buf.item + ebx], al
    mov [esi + ring_buf.wp], ecx
    mov eax, 1

.10E:

    pop esi
    pop ecx
    pop ebx

    mov esp, ebp
    pop ebp
    ret

; \brief ring_buf内のキーコードを表示
; \param col    ebp + 8
; \param row    ebp + 12
; \param buf    バッファ    ebp + 16
draw_key:
    push ebp        ; ebp + 4
    mov ebp, esp    ; ebp + 0

    pusha

    mov edx, [ebp + 8]              ; edx = X
    mov edi, [ebp + 12]             ; edi = Y
    mov esi, [ebp + 16]

    mov ebx, [esi + ring_buf.rp]    ; ebx = buf.rp
    lea esi, [esi + ring_buf.item]  ; esi = &buf[ebx]   // ring_bufの最初
    mov ecx, RING_ITEM_SIZE         ; ecx = RING_ITEM_SIZE

.10L:                               ; do {
    dec ebx                         ;       ebx--;
    and ebx, RING_INDEX_MASK        ;       ebx %= RING_ITEM_SIZE
    mov al, [esi + ebx]             ;       al = esi[ebx];

    cdecl itoa, eax, .tmp, 2, 16, 0b0100
    cdecl draw_str, edx, edi, 0x02, .tmp

    add edx, 3                      ;       edx += 3;

    loop .10L                       ; } while(ecx--);

    popa

    mov esp, ebp
    pop ebp
    ret

.tmp: db "-- ", 0

