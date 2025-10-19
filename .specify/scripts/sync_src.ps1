<#!
.SYNOPSIS
  Build a tidy src/ view of the distributable content.

.DESCRIPTION
  Copies the active distribution flavor (dist/<flavor>) plus user_prompts into
  a tidy src/ tree for easy browsing (no symlinks). Intended as a developer
  convenience view; source of truth remains under dist/ and user_prompts/.

.PARAMETER Flavor
  Distribution flavor to mirror. Default: codex-ps

.EXAMPLE
  pwsh -NoProfile -ExecutionPolicy Bypass -File .specify/scripts/sync_src.ps1

.EXAMPLE
  pwsh -NoProfile -ExecutionPolicy Bypass -File .specify/scripts/sync_src.ps1 -Flavor codex-ps
#>

param(
  [string]$Flavor = 'codex-ps'
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$root = (Resolve-Path .).Path
$dist = Join-Path $root "dist/$Flavor"
if (-not (Test-Path $dist)) { throw "Flavor not found: $dist" }

$srcRoot = Join-Path $root 'src'
if (Test-Path $srcRoot) { Remove-Item -Recurse -Force $srcRoot }
New-Item -ItemType Directory -Path $srcRoot | Out-Null

# Map dist content to tidy layout
$map = @{
  (Join-Path $dist '.codex/prompts')              = (Join-Path $srcRoot 'codex/prompts')
  (Join-Path $dist '.specify/templates')          = (Join-Path $srcRoot 'specify/templates')
  (Join-Path $dist '.specify/scripts')            = (Join-Path $srcRoot 'specify/scripts')
  (Join-Path $dist '.specify/memory')             = (Join-Path $srcRoot 'specify/memory')
}

foreach ($kvp in $map.GetEnumerator()) {
  $from = $kvp.Key; $to = $kvp.Value
  if (Test-Path $from) {
    New-Item -ItemType Directory -Path $to -Force | Out-Null
    Copy-Item -Recurse -Force -Path (Join-Path $from '*') -Destination $to
  }
}

# Include user_prompts in tidy view
$userPrompts = Join-Path $root 'user_prompts'
if (Test-Path $userPrompts) {
  Copy-Item -Recurse -Force -Path $userPrompts -Destination (Join-Path $srcRoot 'user_prompts')
}

# Manifest
$manifest = [ordered]@{
  generated_at_utc = (Get-Date).ToUniversalTime().ToString('o')
  flavor           = $Flavor
  source_map       = $map.Keys
  include          = @('user_prompts')
}
$manifest | ConvertTo-Json -Depth 5 | Set-Content -LiteralPath (Join-Path $srcRoot 'MANIFEST.json') -Encoding utf8

Write-Host "src/ view created at: $srcRoot" -ForegroundColor Green

