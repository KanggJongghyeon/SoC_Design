@echo off
python -m PyInstaller --noconfirm --clean --onefile --windowed --name waveformVerifier main.py
if errorlevel 1 (
    echo Build failed.
    pause
    exit /b 1
)
echo.
echo Build complete: dist\waveformVerifier.exe
pause
