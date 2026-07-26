#!/bin/bash
mips-linux-gnu-as -o boot_loader.o boot_loader.s
mips-linux-gnu-objdump -d boot_loader.o | awk '/^[ \t]*[0-9a-f]+:/{print $2}' > boot_loader.mem
cp boot_loader.mem /mnt/v/soc_design/tb
