#!/usr/bin/env pwsh
# Verify that every script referenced by active prompts exists and is eligible for packaging
[CmdletBinding()]
param(
  [string]$RepoRoot='.'
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

Push-Location $RepoRoot
try {
  $promptsRoot = '.codex/prompts'
  if (-not (Test-Path $promptsRoot)) {
    Write-Host "Active prompts folder not found: $promptsRoot" -ForegroundColor Yellow
    exit 0
  }
  $md = Get-ChildItem -Path $promptsRoot -Recurse -File -Include *.md -ErrorAction SilentlyContinue
  # Match references like .specify/scripts/foo.ps1 or .specify/scripts/bar.sh inside prompts
  $regex = [regex]@'
\.specify/scripts/[^\s)\"']+\.(ps1|sh)
'@
  $missing = @()
  foreach ($f in $md) {
    $text = Get-Content -Raw -Encoding UTF8 -LiteralPath $f.FullName
    $m = $regex.Matches($text)
    if ($m.Count -eq 0) { continue }
    foreach ($mm in $m) {
      $rel = $mm.Value
      # Packaging excludes
      if ($rel -match '\bpackage_dist' -or $rel -match '\bexport_pipeline' -or $rel -match '\.specify\/scripts\/git-hooks\/') {
        continue
      }
      if (-not (Test-Path -LiteralPath $rel)) {
        $missing += "MISSING $rel (referenced by $($f.FullName))"
      }
    }
  }
  if ($missing.Count -gt 0) {
    $missing | ForEach-Object { Write-Host $_ -ForegroundColor Red }
    exit 1
  }
  Write-Host "Referenced scripts OK" -ForegroundColor Green
  exit 0
}
finally {
  Pop-Location
}
