@echo off

REM Change Current Directory to the Batch File's Path
cd /d "%~dp0"

REM Copy Memory File
REM /Y : Overwrite
copy /Y .\..\..\tb\application.mem           .\memFile\application.mem
copy /Y .\..\..\tb\boot_loader.mem           .\memFile\boot_loader.mem
copy /Y .\..\..\tb\for_debug\debug_mode.mem  .\memFile\debug_mode.mem

REM Run Python
python main.py

if errorlevel 1 pause
