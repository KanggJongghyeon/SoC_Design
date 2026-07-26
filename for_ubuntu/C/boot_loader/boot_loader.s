.text
    .align  2
    .globl  _start
    .set    noreorder
    .set    nomacro

_start:
    nop
    li      $sp, 0x00000800
    jal     main
    nop

hang:
    j       hang
    nop
