#!/bin/bash

# Init Object Folder
rm -rf obj
mkdir -p obj

# MIPS Compile 
mips-linux-gnu-gcc -mips32 -S application.c -o obj/application.s
mips-linux-gnu-gcc -mips32 -S dma/dma.c -o obj/dma.s

# MIPS Assemble
mips-linux-gnu-as -o obj/application.o obj/application.s
mips-linux-gnu-as -o obj/dma.o obj/dma.s

# MIPS Link
mips-linux-gnu-gcc -mips32 obj/application.o obj/dma.o -o obj/applicationMips.elf

# Extract Total MIPS Assembly and Memory File
mips-linux-gnu-objdump -d obj/applicationMips.elf > obj/totalApplication.s
mips-linux-gnu-objdump -d obj/applicationMips.elf | awk '/^[ \t]*[0-9a-f]+:/{print $2}' > obj/application.mem
echo "Complete Generate MIPS Memory File"

# Extract ELF Information
mips-linux-gnu-readelf -h obj/applicationMips.elf > obj/elfHeader.log
mips-linux-gnu-readelf -l obj/applicationMips.elf > obj/programHeader.log
mips-linux-gnu-readelf -S obj/applicationMips.elf > obj/sectionHeader.log
mips-linux-gnu-objdump -s obj/applicationMips.elf > obj/sectionContents.log
echo "Complete Generate ELF Information"

# Copy Memory File to Windows
cp obj/application.mem /mnt/v/soc_design/tb
echo "Complete Copy Memory File to Windows Env"

# Native GCC Build for Execution
#gcc application.c dma/dma.c -o obj/application.elf
#echo "Complete Generate Native Executable"
