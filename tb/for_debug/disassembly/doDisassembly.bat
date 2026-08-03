@echo off

REM INIT
if not exist obj                    mkdir obj
if exist obj\disassembly.o          del obj\disassembly.o
if exist obj\mainDisassembly.o      del obj\mainDisassembly.o
if exist obj\mainDisassembly.exe    del obj\mainDisassembly.exe

REM COMPILE
gcc -c disassembly.c -o obj\disassembly.o
gcc -c mainDisassembly.c -o obj\mainDisassembly.o

REM LINK
gcc obj\disassembly.o obj\mainDisassembly.o -o obj\mainDisassembly.exe

REM EXECUTE
obj\mainDisassembly.exe

