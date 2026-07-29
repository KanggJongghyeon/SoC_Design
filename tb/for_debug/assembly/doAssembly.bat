@echo off

REM INIT
if exist assembly.o         del assembly.o
if exist mainAssembly.o     del mainAssembly.o
if exist mainAssembly.exe   del mainAssembly.exe

REM COMPILE
gcc -c assembly.c
gcc -c mainAssembly.c

REM LINK
gcc assembly.o mainAssembly.o -o mainAssembly.exe

REM EXECUTE
mainAssembly.exe
