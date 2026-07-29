@echo off

REM INIT
if exist disAssembly.o          del disAssembly.o
if exist mainDisassembly.o      del mainDisassembly.o
if exist mainDisassembly.exe    del mainDisassembly.exe

REM COMPILE
gcc -c disAssembly.c
gcc -c mainDisassembly.c

REM LINK
gcc disAssembly.o mainDisassembly.o -o mainDisassembly.exe

REM EXECUTE
mainDisassembly.exe

