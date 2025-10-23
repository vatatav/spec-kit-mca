<#!
.SYNOPSIS
  Create a zip from the src/ tree only (no renames, no filtering beyond optional *.bak/*.tmp cleanup).

.DESCRIPTION
  Stages the contents of ./src into a temporary folder and zips it under ./packages.
  The archive root mirrors src’s top-level layout (e.g., .codex/, .specify/, user_prompts/).

.PARAMETER Version
  Optional version label for the package filename. Default: UTC timestamp.

.PARAMETER Name
  Optional package base name. Default: repo folder name + '-src'.

.PARAMETER CleanBackups
  If set, removes *.bak and *.tmp from the staged copy before zipping.

.EXAMPLE
  pwsh -NoProfile -ExecutionPolicy Bypass -File src/.specify/scripts/powershell/package_from_src.ps1 -Version 0.1.1

.EXAMPLE
  pwsh -NoProfile -ExecutionPolicy Bypass -File src/.specify/scripts/powershell/package_from_src.ps1 -Name myproj -Version 1.0.0 -CleanBackups
#>

param(
  [string]$Version,
  [string]$Name,
  [switch]$CleanBackups
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$root = (Resolve-Path .).Path
$srcRoot = Join-Path $root 'src'
if (-not (Test-Path $srcRoot)) { throw "src/ not found at: $srcRoot" }

# Determine package name and stamp
$repoName = Split-Path $root -Leaf
$baseName = if ($Name) { $Name } else { "$repoName-src" }
$stamp = if ($Version) { $Version } else { (Get-Date).ToUniversalTime().ToString('yyyyMMdd-HHmmss') }

# Stage directory
$stageRoot = Join-Path $root "out/package-src-$stamp"
if (Test-Path $stageRoot) { Remove-Item -Recurse -Force $stageRoot }
New-Item -ItemType Directory -Path $stageRoot | Out-Null

# Copy src contents as-is
Copy-Item -Recurse -Force -Path (Join-Path $srcRoot '*') -Destination $stageRoot

# Optional cleanup of backup/temp files
if ($CleanBackups) {
  Get-ChildItem -Path $stageRoot -Recurse -File -Include *.bak,*.tmp -ErrorAction SilentlyContinue |
    ForEach-Object { Remove-Item -LiteralPath $_.FullName -Force }
}

# Ensure packages folder
$pkgDir = Join-Path $root 'packages'
if (-not (Test-Path $pkgDir)) { New-Item -ItemType Directory -Path $pkgDir | Out-Null }

# Build zip
$zipPath = Join-Path $pkgDir ("{0}-{1}.zip" -f $baseName, $stamp)
if (Test-Path $zipPath) { Remove-Item -LiteralPath $zipPath -Force }
Compress-Archive -Path (Join-Path $stageRoot '*') -DestinationPath $zipPath

Write-Host ("Package created: {0}" -f $zipPath) -ForegroundColor Green

# Emit checksum for convenience
try {
  $sha = (Get-FileHash -Algorithm SHA256 -Path $zipPath).Hash
  Write-Host ("SHA256: {0}" -f $sha) -ForegroundColor Cyan
} catch {}

