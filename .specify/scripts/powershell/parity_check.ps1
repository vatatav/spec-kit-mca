#!/usr/bin/env pwsh
# Source-only parity check between PS/SH flavors for shared assets
[CmdletBinding()]
param(
  [string]$RepoRoot = '.'
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Normalize-Content {
  param([string]$text)
  # Normalize to LF and strip UTF-8 BOM if present
  $t = $text -replace "`r`n", "`n" -replace "`r", "`n"
  if ($t.StartsWith([char]0xFEFF)) { $t = $t.Substring(1) }
  return $t
}

function Diff-FirstMismatch {
  param([string[]]$a, [string[]]$b)
  $len = [Math]::Max($a.Count, $b.Count)
  for ($i=0; $i -lt $len; $i++) {
    $al = if ($i -lt $a.Count) { $a[$i] } else { '' }
    $bl = if ($i -lt $b.Count) { $b[$i] } else { '' }
    if ($al -ne $bl) { return @{ line = $i+1; left = $al; right = $bl } }
  }
  return $null
}

Push-Location $RepoRoot
try {
  $psRoot = Join-Path 'flavors' 'codex-ps'
  $shRoot = Join-Path 'flavors' 'codex-sh'
  if (-not (Test-Path $psRoot) -or -not (Test-Path $shRoot)) {
    throw "PS/SH flavor roots not found under 'flavors/'."
  }

  # Shared directories to compare between flavors
  $dirs = @(
    '.specify/templates',
    '.specify/templates/constitutions',
    '.codex/prompts',
    # Additional parity scope (best-effort; skipped if not present under flavors)
    '.specify/memory',
    'user_prompts'
  )

  $mismatches = @()
  foreach ($d in $dirs) {
    $psDir = Join-Path $psRoot $d
    if (-not (Test-Path $psDir)) { continue }
    $psFiles = Get-ChildItem -Path $psDir -Recurse -File -Include *.md -ErrorAction SilentlyContinue
    foreach ($pf in $psFiles) {
      $rel = $pf.FullName.Substring((Resolve-Path $psRoot).Path.Length).TrimStart('\\','/')
      $shPath = Join-Path $shRoot $rel
      if (-not (Test-Path $shPath)) {
        $mismatches += "MISSING in SH: $rel"
        continue
      }
      $left  = Normalize-Content (Get-Content -Raw -Encoding UTF8 -LiteralPath $pf.FullName)
      $right = Normalize-Content (Get-Content -Raw -Encoding UTF8 -LiteralPath $shPath)
      if ($left -ne $right) {
        $al = $left -split "`n"
        $bl = $right -split "`n"
        $first = Diff-FirstMismatch -a $al -b $bl
        $ln = $first.line
        $la = $first.left
        $lb = $first.right
        $mismatches += @(
          "DIFF $d/$([IO.Path]::GetFileName($pf.FullName))",
          "  - Line $ln: '$la'",
          "  + Line $ln: '$lb'"
        )
      }
    }
  }

  if ($mismatches.Count -gt 0) {
    $mismatches | ForEach-Object { Write-Host $_ -ForegroundColor Red }
    exit 1
  }
  Write-Host "Parity OK" -ForegroundColor Green
  exit 0
}
finally {
  Pop-Location
}
