#!/usr/bin/env pwsh
$ErrorActionPreference = 'Stop'

# 1) Collect staged files
$staged = git diff --name-only --cached --diff-filter=ACMR
if (-not $staged) { exit 0 }

# 2) Filter by extensions of interest
$exts = @('md','txt','ps1','psm1','yml','yaml','json')
$targets = @()
foreach ($f in $staged) {
  $e = [System.IO.Path]::GetExtension($f).Trim('.').ToLowerInvariant()
  if ($exts -contains $e) { $targets += $f }
}
if (-not $targets) { exit 0 }

# 3) Character hygiene fix on staged files, then re-stage
foreach ($f in $targets) {
  pwsh -NoProfile -ExecutionPolicy Bypass -File .specify/scripts/powershell/character_hygiene.ps1 -Root $f -Fix | Out-Null
}

git add -- $targets

# 4) Provenance presence check for generated docs
$provCandidates = $targets | Where-Object { $_ -match '(^|/)specs/.+/(spec|plan|tasks|quickstart)\.md$' }
$provErrors = @()
foreach ($f in $provCandidates) {
  & pwsh -NoProfile -ExecutionPolicy Bypass -File .specify/scripts/powershell/provenance.ps1 -Path $f -Generator '' -CheckOnly | Out-Null
  $code = $LASTEXITCODE
  if ($code -ne 0) { $provErrors += $f }
}
if ($provErrors.Count -gt 0) {
  Write-Host "Provenance header missing in:" -ForegroundColor Red
  $provErrors | ForEach-Object { Write-Host " - $_" }
  Write-Host "Hint: .specify/scripts/powershell/provenance.ps1 -Path <file> -Generator '/plan|/tasks|manual'" -ForegroundColor Yellow
  exit 1
}

exit 0
