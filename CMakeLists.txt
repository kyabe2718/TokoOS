cmake_minimum_required(VERSION 3.0)

enable_language(ASM_NASM)
project(TokoOS ASM_NASM)

function(add_bootable_image name) #source...

    set(CAT_COMMAND cat)

    foreach(src ${ARGN})
        get_filename_component(n ${src} NAME_WE)
        add_custom_target(
            ${n}.bin
            COMMAND ${CMAKE_ASM_NASM_COMPILER} -i${CMAKE_CURRENT_LIST_DIR}/ ${src} -o ${n}.bin -l ${n}.lst
            DEPENDS ${src}
        )

        set(CAT_COMMAND "${CAT_COMMAND} ${n}.bin")
    endforeach()

    add_custom_target(
        ${name}_img
        COMMAND /bin/sh -c ${CAT_COMMAND} > ${name}.img
    )

    foreach(src ${ARGN})
        get_filename_component(n ${src} NAME_WE)
        add_dependencies(${name}_img ${n}.bin)
    endforeach()
endfunction()

function(add_bochs_target name)
    set(BOCHSRC_FILE ${CMAKE_CURRENT_BINARY_DIR}/bochs_${name}.bxrc) # bochsのconfigファイルの出力先
    set(BOCHSRC_TEMPLATE ${CMAKE_CURRENT_LIST_DIR}/config/mkbochsrc.sh) # bochsのconfigファイルを作るテンプレート

    # ${name}.imgをloadするimg fileとしたconfigファイルを生成
    add_custom_command(
        OUTPUT ${BOCHSRC_FILE}
        COMMAND /bin/sh ${BOCHSRC_TEMPLATE} ${CMAKE_CURRENT_BINARY_DIR}/${name}.img > ${BOCHSRC_FILE}
        DEPENDS ${BOCHSRC_TEMPLATE}
    )

    # 生成したconfigファイルを用いてbochsを起動
    add_custom_target(
        bochs_${name}
        COMMAND bochs -q -f ${BOCHSRC_FILE} -rc ${CMAKE_CURRENT_LIST_DIR}/config/cmd.init
        DEPENDS ${name}_img
        DEPENDS ${BOCHSRC_FILE}
    )
endfunction()

function(add_qemu_target name)
    # 生成したconfigファイルを用いてbochsを起動
    add_custom_target(
            qemu_${name}
            COMMAND qemu-system-i386 -rtc base=localtime -drive file=${CMAKE_CURRENT_BINARY_DIR}/${name}.img,format=raw -boot order=c
            DEPENDS ${name}_img
    )
endfunction()

add_bootable_image(boot ${CMAKE_CURRENT_LIST_DIR}/src/boot.asm ${CMAKE_CURRENT_LIST_DIR}/src/kernel.asm)
add_bochs_target(boot)
add_qemu_target(boot)
