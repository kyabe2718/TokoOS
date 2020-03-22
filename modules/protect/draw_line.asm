
; \brief 始点と終点を指定して直線を引く
; \param X0     ebp + 8
; \param Y0     ebp + 12
; \param X1     ebp + 16
; \param Y1     ebp + 20
; \param color  ebp + 24
draw_line:
    push ebp        ; ebp + 4
    mov ebp, esp    ; ebp + 0

    push dword 0    ; ebp - 4   = sum
    push dword 0    ; ebp - 8   = x0
    push dword 0    ; ebp - 12   = dx
    push dword 0    ; ebp - 16   = inc_x
    push dword 0    ; ebp - 20   = y0
    push dword 0    ; ebp - 24   = dy
    push dword 0    ; ebp - 28   = inc_y

    ; x軸の計算
    ; ebx = |X1 - X0|
    ; esi = sgn(X1 - X0)
    mov eax, [ebp + 8]
    mov ebx, [ebp + 16]
    sub ebx, eax    ; ebx = X1 - X0
    jge .10F
    neg ebx
    mov esi, -1
    jmp .10E
.10F:
    mov esi, 1
.10E:

    ; y軸の計算
    ; edx = |Y1 - Y0|
    ; edi = sgn(Y1 - Y0)
    mov ecx, [ebp + 12]
    mov edx, [ebp + 20]
    sub edx, ecx
    jge .20F
    neg edx
    mov edi, -1
    jmp .20E
.20F:
    mov edi, 1
.20E:

    ; x軸
    mov [ebp - 8], eax  ; 開始座標
    mov [ebp - 12], ebx ; 描画幅
    mov [ebp - 16], esi ; 増加方向

    ; y軸
    mov [ebp - 20], ecx ; 開始座標
    mov [ebp - 24], edx ; 描画幅
    mov [ebp - 28], edi ; 増加方向

    ; 基準軸（長さが長い方の軸）の決定
    ; esiが基準軸，ediが相対軸
    cmp ebx, edx
    jg .22F
    lea esi, [ebp - 20]
    lea edi, [ebp - 8]
    jmp .22E
.22F:
    lea esi, [ebp - 8]
    lea edi, [ebp - 20]
.22E:

    ; 基準軸の長さが0の場合，1にする
    mov ecx, [esi - 4]
    cmp ecx, 0
    jnz .30E
    mov ecx, 1
.30E:

    ; 線の描画
.50L:
    cdecl draw_pixel, dword [ebp - 8], dword [ebp - 20], dword[ebp + 24]

    mov eax, [esi - 8]  ; 基準軸の描画方向
    add [esi - 0], eax  ; 描画位置を更新

    mov eax, [ebp - 4]
    add eax, [edi - 4]  ; eax = sum + dy（相対軸の増分）

    mov ebx, [esi - 4]  ; ebx = dx （基準軸の増分）

    cmp eax, ebx        ; 積算値 <= 基準軸の増分
    jl .52E
    sub eax, ebx        ; eax -= dx
    mov ebx, [edi - 8]  ;
    add [edi - 0], ebx  ; 相対軸の描画位置を更新
.52E:

    mov [ebp - 4], eax ; sum = eax

    loop .50L
.50E:

    mov esp, ebp
    pop ebp
    ret