@echo off
setlocal
set "SCRIPT_DIR=%~dp0"
set "TARGET_SCRIPT=%SCRIPT_DIR%..\scripts\main.ps1"

:: Try pwsh (PowerShell 7+) first
pwsh.exe -NoProfile -ExecutionPolicy Bypass -File "%TARGET_SCRIPT%" %*
if %ERRORLEVEL% equ 9009 (
    :: Fallback to Windows PowerShell 5.1
    powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%TARGET_SCRIPT%" %*
)
