
; %macro <マクロ名> <引数リスト>
; 引数リストを n-* とすると，n個以上の可変引数を取る
; 引数には%1, %2,...でアクセス
; %{x:y}で範囲指定取得
; .nolistにより，リスティングファイルへの出力を抑制


; 呼び出し規則cdeclで呼び出す
; cdecl <関数名>, <引数1>, <引数2>, ...
%macro cdecl 1-*.nolist

    %rep %0 - 1 ; %0は引数の個数
        push    %{-1:-1} ; 最後の要素
        %rotate -1 ; 右に回転
    %endrep
    %rotate -1 ; 右に回転．これでもとに戻る

        call %1

    ; __BITS__ はビットモード
    ; 3だけ右シフトしてバイト値を得る
    ; 上でpushした分をpopするのに等しい（めんどくさいのでspを動かすだけ）
    %if 1 < %0
        add sp, (__BITS__ >> 3) * (%0 - 1)
    %endif

%endmacro

struc drive
    .no     resw 1
    .cyln   resw 1
    .head   resw 1
    .sect   resw 1
endstruc

; \brief 割り込みベクタを設定
; \param %1 割り込みベクタ番号 (1~255)
; \param %2 割り込みベクタに設定する関数
%macro set_vect 1-*
    push eax
    push edi

    mov edi, VECT_BASE + (%1 * 8)   ; 割り込みゲートディスクリプタは1個あたり8byte
    mov eax, %2

    ; 割り込み処理のアドレスのみ書き換える．他はデフォルト
    mov [edi + 0], ax
    shr eax, 16
    mov [edi + 6], ax

    pop edi
    pop eax
%endmacro

; \brief 特定の番地に値を出力する
; \param %1 出力先
; \param %2 書き込む値（即値でもレジスタでも）
; \note outはレジスタからしかできないので，マクロを用いて簡略化．alが使用されることに注意
%macro outp 2
    mov al, %2
    out %1, al
%endmacro
