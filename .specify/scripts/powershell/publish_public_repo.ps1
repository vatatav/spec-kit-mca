#!/usr/bin/env pwsh
[CmdletBinding()]
param(
  [Parameter(Mandatory=$true)] [string]$RemoteUrl,
  [Parameter(Mandatory=$true)] [ValidateSet('codex-ps','codex-sh')] [string]$Flavor,
  [Parameter(Mandatory=$true)] [string]$Version,
  [string]$Branch='main',
  [switch]$Force
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$root = (Resolve-Path '.').Path
$zip = Join-Path $root "packages/spec-kit-mca-$Flavor-$Version.zip"
if (-not (Test-Path -LiteralPath $zip)) { throw "Package zip not found: $zip" }

$pub = Join-Path $root "out/public-release-$Flavor-$Version"
if (Test-Path $pub) { Remove-Item -Recurse -Force $pub }
New-Item -ItemType Directory -Path $pub | Out-Null

Expand-Archive -LiteralPath $zip -DestinationPath $pub -Force

Push-Location $pub
try {
  git init | Out-Null
  git checkout --orphan $Branch | Out-Null
  git add . | Out-Null
  git commit -m "chore(release): spec-kit-mca $Flavor $Version (dist-as-source)" | Out-Null
  git tag "v$Version" | Out-Null
  git remote add origin $RemoteUrl | Out-Null
  $pushArgs = @('push','-u','origin',$Branch)
  if ($Force) { $pushArgs = @('push','-u','origin',$Branch,'--force') }
  try {
    git @pushArgs | Out-Null
    git push --tags | Out-Null
    Write-Host "Public release pushed to $RemoteUrl ($Branch), tag v$Version" -ForegroundColor Green
  } catch {
    Write-Warning "Push failed: $($_.Exception.Message). You can push manually from: $pub"
  }
} finally {
  Pop-Location
}

