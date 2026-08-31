@echo off
if exist C (
    rmdir /s /q C
)
wsl cp -r /home/kjh/C /mnt/v/soc_design/for_ubuntu/
copy .\buildWin64.bat .\C\application\
