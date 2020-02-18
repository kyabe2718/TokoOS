
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
