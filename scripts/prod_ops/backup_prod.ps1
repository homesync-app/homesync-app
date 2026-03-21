param(
  [Parameter(Mandatory = $true)]
  [string]$DbUrl,
  [string]$OutDir = "backups"
)

$ErrorActionPreference = "Stop"

if (!(Get-Command pg_dump -ErrorAction SilentlyContinue)) {
  throw "pg_dump is required in PATH"
}

New-Item -ItemType Directory -Force -Path $OutDir | Out-Null
$ts = Get-Date -Format "yyyyMMdd_HHmmss"
$target = Join-Path $OutDir "homesync_prod_$ts.dump"

Write-Host "Creating production backup: $target"
& pg_dump --format=custom --no-owner --no-privileges --file="$target" "$DbUrl"

Write-Host "Backup created: $target"
