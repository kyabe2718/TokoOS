cmake_minimum_required(VERSION 3.0)

enable_language(ASM_NASM)
project(TinyOS ASM_NASM)

function(add_bootable_image name source)
    # img fileを作成
    add_custom_command(
        OUTPUT ${name}.img
        COMMAND ${CMAKE_ASM_NASM_COMPILER} -i${CMAKE_CURRENT_LIST_DIR}/ ${source} -o ${name}.img -l ${name}.lst
        DEPENDS ${source}
    )

    add_custom_target(${name}_img  DEPENDS ${name}.img)
endfunction()

function(add_bochs_target name)
    set(BOCHSRC_FILE ${CMAKE_CURRENT_BINARY_DIR}/bochs_${name}.bxrc)

    # ${name}.imgをloadするimg fileとしたconfigファイルを生成
    add_custom_command(
        OUTPUT ${BOCHSRC_FILE}
        COMMAND /bin/sh ${CMAKE_CURRENT_LIST_DIR}/config/mkbochsrc.sh ${CMAKE_CURRENT_BINARY_DIR}/${name}.img > ${BOCHSRC_FILE}
    )

    # 生成したconfigファイルを用いてbochsを起動
    add_custom_target(
        bochs_${name}
        COMMAND /usr/bin/bochs -q -f ${BOCHSRC_FILE} -rc ${CMAKE_CURRENT_LIST_DIR}/config/cmd.init
        DEPENDS ${name}_img
        DEPENDS ${BOCHSRC_FILE}
    )
endfunction()

add_bootable_image(boot ${CMAKE_CURRENT_LIST_DIR}/src/boot.asm)
add_bochs_target(boot)
