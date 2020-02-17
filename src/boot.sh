#! /bin/bash

( [[ $1 == "" ]] || [[ $1 == "-h" ]] || [[ $1 == "--help" ]] ) && echo "1st argument must be boot image file." && exit 1


if [[ $1 == "clean" ]]; then
    rm -f *.img *.lst
    exit 0
fi

filename=$1
target=${filename%.*}

/usr/bin/nasm $filename -o ${target}.img -l ${target}.lst

if [[ $? != 0 ]]; then
    echo "nasm error"
    exit 1
fi

qemu-system-i386 -rtc base=localtime -drive file=$filename,format=raw -boot order=c

