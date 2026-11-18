$ErrorActionPreference = "Stop"

if (Test-Path "C:\Users\Blas\flutter\bin") {
    $env:PATH = "C:\Users\Blas\flutter\bin;$env:PATH"
}

$repoRoot = Split-Path -Parent $PSScriptRoot
$flutterAppDir = Join-Path $repoRoot "flutter_client"
$envFile = Join-Path $flutterAppDir ".env.local"
$scenarioId = "couple"
$viewerUserId = "22220000-0000-0000-0000-000000000001"

if (-not (Test-Path $envFile)) {
    throw "Missing env file: $envFile"
}

Write-Host "Starting HomeSync QA on Chrome (Modo Pareja)..." -ForegroundColor Green

Push-Location $flutterAppDir
try {
    flutter run `
        -d chrome `
        --no-pub `
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
