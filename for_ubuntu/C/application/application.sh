#!/bin/bash
mips-linux-gnu-gcc -mips32 -S application.c
mips-linux-gnu-as -o application.o application.s
mips-linux-gnu-objdump -d application.o | awk '/^[ \t]*[0-9a-f]+:/{print $2}' > application.mem
cp application.mem /mnt/v/soc_design/tb
