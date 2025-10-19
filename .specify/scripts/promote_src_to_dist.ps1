<#!
.SYNOPSIS
  Promote changes from src/ back to dist/<flavor> and user_prompts.

.DESCRIPTION
  Mirrors the tidy src/ view into the authoritative layout:
  - src/codex/prompts            -> dist/<flavor>/.codex/prompts
  - src/specify/templates        -> dist/<flavor>/.specify/templates
  - src/specify/scripts          -> dist/<flavor>/.specify/scripts
  - src/specify/memory           -> dist/<flavor>/.specify/memory
  - src/user_prompts             -> user_prompts

  Use -DryRun to preview changes before copying. This script does not commit.

.PARAMETER Flavor
  Distribution flavor (folder under dist/). Default: codex-ps

.PARAMETER DryRun
  If specified, only prints planned copy operations.

.EXAMPLE
  pwsh -NoProfile -ExecutionPolicy Bypass -File .specify/scripts/promote_src_to_dist.ps1 -DryRun

.EXAMPLE
  pwsh -NoProfile -ExecutionPolicy Bypass -File .specify/scripts/promote_src_to_dist.ps1 -Flavor codex-ps
#>

param(
  [string]$Flavor = 'codex-ps',
  [switch]$DryRun
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$root = (Resolve-Path .).Path
$srcRoot = Join-Path $root 'src'
if (-not (Test-Path $srcRoot)) { throw "src/ not found. Build it via .specify/scripts/sync_src.ps1 first." }

$distRoot = Join-Path $root "dist/$Flavor"
if (-not (Test-Path $distRoot)) { throw "Flavor not found: $distRoot" }

function Promote-Tree([string]$from, [string]$to) {
  if (-not (Test-Path $from)) { return }
  if ($DryRun) {
    Write-Host "[DRY-RUN] Copy $from -> $to"
  } else {
    New-Item -ItemType Directory -Path $to -Force | Out-Null
    Copy-Item -Recurse -Force -Path (Join-Path $from '*') -Destination $to
  }
}

# Map and promote
Promote-Tree (Join-Path $srcRoot 'codex/prompts')         (Join-Path $distRoot '.codex/prompts')
Promote-Tree (Join-Path $srcRoot 'specify/templates')     (Join-Path $distRoot '.specify/templates')
Promote-Tree (Join-Path $srcRoot 'specify/scripts')       (Join-Path $distRoot '.specify/scripts')
Promote-Tree (Join-Path $srcRoot 'specify/memory')        (Join-Path $distRoot '.specify/memory')

# user_prompts at repo root
if (Test-Path (Join-Path $srcRoot 'user_prompts')) {
  $destUP = Join-Path $root 'user_prompts'
  if ($DryRun) {
    Write-Host "[DRY-RUN] Copy src/user_prompts -> $destUP"
  } else {
    if (Test-Path $destUP) { Remove-Item -Recurse -Force $destUP }
    Copy-Item -Recurse -Force -Path (Join-Path $srcRoot 'user_prompts') -Destination $destUP
  }
}

Write-Host (if ($DryRun) { 'Promotion preview complete.' } else { 'Promotion complete.' }) -ForegroundColor Green

