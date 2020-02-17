cmake_minimum_required(VERSION 3.0)

project(TinyOS)

function(add_bootable_image name source)
    # img fileを作成
    add_custom_command(
        OUTPUT ${name}.img
        COMMAND ${CMAKE_ASM_NASM_COMPILER} -i ${CMAKE_CURRENT_LIST_DIR}/ ${source} -o ${name}.img -l ${name}.lst
    )
endfunction()

function(add_bochs_target name)
    # ${name}.imgをloadするimg fileとしたconfigファイルを生成
    add_custom_command(
        OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/bochs_${name}.bxrc
        COMMAND /bin/sh ${CMAKE_CURRENT_LIST_DIR}/config/mkbochsrc.sh ${CMAKE_CURRENT_BINARY_DIR}/${name}.img > ${CMAKE_CURRENT_BINARY_DIR}/bochs_${name}.bxrc
    )

    # 生成したconfigファイルを用いてbochsを起動
    add_custom_target(
        bochs_${name}
        bochs -q -f ${CMAKE_CURRENT_BINARY_DIR}/bochsrc_${name}.bxrc -rc ${CMAKE_CURRENT_LIST_DIR}/config/cmd.init
        DEPENDS ${name}.img ${CMAKE_CURRENT_BINARY_DIR}/bochs_${name}.bxrc)
endfunction()

add_bootable_image(boot ${CMAKE_CURRENT_LIST_DIR}/src/boot.asm)
add_bochs_target(boot)
