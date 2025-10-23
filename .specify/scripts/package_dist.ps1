<#!
.SYNOPSIS
  Package a clean distributable from flavors/<flavor>, excluding runtime artifacts.

.DESCRIPTION
  Creates a versioned zip under ./packages for a given flavor (default codex-ps).
  Ensures runtime files are not included (e.g., .codex/log, sessions, auth, history).
  Reads from flavors/<flavor> so the staged zip root matches the shipped kit layout.

.PARAMETER Flavor
  Flavor to package (folder under ./flavors). Default: codex-ps

.PARAMETER Version
  Optional version label for the package filename. Default: date-time stamp.

.EXAMPLE
  ./package_dist.ps1 -Flavor codex-ps -Version 0.1.0
#>

param(
  [string]$Flavor = 'codex-ps',
  [string]$Version,
  [switch]$UseGenericPrompts
)

set-strictmode -version latest
$ErrorActionPreference = 'Stop'

$root = (Resolve-Path .).Path
$dist = Join-Path $root "flavors/$Flavor"
if (-not (Test-Path -LiteralPath $dist)) { throw "Flavor not found: $dist" }

# Build a temp staging dir filtering out runtime .codex files
$stamp = if ($Version) { $Version } else { (Get-Date).ToUniversalTime().ToString('yyyyMMdd-HHmmss') }
$stageRoot = Join-Path $root "out/package-$Flavor-$stamp"
if (Test-Path $stageRoot) { Remove-Item -Recurse -Force $stageRoot }
New-Item -ItemType Directory -Path $stageRoot | Out-Null

Copy-Item -Recurse -Force -Path (Join-Path $dist '*') -Destination $stageRoot

# Remove runtime artifacts just-in-case
$runtime = @(
  ".codex/log",
  ".codex/sessions",
  ".codex/auth.json",
  ".codex/history.jsonl",
  ".codex/config.toml",
  ".codex/version.json"
)
foreach ($rel in $runtime) {
  $p = Join-Path $stageRoot $rel
  if (Test-Path $p) { Remove-Item -Recurse -Force $p }
}

# Remove developer-only content from the staged package (selective)
# Keep runtime helper scripts for the agent flow; remove only packaging/export/CI artifacts.
$devOnlyPaths = @(
  "DEVELOPERS.md",
  "docs",
  ".github",
  "CONTRIBUTING.md",
  ".specify/scripts/git-hooks"
)
foreach ($rel in $devOnlyPaths) {
  $p = Join-Path $stageRoot $rel
  if (Test-Path $p) { Remove-Item -Recurse -Force $p }
}

# Remove developer-only scripts by pattern (package/export helpers)
$devOnlyPatterns = @(
  "*.package_dist.*",
  "package_dist.*",
  "export_pipeline.*"
)
if (Test-Path (Join-Path $stageRoot '.specify/scripts')) {
  Get-ChildItem -Path (Join-Path $stageRoot '.specify/scripts') -Recurse -File |
    Where-Object { $name = $_.Name; $devOnlyPatterns | ForEach-Object { if ($name -like $_) { $true } } } |
    ForEach-Object { Remove-Item -LiteralPath $_.FullName -Force }
}

# Normalize line endings and encoding for text files (Markdown, prompts)
function Normalize-TextFile([string]$path) {
  try {
    $utf8NoBom = New-Object System.Text.UTF8Encoding($false)
    $txt = [System.IO.File]::ReadAllText($path, [System.Text.Encoding]::UTF8)
    # Normalize to LF then back to CRLF for consistency on Windows
    $lf = $txt -replace "\r\n?", "`n"
    $crlf = $lf -replace "`n", "`r`n"
    [System.IO.File]::WriteAllText($path, $crlf, $utf8NoBom)
  } catch {}
}

Get-ChildItem -Path $stageRoot -Recurse -Include *.md -File | ForEach-Object { Normalize-TextFile $_.FullName }

# Pre-check: referenced-scripts gate (fail packaging if missing referenced scripts)
$refsGate = Join-Path $root '.specify/scripts/powershell/referenced_scripts_gate.ps1'
if (Test-Path $refsGate) {
  Write-Host "[package] referenced-scripts gate" -ForegroundColor Cyan
  & $refsGate -RepoRoot $root
  if ($LASTEXITCODE -ne 0) { throw "Referenced-scripts gate failed." }
}

# Include user_prompts defaults if present (rename to mcXX-*.md; exclude legacy mca_flow)
$userPrompts = Join-Path $root 'user_prompts'
if (Test-Path $userPrompts) {
  $destUP = Join-Path $stageRoot 'user_prompts'
  Copy-Item -Recurse -Force -Path $userPrompts -Destination $destUP
  # Remove legacy content
  $legacy = Join-Path $destUP 'mca_flow'
  if (Test-Path $legacy) { Remove-Item -Recurse -Force $legacy }
  # Optional generic prompt promotion
  if ($UseGenericPrompts) {
    $generic = Join-Path $userPrompts 'specify_prompt.generic.md'
    if (Test-Path $generic) {
      Copy-Item -Force -LiteralPath $generic -Destination (Join-Path $destUP 'specify_prompt.md')
    }
  }
  # Rename known prompts to mcXX-*.md for distribution
  $map = @{
    'init-spec-kit_prompt.md' = 'mc00-init.md'
    'constitution_prompt.md'  = 'mc01-constitution.md'
    'prep-next-spec_prompt.md'= 'mc02-prep-next-spec.md'
    'specify_prompt.md'       = 'mc03-specify.md'
    'clarify_prompt.md'       = 'mc04-clarify.md'
    'plan_prompt.md'          = 'mc05-plan.md'
    'tasks_prompt.md'         = 'mc06-tasks.md'
    'analyze_prompt.md'       = 'mc07-analyze.md'
    'implement_prompt.md'     = 'mc08-implement.md'
  }
  foreach ($k in $map.Keys) {
    $src = Join-Path $destUP $k
    if (Test-Path $src) {
      $dst = Join-Path $destUP $map[$k]
      Move-Item -Force -LiteralPath $src -Destination $dst
    }
  }
}

# Normalize timestamps for determinism (set to package stamp) - run last, after all file edits
try {
  $uniform = [DateTime]::ParseExact($stamp, 'yyyyMMdd-HHmmss', [System.Globalization.CultureInfo]::InvariantCulture, [System.Globalization.DateTimeStyles]::AssumeUniversal)
} catch {
  $uniform = (Get-Date).ToUniversalTime()
}
Get-ChildItem -Path $stageRoot -Recurse -File | ForEach-Object {
  try {
    $_.LastWriteTimeUtc = $uniform
  } catch {}
}

# Ensure packages dir
$pkgDir = Join-Path $root 'packages'
if (-not (Test-Path $pkgDir)) { New-Item -ItemType Directory -Path $pkgDir | Out-Null }

$zipPath = Join-Path $pkgDir "spec-kit-mca-$Flavor-$stamp.zip"
if (Test-Path $zipPath) { Remove-Item -LiteralPath $zipPath -Force }
Compress-Archive -Path (Join-Path $stageRoot '*') -DestinationPath $zipPath

Write-Host "Package created: $zipPath" -ForegroundColor Green

