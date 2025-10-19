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

# 3) Character hygiene (check-only; warn)
$hygieneWarn = $false
foreach ($f in $targets) {
  & pwsh -NoProfile -ExecutionPolicy Bypass -File .specify/scripts/character_hygiene.ps1 -Root $f | Out-Null
  if ($LASTEXITCODE -ne 0) { $hygieneWarn = $true }
}
if ($hygieneWarn) {
  Write-Host "[WARN] Character hygiene issues detected. Consider running: .specify/scripts/character_hygiene.ps1 -Root . -Fix" -ForegroundColor Yellow
}

# 4) Provenance header check (presence + expected generator)
$provCandidates = $targets | Where-Object { $_ -match '(^|/)specs/.+/(spec|plan|tasks|quickstart)\.md$' }
$provErrors = @()
foreach ($f in $provCandidates) {
  $expected = ''
  if ($f -match '(^|/)specs/.+/spec\.md$')       { $expected = '/specify' }
  elseif ($f -match '(^|/)specs/.+/plan\.md$')   { $expected = '/plan' }
  elseif ($f -match '(^|/)specs/.+/tasks\.md$')  { $expected = '/tasks' }
  elseif ($f -match '(^|/)specs/.+/quickstart\.md$') { $expected = '/plan' }
  & pwsh -NoProfile -ExecutionPolicy Bypass -File .specify/scripts/provenance.ps1 -Path $f -Generator $expected -CheckOnly | Out-Null
  if ($LASTEXITCODE -ne 0) { $provErrors += "$f (expected: $expected)" }
}
if ($provErrors.Count -gt 0) {
  Write-Host "[WARN] Provenance generator mismatch:" -ForegroundColor Yellow
  $provErrors | ForEach-Object { Write-Host " - $_" }
}

# 5) Referenced-scripts gate only when prompts/scripts changed
$changedPaths = $targets
if ($changedPaths | Where-Object { $_ -match '^\.codex/prompts/|^\.specify/scripts/' }) {
  if (Test-Path '.specify/scripts/powershell/referenced_scripts_gate.ps1') {
    & pwsh -NoProfile -ExecutionPolicy Bypass -File .specify/scripts/powershell/referenced_scripts_gate.ps1 -RepoRoot . | Out-Null
    if ($LASTEXITCODE -ne 0) {
      Write-Host "Referenced-scripts gate failed. Please ensure all referenced scripts exist." -ForegroundColor Red
      exit 1
    }
  }
}

exit 0
