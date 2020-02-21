
; \brief LBA方式（通し番号）で指定されたセクタ番号をCHS方式（シリンダ・ヘッダ・セクタ）に変換する
; \param drive drive構造体のアドレス（ドライブパラメータが格納されている）
; \param drv_chs  drive構造体のアドレス．変換後のchs情報を格納する
; \param lba LBA
; \return 成功(0以外)or失敗(0)
; lba_chs(drive, drv_chs, lba)
lba_chs:
                ; bp + 8    lba
                ; bp + 6    drv_chs
                ; bp + 4    drive
    push bp     ; bp + 2    ip 戻り番地
    mov bp, sp  ; bp + 0    sp

    push si
    push di
    push bx
    push dx

    mov si, [bp + 4]
    mov di, [bp + 6]

    mov al, [si + drive.head]   ; ax = 最大ヘッド数
    mul byte [si + drive.sect]  ; ax *= 最大セクタ数
    mov bx, ax                  ; bx = ax

    mov dx, 0           ;
    mov ax, [bp + 8]    ; dx:ax = LBA
    div bx              ; dx = dx:ax % bx, ax = dx:ax / bx

    mov [di + drive.cyln], ax   ; シリンダ番号

    mov ax, dx  ; 余り
    div byte [si + drive.sect]; ah = ax % 最大セクタ数 -> セクタ番号, al = ax / 最大セクタ数 -> ヘッド番号

    movzx dx, ah    ; 拡張
    inc dx          ; セクタだけ0-indexではなく1-index

    mov ah, 0x00    ; 実質的に al -> ax への拡張

    mov [di + drive.head], ax
    mov [di + drive.sect], dx

    pop dx
    pop bx
    pop di
    pop si

    mov sp, bp
    pop bp
    ret

; \brief lba方式で指定されたセクタを内部でchs方式に変換し，読み出す
; \param drive ドライブパラメータが格納されたdrive構造体のアドレス
; \param lba LBA方式でのセクタ指定
; \param sect 読み出しセクタ数
; \param dst 読み出し先アドレス
; \return 実際に読み出したセクタ数
; read_lba(drive, lba, sect, dst)
read_lba:
                ; bp +10 dst
                ; bp + 8 sect
                ; bp + 6 lba
                ; bp + 4 drive
    push bp     ; bp + 2
    mov bp, sp  ; bp

    push si

    mov si, [bp + 4]    ; si = drive

    mov ax, [bp + 6]    ; ax = lba
    cdecl lba_chs, si, .chs, ax

    mov al, [si + drive.no]
    mov [.chs + drive.no], al

    cdecl read_chs, .chs, word[bp + 8], word[bp + 10]

    pop si

    mov sp, bp
    pop bp
    ret


.chs:
    istruc drive
       at  drive.no,      dw 0
       at  drive.cyln,    dw 0
       at  drive.head,    dw 0
       at  drive.sect,    dw 0
    iend
