param(
    [string]$DeviceId = "",
    [string]$OutputDir = "",
    [string]$PackageName = "com.blas.homesync"
)

$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot

function Resolve-Adb {
    $candidates = @(
        $env:ANDROID_HOME,
        $env:ANDROID_SDK_ROOT,
        (Join-Path $env:LOCALAPPDATA "Android\Sdk")
    ) | Where-Object { $_ -and (Test-Path $_) }

    foreach ($root in $candidates) {
        $adb = Join-Path $root "platform-tools\adb.exe"
        if (Test-Path $adb) {
            return $adb
        }
    }

    $cmd = Get-Command adb -ErrorAction SilentlyContinue
    if ($cmd) {
        return $cmd.Source
    }

    throw "adb not found. Install Android platform-tools or set ANDROID_HOME."
}

$adb = Resolve-Adb
$devices = & $adb devices
$deviceLines = @($devices | Where-Object { $_ -match "\tdevice$" })

if ($deviceLines.Count -eq 0) {
    throw "No adb devices connected."
}

if (-not $DeviceId) {
    $DeviceId = ($deviceLines[0] -split "\t")[0]
}

if (-not $OutputDir) {
    $stamp = Get-Date -Format "yyyyMMdd-HHmmss"
    $OutputDir = Join-Path $repoRoot "artifacts\android-qa\$stamp"
}

New-Item -ItemType Directory -Force -Path $OutputDir | Out-Null

Write-Host "Capturing Android QA evidence..." -ForegroundColor Cyan
Write-Host "Device:  $DeviceId" -ForegroundColor Yellow
Write-Host "Output:  $OutputDir" -ForegroundColor Yellow

$remoteShot = "/sdcard/homesync-qa-screen.png"
$remoteUi = "/sdcard/homesync-qa-ui.xml"

& $adb -s $DeviceId shell screencap -p $remoteShot
& $adb -s $DeviceId pull $remoteShot (Join-Path $OutputDir "screen.png") | Out-Null
& $adb -s $DeviceId shell rm $remoteShot | Out-Null

& $adb -s $DeviceId shell uiautomator dump $remoteUi | Out-Null
& $adb -s $DeviceId pull $remoteUi (Join-Path $OutputDir "ui.xml") | Out-Null
& $adb -s $DeviceId shell rm $remoteUi | Out-Null

& $adb -s $DeviceId logcat -d -v time > (Join-Path $OutputDir "logcat.txt")
& $adb -s $DeviceId shell dumpsys meminfo $PackageName > (Join-Path $OutputDir "meminfo.txt")
& $adb -s $DeviceId shell dumpsys gfxinfo $PackageName framestats > (Join-Path $OutputDir "gfxinfo-framestats.txt")

Write-Host "Evidence captured." -ForegroundColor Green
