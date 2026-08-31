@echo off

REM Init Object Folder
if exist objWin64 (
    rmdir /s /q objWin64
)
mkdir objWin64

REM COMPILE-ASSEMBLE
gcc -DNMIPS -c application.c -o objWin64\application.o
gcc -DNMIPS -c dma\dma.c -o objWin64\dma.o

REM LINK
gcc objWin64\application.o objWin64\dma.o -o objWin64\applicationWin64.exe
