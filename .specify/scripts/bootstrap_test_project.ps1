<#!
.SYNOPSIS
  Scaffold a test project from the dist/<flavor> contents and user_prompts.

.DESCRIPTION
  Copies the current distributable (dist/<flavor>) and user_prompts into a
  destination directory to trial the kit on a fresh project. Includes
  pwsh-LOCAL.bat to localize CODEX_HOME when using Codex CLI.

.PARAMETER Destination
  Path to the test project directory to create.

.PARAMETER Flavor
  Distribution flavor (default codex-ps).

.EXAMPLE
  pwsh -NoProfile -ExecutionPolicy Bypass -File .specify/scripts/bootstrap_test_project.ps1 -Destination D:\Projects\test-kit -Flavor codex-ps
#>

param(
  [Parameter(Mandatory=$true)] [string]$Destination,
  [string]$Flavor = 'codex-ps'
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$root = (Resolve-Path .).Path
$dist = Join-Path $root "dist/$Flavor"
if (-not (Test-Path $dist)) { throw "Flavor not found: $dist" }

if (Test-Path $Destination) { Remove-Item -Recurse -Force $Destination }
New-Item -ItemType Directory -Path $Destination | Out-Null

# Copy distributable files
Copy-Item -Recurse -Force -Path (Join-Path $dist '*') -Destination $Destination

# Copy user_prompts
$userPrompts = Join-Path $root 'user_prompts'
if (Test-Path $userPrompts) {
  Copy-Item -Recurse -Force -Path $userPrompts -Destination (Join-Path $Destination 'user_prompts')
}

Write-Host "Test project created at: $Destination" -ForegroundColor Green
Write-Host "Tip: Run pwsh-LOCAL.bat in that folder to localize CODEX_HOME before using /commands." -ForegroundColor Yellow

