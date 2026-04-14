@echo off
setlocal

set "SCRIPT_DIR=%~dp0"
set "POWERSHELL_SCRIPT=%SCRIPT_DIR%run_device.ps1"

powershell.exe -NoExit -ExecutionPolicy Bypass -File "%POWERSHELL_SCRIPT%"

endlocal
