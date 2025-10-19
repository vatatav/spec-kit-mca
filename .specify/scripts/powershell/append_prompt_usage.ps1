#!/usr/bin/env pwsh
[CmdletBinding()]
param(
  [Parameter(Mandatory=$true)] [string]$Prompt,
  [Parameter(Mandatory=$true)] [string]$Step
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$log = Join-Path (Resolve-Path '.').Path 'logs/prompt_usage.md'
if (-not (Test-Path -LiteralPath (Split-Path $log -Parent))) {
  New-Item -ItemType Directory -Path (Split-Path $log -Parent) | Out-Null
}
$ts = (Get-Date).ToUniversalTime().ToString('o')
Add-Content -LiteralPath $log -Encoding UTF8 -Value "| $ts | $Prompt | $Step |"

