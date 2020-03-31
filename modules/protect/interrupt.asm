ALIGN 4
IDTR: dw 8 * 256 - 1
      dd VECT_BASE

; 割り込みゲートディスクリプタの作成
init_int:
    push eax
    push ebx
    push ecx
    push edi

    ; デフォルトの割り込みにデフォルト処理を設定
    ; 割り込みゲートディスクリプタの構造は以下
    ; offset[31:16] | P DPL DT TYPE 0 0 | segment selector | offset[15:0]
    ; P 1bit 割り込み処理がメモリ上に存在するか
    ; DPL 2bit 特権レベル
    ; DT 1bit ディスクリプタタイプ
    ; TYPE 4bit
    ; segment selector カーネルコード用セグメントセレクタは0x0008
    lea eax, [int_default]
    mov ebx, 0x0008_8E00    ;
    xchg ax, bx ; axとbxのデータを入れ替える

    mov ecx, 256        ; 割り込みベクタ数
    mov edi, VECT_BASE  ; 割り込みベクタテーブル

.10L:
    mov [edi + 0], ebx  ; 割り込みディスクリプタ下位
    mov [edi + 4], eax  ; 割り込みディスクリプタ上位

    add edi, 8
    loop .10L

    lidt [IDTR] ; 割り込みディスクリプタテーブルをロード

    pop edi
    pop ecx
    pop ebx
    pop eax
    ret

; スタックの上から4つを表示して停止
; error codeなしだと EIP, CS, EFLAGS
; error codeありだと ERROE CODE, EIP, CS, EFLAGS
; がスタックに積まれる
int_stop:
    cdecl draw_str, 25, 15, 0x060F, eax

    mov eax, [esp + 0]
    cdecl itoa, eax, .p1, 8, 16, 0b0100

    mov eax, [esp + 4]
    cdecl itoa, eax, .p2, 8, 16, 0b0100

    mov eax, [esp + 8]
    cdecl itoa, eax, .p3, 8, 16, 0b0100

    mov eax, [esp + 12]
    cdecl itoa, eax, .p4, 8, 16, 0b0100

    cdecl draw_str, 25, 16, 0x0F04, .s1
    cdecl draw_str, 25, 17, 0x0F04, .s2
    cdecl draw_str, 25, 18, 0x0F04, .s3
    cdecl draw_str, 25, 19, 0x0F04, .s4

    jmp $

.s1: db "ESP+ 0:"
.p1: db "-------- ", 0
.s2: db "   + 4:"
.p2: db "-------- ", 0
.s3: db "   + 8:"
.p3: db "-------- ", 0
.s4: db "   +12:"
.p4: db "-------- ", 0

; デフォルトの割り込み処理
int_default:
    pushf
    push cs
    push int_stop
    mov eax, .s0
    iret
.s0: db " <    STOP    > ", 0

int_zero_div:
    pushf
    push cs
    push int_stop
    mov eax, .s0
    iret
.s0: db " <  ZERO DIV  > ", 0
