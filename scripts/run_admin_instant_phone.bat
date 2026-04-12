@echo off
setlocal
cd /d "%~dp0"
powershell -ExecutionPolicy Bypass -File "%~dp0run_admin_instant_phone.ps1"
if errorlevel 1 (
  echo.
  echo El launcher admin QA termino con error.
  pause
)
endlocal
