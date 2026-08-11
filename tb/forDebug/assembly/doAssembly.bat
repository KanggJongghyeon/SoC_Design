@echo off

REM INIT
if not exist obj                mkdir obj
if exist obj\assembly.o         del obj\assembly.o
if exist obj\mainAssembly.o     del obj\mainAssembly.o
if exist obj\mainAssembly.exe   del obj\mainAssembly.exe

REM COMPILE
gcc -DNDEBUG -c assembly.c -o obj\assembly.o
gcc -DNDEBUG -c mainAssembly.c -o obj\mainAssembly.o

REM LINK
gcc obj\assembly.o obj\mainAssembly.o -o obj\mainAssembly.exe

REM EXECUTE
obj\mainAssembly.exe
