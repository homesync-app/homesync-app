@echo off
title HomeSync Admin (localhost)
cd /d "%~dp0"

REM Instalar dependencias automaticamente la primera vez
if not exist "node_modules" (
  echo node_modules no encontrado. Instalando dependencias...
  echo.
  call npm install
  if errorlevel 1 (
    echo.
    echo ERROR: fallo npm install. Revisa el mensaje de arriba.
    pause
    exit /b 1
  )
  echo.
)

echo Levantando HomeSync Admin en localhost...
echo (cerra esta ventana para apagar el servidor)
echo.
call npm run dev -- --open
pause
