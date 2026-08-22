#!/bin/bash

# Init Object Folder
rm -rf obj
mkdir -p obj

# MIPS Compile 
mips-linux-gnu-gcc -mips32 -S application.c -o obj/application.s
mips-linux-gnu-gcc -mips32 -S dmaCtrl/dmaCtrl.c -o obj/dmaCtrl.s

# MIPS Assemble
mips-linux-gnu-as -o obj/application.o obj/application.s
mips-linux-gnu-as -o obj/dmaCtrl.o obj/dmaCtrl.s

# MIPS Link
mips-linux-gnu-gcc -mips32 obj/application.o obj/dmaCtrl.o -o obj/applicationMips.out

# Extract Total MIPS Assembly and Memory File
mips-linux-gnu-objdump -d obj/applicationMips.out > obj/totalApplication.s
mips-linux-gnu-objdump -d obj/applicationMips.out | awk '/^[ \t]*[0-9a-f]+:/{print $2}' > obj/application.mem
echo "Complete Generate MIPS Memory File"

# Copy Memory File to Windows
cp obj/application.mem /mnt/v/soc_design/tb
echo "Complete Copy Memory File to Windows Env"

# Native GCC Build for Execution
gcc application.c dmaCtrl/dmaCtrl.c -o obj/application.out
echo "Complete Generate Native Executable"
