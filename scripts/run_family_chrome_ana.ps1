$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
$flutterAppDir = Join-Path $repoRoot "flutter_client"
$scenarioId = "family"
$viewerUserId = "44440000-0000-0000-0000-000000000002"

Write-Host "Checking connected Flutter devices..." -ForegroundColor Cyan
$devicesOutput = flutter devices
$devicesOutput | ForEach-Object { Write-Host $_ }
$devicesText = ($devicesOutput | Out-String)

if ($devicesText -match "No devices detected") {
    throw "No Flutter devices detected."
}

if ($devicesText -notmatch "Chrome") {
    throw "Chrome device not available in Flutter."
}

Write-Host ""
Write-Host "Starting HomeSync QA on Chrome (Ana / Family)..." -ForegroundColor Green
Write-Host ""

Push-Location $flutterAppDir
try {
    flutter run `
        -d chrome `
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
