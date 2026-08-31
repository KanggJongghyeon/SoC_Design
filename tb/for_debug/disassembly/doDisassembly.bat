@echo off

REM Set
set OS_LINUX=1
set OS_WINDOWS=2

REM INPUT
:INPUT
echo --------Select OS ----------
echo Press Button {1, 2}
echo [1] MEM File Made by LINUX
echo [2] MEM File Made by Windows
echo ----------------------------
set /p CRLF_FLAG=: 

if %CRLF_FLAG%==%OS_LINUX% goto INIT
if %CRLF_FLAG%==%OS_WINDOWS% goto INIT

echo Wrong Input...Try Again
goto INPUT

REM INIT
:INIT
if not exist obj        mkdir obj
if not exist textFile   mkdir textFile

if exist obj\array.o                del obj\array.o
if exist obj\disassembly.o          del obj\disassembly.o
if exist obj\mainDisassembly.o      del obj\mainDisassembly.o
if exist obj\mainDisassembly.exe    del obj\mainDisassembly.exe

REM COMPILE-ASSEMBLE
gcc -DNDEBUG -DCRLF=%CRLF_FLAG% -c array.c -o obj\array.o
gcc -DNDEBUG -DCRLF=%CRLF_FLAG% -c disassembly.c -o obj\disassembly.o
gcc -DNDEBUG -DCRLF=%CRLF_FLAG% -c mainDisassembly.c -o obj\mainDisassembly.o

REM LINK
gcc obj\array.o obj\disassembly.o obj\mainDisassembly.o -o obj\mainDisassembly.exe

REM EXECUTE
obj\mainDisassembly.exe
