LDT:        dq 0x0000000000000000
.cs_task_0: dq 0x00CF9A000000FFFF
.ds_task_0: dq 0x00CF92000000FFFF
.cs_task_1: dq 0x00CF9A000000FFFF
.ds_task_1: dq 0x00CF92000000FFFF
.end:

CS_TASK_0   equ (.cs_task_0 - LDT) | 4
DS_TASK_0   equ (.ds_task_0 - LDT) | 4
CS_TASK_1   equ (.cs_task_1 - LDT) | 4
DS_TASK_1   equ (.ds_task_1 - LDT) | 4

LDT_LIMIT   equ .end - LDT - 1
