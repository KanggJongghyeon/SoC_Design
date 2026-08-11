@echo off

REM INIT
if not exist obj        mkdir obj
if not exist textFile  mkdir textFile
if exist obj\array.o                del obj\array.o
if exist obj\disassembly.o          del obj\disassembly.o
if exist obj\mainDisassembly.o      del obj\mainDisassembly.o
if exist obj\mainDisassembly.exe    del obj\mainDisassembly.exe

REM COMPILE-ASSEMBLE
gcc -DNDEBUG -c array.c -o obj\array.o
gcc -DNDEBUG -c disassembly.c -o obj\disassembly.o
gcc -DNDEBUG -c mainDisassembly.c -o obj\mainDisassembly.o

REM LINK
gcc obj\array.o obj\disassembly.o obj\mainDisassembly.o -o obj\mainDisassembly.exe

REM EXECUTE
obj\mainDisassembly.exe
