param(
  [Parameter(Mandatory = $true)]
  [string]$DbUrl,
  [Parameter(Mandatory = $true)]
  [string]$BackupFile
)

$ErrorActionPreference = "Stop"

if (!(Test-Path $BackupFile)) {
  throw "Backup file not found: $BackupFile"
}

if (!(Get-Command pg_restore -ErrorAction SilentlyContinue)) {
  throw "pg_restore is required in PATH"
}

Write-Host "Restoring backup into target database..."
& pg_restore --clean --if-exists --no-owner --no-privileges --dbname="$DbUrl" "$BackupFile"
Write-Host "Restore finished"
