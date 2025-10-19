#!/usr/bin/env pwsh
# Smoke test a built package zip by expanding and running gates inside it
[CmdletBinding()]
param(
  [Parameter(Mandatory=$true)] [string]$ZipPath
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

if (-not (Test-Path -LiteralPath $ZipPath)) {
  throw "Zip not found: $ZipPath"
}

$work = Join-Path ([System.IO.Path]::GetTempPath()) ("spec-kit-mca-smoke-" + [System.Guid]::NewGuid())
New-Item -ItemType Directory -Path $work | Out-Null

try {
  Expand-Archive -LiteralPath $ZipPath -DestinationPath $work -Force

  Push-Location $work
  try {
    # Minimal checks
    if (Test-Path '.specify/scripts/powershell/referenced_scripts_gate.ps1') {
      & .specify/scripts/powershell/referenced_scripts_gate.ps1 -RepoRoot .
      if ($LASTEXITCODE -ne 0) { throw "referenced-scripts gate failed in package" }
    }
    # Parity is a source-only gate; run only if both flavors exist inside the package (rare)
    if ((Test-Path 'flavors/codex-ps') -and (Test-Path 'flavors/codex-sh') -and (Test-Path '.specify/scripts/powershell/parity_check.ps1')) {
      & .specify/scripts/powershell/parity_check.ps1 -RepoRoot .
      if ($LASTEXITCODE -ne 0) { throw "parity check failed in package" }
    } else {
      Write-Host "[smoke] Parity check skipped (package contains single flavor)" -ForegroundColor Yellow
    }
    Write-Host "Smoke test PASS: $ZipPath" -ForegroundColor Green
  } finally { Pop-Location }
} finally {
  Remove-Item -Recurse -Force $work
}
