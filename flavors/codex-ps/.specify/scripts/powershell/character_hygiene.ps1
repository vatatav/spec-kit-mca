param(
  [string]$Root = '.',
  [switch]$Fix,
  [switch]$StripEmoji,  # Optional: also remove emoji/symbol bullets
  [string[]]$IncludeExt = @('md','txt','yml','yaml','json','py','ts','js','ps1','psm1','sh','rb','go','rs','java','cs','toml','ini','cfg')
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Get-TargetFiles {
  param([string]$root)
  Get-ChildItem -Path $root -Recurse -File -ErrorAction SilentlyContinue |
    Where-Object {
      $rel = $_.FullName
      $ext = $_.Extension.TrimStart('.').ToLowerInvariant()
      ($IncludeExt -contains $ext) -and ($rel -notmatch "\\\.git\\|node_modules\\|dist\\|build\\|\.venv\\|venv\\|target\\|bin\\|obj\\")
    }
}

$pattern = '[\u00A0\u2000-\u200B\u200C\u200D\u2060\uFEFF\u2010-\u2015\u2212\u2018\u2019\u201C\u201D\u2026]'
if ($StripEmoji) {
  # Include common emoji blocks (Dingbats, Misc Symbols, and Emoji ranges)
  $pattern = $pattern.TrimEnd(']') + '\u2022\u2700-\u27BF\u1F300-\u1F6FF\u1F900-\u1F9FF\u1FA70-\u1FAFF]'
}

function Normalize-Text {
  param([string]$text)
  $orig = $text
  $text = $text -replace "\uFEFF", ''                # BOM / ZWNBSP → remove
  $text = $text -replace "[\u200B\u200C\u200D\u2060]", ''  # zero-width → remove
  $text = $text -replace "\u00A0", ' '                # NBSP → space
  $text = $text -replace "[\u2010-\u2015\u2212]", '-' # Hyphens/dashes → ASCII '-'
  $text = $text -replace "[\u2018\u2019]", "'"        # ' ' → '
  $text = $text -replace "[\u201C\u201D]", '"'        # " " → "
  $text = $text -replace "\u2026", '...'              # ... → ...
  if ($StripEmoji) {
    # Remove common bullets/emoji optionally (preserve standard ASCII '*', '-', '+')
    $text = $text -replace "\u2022", '*'        # • -> *
    $text = $text -replace "[\u2700-\u27BF]", ''
    $text = $text -replace "[\u1F300-\u1F6FF]", ''
    $text = $text -replace "[\u1F900-\u1F9FF]", ''
    $text = $text -replace "[\u1FA70-\u1FAFF]", ''
  }
  # Return
  return @{ text = $text; changed = ($text -ne $orig) }
}

$violations = @()
foreach ($f in Get-TargetFiles -root $Root) {
  $raw = Get-Content -Raw -LiteralPath $f.FullName -Encoding utf8
  if ($raw -match $pattern) {
    if ($Fix) {
      $res = Normalize-Text -text $raw
      if ($res.changed) {
        $res.text | Set-Content -Encoding utf8 -LiteralPath $f.FullName
        Write-Host "Fixed: $($f.FullName)"
      }
    } else {
      $violations += $f.FullName
      Write-Host "Found: $($f.FullName)"
    }
  }
}

if (-not $Fix -and $violations.Count -gt 0) {
  Write-Error ("Character hygiene check failed in {0} file(s). Run with -Fix to normalize." -f $violations.Count)
  exit 1
}

Write-Host ("Character hygiene {0}." -f (if ($Fix) { 'normalization complete' } else { 'check passed' }))

