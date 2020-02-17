#! /bin/bash

SCRIPT_DIR=$(cd $(dirname $0); pwd)

filename=src/boot.asm
target=${filename%.*}

echo $filename
echo $target

/usr/bin/nasm $filename -o ${target}.img -l ${target}.lst

if [[ $? != 0 ]]; then
    echo "nasm error"
    exit 1
fi

# Bochs
bochs -q -f ${SCRIPT_DIR}/config/bochsrc.bxrc -rc ${SCRIPT_DIR}/config/cmd.init

# qemu（上手く行かない？？）
# qemu-system-i386 -rtc base=localtime -drive file=$filename,format=raw -boot order=c

