$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
$flutterAppDir = Join-Path $repoRoot "flutter_client"
$envFile = Join-Path $flutterAppDir ".env.local"
$deviceId = "R5CY10QFHYT"
$scenarioId = "family"
$viewerUserId = "44440000-0000-0000-0000-000000000001"

if (-not (Test-Path $envFile)) {
    throw "Missing env file: $envFile"
}

Write-Host "Checking connected Flutter devices..." -ForegroundColor Cyan
$devicesOutput = flutter devices
$devicesOutput | ForEach-Object { Write-Host $_ }
$devicesText = ($devicesOutput | Out-String)

if ($devicesText -match "No devices detected") {
    throw "No Flutter devices detected."
}

if ($devicesText -notmatch $deviceId) {
    throw "Android phone '$deviceId' not detected."
}

Write-Host ""
Write-Host "Starting HomeSync QA on phone (Blas / Family)..." -ForegroundColor Green
Write-Host ""

Push-Location $flutterAppDir
try {
    flutter run `
        -d $deviceId `
        --dart-define-from-file=.env.local `
        --dart-define=APP_ENV=staging `
        --dart-define=AUTH_MODE=supabase_native `
        --dart-define=ENABLE_ADMIN_TESTING=true `
        --dart-define=ADMIN_TESTING_AUTO_LOGIN=true `
        --dart-define=ADMIN_TESTING_AUTO_SCENARIO_ID=$scenarioId `
        --dart-define=ADMIN_TESTING_AUTO_VIEWER_USER_ID=$viewerUserId `
        --dart-define=ADMIN_TESTING_BASE_EMAIL=test@homesync.com `
        --dart-define=ADMIN_TESTING_BASE_PASSWORD=qapass123 `
        --dart-define=ADMIN_TESTING_USERNAME=admin `
        --dart-define=ADMIN_TESTING_PASSWORD=superadmin
}
finally {
    Pop-Location
}
