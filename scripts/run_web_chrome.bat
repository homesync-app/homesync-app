@echo off
setlocal EnableExtensions EnableDelayedExpansion

set "REPO_ROOT=%~dp0.."
for %%I in ("%REPO_ROOT%") do set "REPO_ROOT=%%~fI"

set "FLUTTER_APP_DIR=%REPO_ROOT%\flutter_client"

echo.
echo HomeSync - Web en Chrome
echo ========================
echo.

pushd "%FLUTTER_APP_DIR%" || (
    echo No se encontro: %FLUTTER_APP_DIR%
    pause
    exit /b 1
)

call flutter pub get || goto :fail
echo.
echo Iniciando en Chrome...
echo Presiona Ctrl+C para detener.
echo.

call flutter run -d chrome --dart-define=APP_ENV=staging
set "RUN_EXIT=%ERRORLEVEL%"
popd
exit /b %RUN_EXIT%

:fail
set "ERR=%ERRORLEVEL%"
echo.
echo Fallo con codigo !ERR!.
popd
pause
exit /b !ERR!
