#!/usr/bin/env pwsh
[CmdletBinding()]
param(
  [string]$RepoRoot = '.'
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

Push-Location $RepoRoot
try {
  # Resolve feature paths via prerequisites helper
  $prereq = Join-Path '.specify/scripts/powershell' 'check-prerequisites.ps1'
  if (-not (Test-Path $prereq)) { throw "Missing script: $prereq" }
  $json = & $prereq -Json -PathsOnly | Out-String | ConvertFrom-Json
  $spec  = $json.FEATURE_SPEC
  $plan  = $json.IMPL_PLAN
  $tasks = $json.TASKS

  Write-Host "[analyze] Provenance check" -ForegroundColor Cyan
  $prov = Join-Path '.specify/scripts' 'provenance.ps1'
  & $prov -Path $spec  -Generator '/specify' -CheckOnly | Out-Null
  & $prov -Path $plan  -Generator '/plan'    -CheckOnly | Out-Null
  & $prov -Path $tasks -Generator '/tasks'   -CheckOnly | Out-Null

  Write-Host "[analyze] Character hygiene (check)" -ForegroundColor Cyan
  # Load hygiene scope from config if present; otherwise use a conservative default.
  $cfgPath = Join-Path '.specify/config' 'gates.hygiene.json'
  $exclude = @('zzz','data\upstream','data\one_piece','out','packages')
  $includeGlobs = @()
  if (Test-Path $cfgPath) {
    try {
      $cfg = Get-Content -Raw -LiteralPath $cfgPath | ConvertFrom-Json
      if ($cfg.exclude_dirs) { $exclude = @($cfg.exclude_dirs) }
      if ($cfg.include_globs) { $includeGlobs = @($cfg.include_globs) }
    } catch {
      Write-Host "[analyze] WARNING: Failed to parse $cfgPath; falling back to defaults" -ForegroundColor Yellow
    }
  }
  & .specify/scripts/character_hygiene.ps1 -Root . -ExcludeDirs $exclude -IncludeGlobs $includeGlobs | Out-Null

  $failures = @()

  # Mode guard (warn-only): compare .init-mode with active prompts layout
  try {
    $init = Get-Content -LiteralPath '.specify/.init-mode' -Encoding UTF8 | ConvertFrom-StringData
    $mode = $init['Mode']
    if ($mode) {
      if ($mode -eq 'ORG') {
        $mc = Get-ChildItem -Path '.codex/prompts' -Filter 'mc*.md' -File -ErrorAction SilentlyContinue
        if ($mc) { Write-Host "[WARN] Mode=ORG but MCA prompts are active under .codex/prompts" -ForegroundColor Yellow }
      } elseif ($mode -eq 'MCA') {
        if (Test-Path '.codex/prompts/org') { Write-Host "[WARN] Mode=MCA but ORG prompts present under .codex/prompts/org" -ForegroundColor Yellow }
      }
    }
  } catch {}

  $parity = '.specify/scripts/powershell/parity_check.ps1'
  if (Test-Path $parity) {
    Write-Host "[analyze] Parity check" -ForegroundColor Cyan
    try { & $parity -RepoRoot . | Out-Null } catch { $failures += "parity" }
  } else {
    Write-Host "[analyze] Parity check skipped (script not present yet)" -ForegroundColor Yellow
  }

  $refs = '.specify/scripts/powershell/referenced_scripts_gate.ps1'
  if (Test-Path $refs) {
    Write-Host "[analyze] Referenced-scripts gate" -ForegroundColor Cyan
    try { & $refs -RepoRoot . | Out-Null } catch { $failures += "referenced-scripts" }
  } else {
    Write-Host "[analyze] Referenced-scripts gate skipped (script not present yet)" -ForegroundColor Yellow
  }

  if ($failures.Count -gt 0) {
    Write-Host ("[analyze] FAIL: {0}" -f ($failures -join ', ')) -ForegroundColor Red
    exit 2
  }
  Write-Host "[analyze] PASS" -ForegroundColor Green
  exit 0
}
finally {
  Pop-Location
}
