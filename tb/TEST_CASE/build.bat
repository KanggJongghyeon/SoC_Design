@echo off

REM INIT
if exist convert.o          del convert.o
if exist main.o             del main.o
if exist main.exe           del main.exe
if exist test_case_x.txt    del test_case_x.txt

REM COMPILE
gcc -c convert.c
gcc -c main.c

REM LINK
gcc convert.o main.o -o main.exe

REM EXECUTE
main.exe
