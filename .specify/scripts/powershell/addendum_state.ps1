#!/usr/bin/env pwsh
# Compute and persist an Addendum-ID for a given command prompt file.
# - Extracts the active Addendum block from a prompt (between the first line starting with
#   "Addendum:" and the line containing "ARCHIVE BELOW - DO NOT EXECUTE").
# - Normalizes content (UTF-8, CRLF→LF, trims trailing spaces) and computes SHA-256.
# - Optional: persists state under .codex/state/addenda/<command>.id and updates the
#   runtime prompt filename to include YY (two digits), incrementing only when the
#   Addendum-ID changes.

[CmdletBinding()] param(
  [Parameter(Mandatory=$false)][string]$Command,            # e.g., mc07-implement
  [Parameter(Mandatory=$false)][string]$PromptPath,         # e.g., user_prompts/implement_prompt.md
  [switch]$SetState,                                        # write .codex/state and update runtime prompt filename
  [switch]$NoPromptRename                                   # when -SetState, skip renaming runtime prompt file
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Get-ActiveAddendumBlock([string]$path) {
  if (-not (Test-Path -LiteralPath $path)) { throw "Prompt not found: $path" }
  $raw = Get-Content -LiteralPath $path -Encoding UTF8 | ForEach-Object { $_ }
  $in = $false
  $lines = @()
  foreach ($line in $raw) {
    if (-not $in) {
      if ($line -match '^Addendum:\s') { $in = $true; $lines += $line; continue }
      continue
    }
    if ($line -match 'ARCHIVE BELOW\s*-\s*DO NOT EXECUTE' -or $line -match 'ARCHIVE BELOW\s*-\s*DO NOT EXECUTE') { break }
    $lines += $line
  }
  if ($lines.Count -eq 0) { throw "Could not find an active Addendum block in $path" }
  # Normalize: CRLF→LF, trim trailing spaces
  $norm = ($lines | ForEach-Object { ($_ -replace '\s+$','') }) -join "`n"
  return $norm
}

function Get-HashHex([string]$text) {
  $bytes = [System.Text.Encoding]::UTF8.GetBytes($text)
  $sha = [System.Security.Cryptography.SHA256]::Create()
  $hash = $sha.ComputeHash($bytes)
  ($hash | ForEach-Object { $_.ToString('x2') }) -join ''
}

function Read-State([string]$cmd) {
  $stateDir = '.codex/state/addenda'
  $statePath = Join-Path $stateDir ("{0}.id" -f $cmd)
  if (-not (Test-Path $statePath)) { return @{ path=$statePath; exists=$false; id=''; yy='00'; executed_at='' } }
  $kv = Get-Content -LiteralPath $statePath -Encoding UTF8 | Where-Object { $_ -match '=' }
  $map = @{}
  foreach ($l in $kv) {
    $pair = $l.Split('=',2)
    if ($pair.Count -eq 2) { $map[$pair[0].Trim()] = $pair[1].Trim() }
  }
  return @{ path=$statePath; exists=$true; id=($map['id']); yy=($map['yy']); executed_at=($map['executed_at']) }
}

function Write-State([string]$cmd, [string]$id, [string]$yy) {
  $stateDir = '.codex/state/addenda'
  if (-not (Test-Path $stateDir)) { New-Item -ItemType Directory -Path $stateDir | Out-Null }
  $statePath = Join-Path $stateDir ("{0}.id" -f $cmd)
  $now = (Get-Date).ToUniversalTime().ToString('o')
  @(
    "id=$id",
    "yy=$yy",
    "executed_at=$now"
  ) | Set-Content -LiteralPath $statePath -Encoding UTF8
  return $statePath
}

function Next-YY([string]$yy) {
  if (-not $yy -or -not ($yy -match '^\d{2}$')) { return '01' }
  $n = [int]$yy
  $n++
  return ('{0:00}' -f $n)
}

function Update-RuntimePrompt([string]$cmd, [string]$yy, [string]$id) {
  $rtDir = '.codex/prompts'
  if (-not (Test-Path $rtDir)) { return }
  $base = Join-Path $rtDir ("{0}.md" -f $cmd)
  $from = if (Test-Path $base) { $base } else {
    # fall back to the highest YY present
    $cand = Get-ChildItem -LiteralPath $rtDir -File -Filter ("{0}-*.md" -f $cmd) | Sort-Object Name | Select-Object -Last 1
    if ($cand) { $cand.FullName } else { $null }
  }
  if (-not $from) { return }
  $to = Join-Path $rtDir ("{0}-{1}.md" -f $cmd, $yy)
  Copy-Item -LiteralPath $from -Destination $to -Force
  # Prepend last executed header if not present
  $header = "<!-- Last-Executed-Addendum-ID: $id at $((Get-Date).ToUniversalTime().ToString('o')) -->"
  $content = Get-Content -LiteralPath $to -Encoding UTF8
  if ($content.Length -eq 0 -or ($content[0] -notmatch 'Last-Executed-Addendum-ID')) {
    @($header) + $content | Set-Content -LiteralPath $to -Encoding UTF8
  }
  return $to
}

if (-not $PromptPath) {
  if (-not $Command) { throw 'Provide -Command or -PromptPath' }
  # Best-effort map common names: mc07-implement → user_prompts/implement_prompt.md
  $name = $Command -replace '^mc\d{2}-',''
  $PromptPath = Join-Path 'user_prompts' ("{0}_prompt.md" -f $name)
}

if (-not $Command) {
  # derive from filename if not provided
  $bn = [System.IO.Path]::GetFileNameWithoutExtension($PromptPath)
  # try to find mcXX from content title lines; otherwise use filename
  $Command = $bn
}

$block = Get-ActiveAddendumBlock -path $PromptPath
$id = Get-HashHex -text $block
$state = Read-State -cmd $Command

if ($state.exists -and $state.id -eq $id) {
  Write-Output ("UNCHANGED id={0} yy={1}" -f $id, $state.yy)
  exit 0
}

$next = Next-YY -yy $state.yy
Write-Output ("CHANGED id={0} next_yy={1}" -f $id, $next)

if ($SetState) {
  $p = Write-State -cmd $Command -id $id -yy $next
  if (-not $NoPromptRename) { Update-RuntimePrompt -cmd $Command -yy $next -id $id | Out-Null }
  Write-Output ("STATE WRITTEN: {0}" -f $p)
}

exit 0


