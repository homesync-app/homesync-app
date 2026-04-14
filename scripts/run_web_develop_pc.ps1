$ErrorActionPreference = "Stop"

param(
    [string]$Device = "chrome"
)

$repoRoot = Split-Path -Parent $PSScriptRoot
$targetBranch = "develop"
$managedWorktreeRoot = Join-Path $repoRoot ".worktrees"
$managedWorktreePath = Join-Path $managedWorktreeRoot "develop-web"
$flutterAppDir = $null

Write-Host ""
Write-Host "HomeSync - Web PC sobre develop" -ForegroundColor Cyan
Write-Host "================================" -ForegroundColor Cyan
Write-Host ""

Push-Location $repoRoot
try {
    Write-Host "Actualizando referencias remotas..." -ForegroundColor Yellow
    git fetch origin

    $worktreeLines = git worktree list --porcelain
    $resolvedWorktreePath = $null

    for ($i = 0; $i -lt $worktreeLines.Count; $i++) {
        if ($worktreeLines[$i] -eq "branch refs/heads/$targetBranch") {
            for ($j = $i - 1; $j -ge 0; $j--) {
                if ($worktreeLines[$j] -like "worktree *") {
                    $resolvedWorktreePath = ($worktreeLines[$j] -replace '^worktree ', '').Trim()
                    break
                }
            }
            break
        }
    }

    if ($resolvedWorktreePath) {
        Write-Host "Usando worktree existente de '$targetBranch': $resolvedWorktreePath" -ForegroundColor Green
    } else {
        if (-not (Test-Path $managedWorktreeRoot)) {
            New-Item -ItemType Directory -Path $managedWorktreeRoot | Out-Null
        }

        if (Test-Path $managedWorktreePath) {
            Write-Host "Limpiando worktree administrado anterior..." -ForegroundColor DarkYellow
            git worktree remove --force $managedWorktreePath
        }

        Write-Host "Creando worktree dedicado para '$targetBranch'..." -ForegroundColor Yellow
        git worktree add --track -B $targetBranch $managedWorktreePath origin/$targetBranch
        $resolvedWorktreePath = $managedWorktreePath
    }

    $flutterAppDir = Join-Path $resolvedWorktreePath "flutter_client"
    if (-not (Test-Path $flutterAppDir)) {
        throw "No se encontro flutter_client en: $flutterAppDir"
    }

    Push-Location $resolvedWorktreePath
    try {
        Write-Host "Sincronizando branch '$targetBranch'..." -ForegroundColor Yellow
        git fetch origin
        git checkout $targetBranch
        git pull origin $targetBranch --ff-only

        $lastCommit = git log -1 --format="%h %s"
        Write-Host "Ultimo commit: $lastCommit" -ForegroundColor DarkGray
    }
    finally {
        Pop-Location
    }
}
finally {
    Pop-Location
}

Write-Host ""
Write-Host "Verificando dispositivos web disponibles..." -ForegroundColor Yellow
$devicesOutput = flutter devices
$devicesText = ($devicesOutput | Out-String).ToLowerInvariant()
$devicesOutput | ForEach-Object { Write-Host $_ }

if ($devicesText -notmatch [regex]::Escape($Device.ToLowerInvariant())) {
    throw "El dispositivo web '$Device' no esta disponible en Flutter."
}

Write-Host ""
Write-Host "Iniciando HomeSync web sobre develop en '$Device'..." -ForegroundColor Green
Write-Host "Worktree: $flutterAppDir" -ForegroundColor DarkGray
Write-Host "Presiona Ctrl+C para detener." -ForegroundColor DarkGray
Write-Host ""

Push-Location $flutterAppDir
try {
    flutter pub get
    flutter run `
        -d $Device `
        --dart-define=APP_ENV=staging
}
finally {
    Pop-Location
}
