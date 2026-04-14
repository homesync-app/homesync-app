@echo off
setlocal EnableExtensions EnableDelayedExpansion

set "REPO_ROOT=%~dp0.."
for %%I in ("%REPO_ROOT%") do set "REPO_ROOT=%%~fI"

set "TARGET_BRANCH=develop"
set "MANAGED_WORKTREE_ROOT=C:\hs_worktrees"
set "MANAGED_WORKTREE_PATH=%MANAGED_WORKTREE_ROOT%\develop-web"
set "DEVICE=chrome"

if not "%~1"=="" (
    set "DEVICE=%~1"
)

echo.
echo HomeSync - Web PC sobre develop
echo ================================
echo.

pushd "%REPO_ROOT%" || (
    echo No se pudo abrir el repo: %REPO_ROOT%
    pause
    exit /b 1
)

echo Actualizando referencias remotas...
git fetch origin
if errorlevel 1 (
    echo Aviso: no se pudo hacer fetch. Se intentara usar la referencia local origin/%TARGET_BRANCH%.
    git show-ref --verify --quiet refs/remotes/origin/%TARGET_BRANCH% || goto :fail
)

if not exist "%MANAGED_WORKTREE_ROOT%" mkdir "%MANAGED_WORKTREE_ROOT%"

if exist "%MANAGED_WORKTREE_PATH%\flutter_client" (
    echo Usando worktree dedicado existente: %MANAGED_WORKTREE_PATH%
) else (
    echo Creando worktree dedicado apuntando a origin/%TARGET_BRANCH%...
    git worktree add --force --detach "%MANAGED_WORKTREE_PATH%" origin/%TARGET_BRANCH% || goto :fail
)

set "FLUTTER_APP_DIR=%MANAGED_WORKTREE_PATH%\flutter_client"
if not exist "%FLUTTER_APP_DIR%" (
    echo No se encontro flutter_client en: %FLUTTER_APP_DIR%
    goto :fail
)

pushd "%MANAGED_WORKTREE_PATH%" || goto :fail
echo Sincronizando con origin/%TARGET_BRANCH%...
git fetch origin
if errorlevel 1 (
    echo Aviso: fetch dentro del worktree fallo. Continuando con origin/%TARGET_BRANCH% local.
)
git checkout --detach origin/%TARGET_BRANCH% || goto :fail_in_worktree
for /f "usebackq delims=" %%L in (`git log -1 --format^="%%h %%s"`) do set "LAST_COMMIT=%%L"
echo Ultimo commit: !LAST_COMMIT!
popd

echo.
echo Verificando dispositivos web disponibles...
call flutter devices || goto :fail
echo.
echo Iniciando HomeSync web sobre develop en "%DEVICE%"...
echo Worktree: %FLUTTER_APP_DIR%
echo Presiona Ctrl+C para detener.
echo.

pushd "%FLUTTER_APP_DIR%" || goto :fail
call flutter pub get || goto :fail_in_flutter
call flutter run -d %DEVICE% --dart-define=APP_ENV=staging
set "RUN_EXIT=%ERRORLEVEL%"
popd
popd
exit /b %RUN_EXIT%

:fail_in_flutter
set "ERR=%ERRORLEVEL%"
echo.
echo Fallo Flutter con codigo !ERR!.
popd
popd
pause
exit /b !ERR!

:fail_in_worktree
set "ERR=%ERRORLEVEL%"
echo.
echo Fallo sincronizando el worktree con codigo !ERR!.
popd
popd
pause
exit /b !ERR!

:fail
set "ERR=%ERRORLEVEL%"
echo.
echo Fallo el script con codigo !ERR!.
popd
pause
exit /b !ERR!
