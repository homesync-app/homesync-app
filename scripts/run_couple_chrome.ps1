$ErrorActionPreference = "Stop"

if (Test-Path "C:\Users\Blas\flutter\bin") {
    $env:PATH = "C:\Users\Blas\flutter\bin;$env:PATH"
}

$repoRoot = Split-Path -Parent $PSScriptRoot
$flutterAppDir = Join-Path $repoRoot "flutter_client"
$envFile = Join-Path $flutterAppDir ".env.local"
$scenarioId = "demo"
$viewerUserId = "aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaa1"

if (-not (Test-Path $envFile)) {
    throw "Missing env file: $envFile"
}

Write-Host "Starting HomeSync on Chrome (Modo Pareja - Sofi & Mati) on http://localhost:8080 ..." -ForegroundColor Green

Push-Location $flutterAppDir
try {
    flutter run `
        -d chrome `
        --no-pub `
        --web-hostname=127.0.0.1 `
        --web-port=8080 `
        --dart-define-from-file=.env.local `
        --dart-define=APP_ENV=staging `
        --dart-define=AUTH_MODE=supabase_native `
        --dart-define=ENABLE_ADMIN_TESTING=true `
        --dart-define=ADMIN_TESTING_AUTO_LOGIN=true `
        --dart-define=ADMIN_TESTING_AUTO_SCENARIO_ID=$scenarioId `
        --dart-define=ADMIN_TESTING_AUTO_VIEWER_USER_ID=$viewerUserId
}
finally {
    Pop-Location
}
