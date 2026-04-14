$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
$flutterAppDir = Join-Path $repoRoot "flutter_client"

Write-Host ""
Write-Host "HomeSync - Lanzar en dispositivo fisico" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# ── Sincronizar con los ultimos cambios ──────────────────────────────────────
Write-Host "Sincronizando con los ultimos cambios..." -ForegroundColor Yellow

Push-Location $repoRoot
try {
    git fetch origin 2>&1 | Out-Null

    $latestBranch = "develop"

    # Git no permite checkout de un branch ya abierto en un worktree.
    # Si ese es el caso, usamos el flutter_client del worktree directamente.
    $worktreeLine = git worktree list --porcelain 2>&1 |
        Select-String "branch refs/heads/$latestBranch$" |
        Select-Object -First 1

    if ($worktreeLine) {
        # Extraer el path del worktree (la linea "worktree <path>" que lo precede)
        $allLines = git worktree list --porcelain 2>&1
        for ($i = 0; $i -lt $allLines.Count; $i++) {
            if ($allLines[$i] -match "branch refs/heads/$latestBranch$") {
                $wtPath = ($allLines[$i - 2] -replace '^worktree ', '').Trim()
                break
            }
        }
        $flutterAppDir = Join-Path $wtPath "flutter_client"
        Write-Host "  Branch: $latestBranch (worktree)" -ForegroundColor DarkGray
    } else {
        $currentBranch = git branch --show-current
        if ($currentBranch -ne $latestBranch) {
            Write-Host "  Cambiando: '$currentBranch' -> '$latestBranch'" -ForegroundColor DarkGray
            git checkout $latestBranch 2>&1 | Out-Null
        }
        git pull origin $latestBranch --ff-only 2>&1 | Out-Null
        Write-Host "  Branch: $latestBranch" -ForegroundColor DarkGray
    }

    $lastMsg = git log "origin/$latestBranch" -1 --format="%s"
    Write-Host "  Ultimo commit: $lastMsg" -ForegroundColor DarkGray
} catch {
    Write-Host "  Advertencia git: $($_.Exception.Message)" -ForegroundColor DarkYellow
} finally {
    Pop-Location
}

Write-Host ""
# ─────────────────────────────────────────────────────────────────────────────

Write-Host "Buscando dispositivos conectados..." -ForegroundColor Yellow
$devicesOutput = flutter devices 2>&1
$devicesText = ($devicesOutput | Out-String)

if ($devicesText -match "No devices detected" -or $devicesText -match "No se detectaron") {
    Write-Host ""
    Write-Host "No se encontro ningun dispositivo." -ForegroundColor Red
    Write-Host ""
    Write-Host "Asegurate de:" -ForegroundColor Yellow
    Write-Host "  1. Tener el celular conectado por USB"
    Write-Host "  2. Tener Depuracion USB activado en Opciones de desarrollador"
    Write-Host "  3. Haber aceptado el permiso en la pantalla del celular"
    Write-Host ""
    Read-Host "Presiona Enter para salir"
    exit 1
}

Write-Host ""
$devicesOutput | ForEach-Object { Write-Host $_ }
Write-Host ""
Write-Host "Iniciando HomeSync en modo staging..." -ForegroundColor Green
Write-Host "Presiona Ctrl+C para detener" -ForegroundColor DarkGray
Write-Host ""

Push-Location $flutterAppDir
try {
    flutter run --dart-define=APP_ENV=staging
}
finally {
    Pop-Location
}
