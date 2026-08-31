#!/bin/bash

# Init Object Folder
rm -rf objMips
mkdir -p objMips

# MIPS Compile 
mips-linux-gnu-gcc -mips32 -S application.c -o objMips/application.s
mips-linux-gnu-gcc -mips32 -S dma/dma.c -o objMips/dma.s

# MIPS Assemble
mips-linux-gnu-as -o objMips/application.o objMips/application.s
mips-linux-gnu-as -o objMips/dma.o objMips/dma.s

# MIPS Link
mips-linux-gnu-gcc -mips32 objMips/application.o objMips/dma.o -o objMips/applicationMips.elf

# Extract Total MIPS Assembly and Memory File
mips-linux-gnu-objdump -d objMips/applicationMips.elf > objMips/totalApplication.s
mips-linux-gnu-objdump -d objMips/applicationMips.elf | awk '/^[ \t]*[0-9a-f]+:/{print $2}' > objMips/application.mem
echo "Complete Generate MIPS Memory File"

# Extract ELF Information
mips-linux-gnu-readelf -h objMips/applicationMips.elf > objMips/elfHeader.log
mips-linux-gnu-readelf -l objMips/applicationMips.elf > objMips/programHeader.log
mips-linux-gnu-readelf -S objMips/applicationMips.elf > objMips/sectionHeader.log
mips-linux-gnu-objdump -s objMips/applicationMips.elf > objMips/sectionContents.log
echo "Complete Generate ELF Information"

# Copy Memory File to Windows
cp objMips/application.mem /mnt/v/soc_design/tb
echo "Complete Copy Memory File to Windows Env"
