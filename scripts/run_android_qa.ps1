param(
    [ValidateSet("solo", "couple", "friends", "family")]
    [string]$Scenario = "family",

    [string]$ViewerUserId = "",

    [string]$DeviceId = "",

    [switch]$RealQaSession
)

$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
$flutterAppDir = Join-Path $repoRoot "flutter_client"
$envFile = Join-Path $flutterAppDir ".env.local"

$defaultViewers = @{
    solo = "11110000-0000-0000-0000-000000000001"
    couple = "22220000-0000-0000-0000-000000000001"
    friends = "33330000-0000-0000-0000-000000000001"
    family = "44440000-0000-0000-0000-000000000001"
}

if (-not $ViewerUserId) {
    $ViewerUserId = $defaultViewers[$Scenario]
}

if (-not (Test-Path $envFile)) {
    throw "Missing env file: $envFile"
}

Write-Host "Checking connected Flutter devices..." -ForegroundColor Cyan
$devicesOutput = flutter devices
$devicesOutput | ForEach-Object { Write-Host $_ }
$androidLines = @($devicesOutput | Where-Object { $_ -match "android-" })

if ($androidLines.Count -eq 0) {
    throw "No Android Flutter devices detected. Start an emulator or connect a phone."
}

if (-not $DeviceId) {
    $firstAndroidLine = $androidLines[0]
    $parts = $firstAndroidLine -split "\s+•\s+"
    if ($parts.Count -lt 2) {
        throw "Could not infer Android device id from: $firstAndroidLine"
    }
    $DeviceId = $parts[1].Trim()
}

Write-Host ""
Write-Host "Starting HomeSync Android QA" -ForegroundColor Green
Write-Host "Device:   $DeviceId" -ForegroundColor Yellow
Write-Host "Scenario: $Scenario" -ForegroundColor Yellow
Write-Host "Viewer:   $ViewerUserId" -ForegroundColor Yellow
Write-Host "Mode:     $(if ($RealQaSession) { 'real QA user session' } else { 'admin preview session' })" -ForegroundColor Yellow
Write-Host ""

$flutterArgs = @(
    "run",
    "-d", $DeviceId,
    "--dart-define-from-file=.env.local",
    "--dart-define=APP_ENV=staging",
    "--dart-define=AUTH_MODE=supabase_native",
    "--dart-define=ENABLE_ADMIN_TESTING=true",
    "--dart-define=ADMIN_TESTING_AUTO_LOGIN=true",
    "--dart-define=ADMIN_TESTING_AUTO_SCENARIO_ID=$Scenario",
    "--dart-define=ADMIN_TESTING_AUTO_VIEWER_USER_ID=$ViewerUserId",
    "--dart-define=ADMIN_TESTING_BASE_EMAIL=test@homesync.com",
    "--dart-define=ADMIN_TESTING_BASE_PASSWORD=qapass123",
    "--dart-define=ADMIN_TESTING_USERNAME=admin",
    "--dart-define=ADMIN_TESTING_PASSWORD=superadmin"
)

if ($RealQaSession) {
    $flutterArgs += "--dart-define=ADMIN_TESTING_AUTO_REAL_QA_LOGIN=true"
}

Push-Location $flutterAppDir
try {
    & flutter @flutterArgs
}
finally {
    Pop-Location
}
