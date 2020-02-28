
# これは何
作って理解するOSの実装

# 使い方
* bochsを用いてbootする
```bash
$ mkdir build && cd build && cmake .. && make bochs_boot
```
* bootイメージを作成するだけ
```bash
$ mkdir build && cd build && cmake .. && make boot_img
```

# 動作確認環境
* ThinkPad L480
    * Intel Core i5-8350U
    * Ubuntu18.04.4 LTS
    * Linux Kernel 5.3.0-28-generic

* ThinkPad X270
    * Intel Core i7-7500U
    * Ubuntu18.04.4 LTS
    * Linux Kernel 4.15.0-88-generic
    
# 依存パッケージ
動作確認済みバージョンを併記
* bochs, bochs-x
    * Bochs x86 Emulator 2.6
* nasm
    * NASM version 2.13.02
* cmake
    * cmake version 3.13.2
* make
    * GNU Make 4.1



