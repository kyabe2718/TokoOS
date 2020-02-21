%include "include/define.asm"
%include "include/macro.asm"

ORG KERNEL_LOAD

[BITS 32]   ; 32bitコードを生成する

; エントリポイント
kernel:
    jmp $


; パディング
times KERNEL_SIZE - ($ - $$) db 0
