<#!
.SYNOPSIS
  Collects key project artifacts into a timestamped export folder, optionally zipping.

.DESCRIPTION
  Exports the constitution, templates, user prompts, and a small set of recent
  session logs for provenance/traceability. Produces a MANIFEST.json listing
  included files and metadata.

.PARAMETER DestinationRoot
  Root directory under which the timestamped export folder is created. Default: ./exports

.PARAMETER Zip
  If provided, compresses the export folder into a .zip and leaves both folder and zip.

.PARAMETER RecentSessions
  Number of most recent session files (*.jsonl) from .codex/sessions to include. Default: 5

.EXAMPLE
  ./export_pipeline.ps1

.EXAMPLE
  ./export_pipeline.ps1 -DestinationRoot out -Zip -RecentSessions 10
#>

param(
  [string]$DestinationRoot = "exports",
  [switch]$Zip,
  [int]$RecentSessions = 5
)

set-strictmode -version latest
$ErrorActionPreference = 'Stop'

function New-Dir([string]$p) {
  if (-not (Test-Path -LiteralPath $p)) { New-Item -ItemType Directory -Path $p | Out-Null }
}

$timestamp = (Get-Date).ToUniversalTime().ToString('yyyyMMdd-HHmmss')
$exportRoot = Join-Path -Path (Resolve-Path .).Path -ChildPath $DestinationRoot
New-Dir $exportRoot

$exportDir = Join-Path $exportRoot "export-$timestamp"
New-Dir $exportDir

# Copy constitution
$paths = @()
$constitution = ".specify/memory/constitution.md"
if (Test-Path $constitution) {
  $dest = Join-Path $exportDir "constitution.md"
  Copy-Item -LiteralPath $constitution -Destination $dest -Force
  $paths += $dest
}

# Copy templates
$templatesDir = ".specify/templates"
if (Test-Path $templatesDir) {
  $destT = Join-Path $exportDir "templates"
  New-Dir $destT
  Get-ChildItem -LiteralPath $templatesDir -Filter *.md | ForEach-Object {
    $tDest = Join-Path $destT $_.Name
    Copy-Item -LiteralPath $_.FullName -Destination $tDest -Force
    $paths += $tDest
  }
}

# Copy user prompts (if present)
$userPromptsDir = ".codex/prompts/codex_user_prompts"
if (Test-Path $userPromptsDir) {
  $destP = Join-Path $exportDir "prompts"
  New-Dir $destP
  Get-ChildItem -LiteralPath $userPromptsDir -Filter *.md | ForEach-Object {
    $pDest = Join-Path $destP $_.Name
    Copy-Item -LiteralPath $_.FullName -Destination $pDest -Force
    $paths += $pDest
  }
}

# Copy a few recent session logs
$sessionsRoot = ".codex/sessions"
if (Test-Path $sessionsRoot) {
  $destS = Join-Path $exportDir "sessions"
  New-Dir $destS
  $recent = Get-ChildItem -LiteralPath $sessionsRoot -Recurse -Filter *.jsonl `
            | Sort-Object LastWriteTime -Descending `
            | Select-Object -First $RecentSessions
  foreach ($f in $recent) {
    $sDest = Join-Path $destS $f.Name
    Copy-Item -LiteralPath $f.FullName -Destination $sDest -Force
    $paths += $sDest
  }
}

# Manifest
$manifest = [ordered]@{
  generated_at_utc = (Get-Date).ToUniversalTime().ToString('o')
  export_dir       = $exportDir
  files            = $paths
}
$manifestPath = Join-Path $exportDir "MANIFEST.json"
$manifest | ConvertTo-Json -Depth 5 | Set-Content -LiteralPath $manifestPath -Encoding utf8

Write-Host "Export created at: $exportDir" -ForegroundColor Green

if ($Zip) {
  $zipPath = "$exportDir.zip"
  if (Test-Path $zipPath) { Remove-Item -LiteralPath $zipPath -Force }
  Compress-Archive -Path (Join-Path $exportDir '*') -DestinationPath $zipPath
  Write-Host "Zip archive created: $zipPath" -ForegroundColor Green
}

