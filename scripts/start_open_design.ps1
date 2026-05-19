$ErrorActionPreference = 'Stop'

$repoRoot = Split-Path -Parent $PSScriptRoot
$openDesignRoot = Join-Path $repoRoot 'tools\open-design'

if (-not (Test-Path (Join-Path $openDesignRoot 'package.json'))) {
  throw "Open Design is not installed at $openDesignRoot. Clone https://github.com/nexu-io/open-design.git there first."
}

Push-Location $openDesignRoot
try {
  $env:PATH = "$openDesignRoot;$env:PATH"
  corepack pnpm tools-dev start web --daemon-port 17456 --web-port 17573
  corepack pnpm tools-dev status
  Write-Host ''
  Write-Host 'Open Design: http://127.0.0.1:17573'
  Write-Host 'Daemon:      http://127.0.0.1:17456'
} finally {
  Pop-Location
}
