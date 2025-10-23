<#!
.SYNOPSIS
  Initialize Spec-Kit for MCA or Original mode by selecting a constitution base and aligning templates.

.DESCRIPTION
  Copies a chosen constitution base into `.specify/memory/constitution.md` and, if ORG mode is selected,
  replaces local templates with the org variants. MCA mode uses local `.specify/templates/*.md` as-is.

.PARAMETER Mode
  MCA (default) or ORG. Determines which template set is active post-init.

.PARAMETER Base
  Constitution base to copy: 'mca' (default) or 'org'.

.PARAMETER AgentShell
  Distribution flavor to use as source (for bases/templates). Default: 'codex-ps'.

.EXAMPLE
  ./init_spec_kit.ps1 -Mode MCA -Base mca -AgentShell codex-ps

.EXAMPLE
  ./init_spec_kit.ps1 -Mode ORG -Base org -AgentShell codex-ps
#>

param(
  [ValidateSet('MCA','ORG')]
  [string]$Mode = 'MCA',

  [ValidateSet('mca','org')]
  [string]$Base = 'mca',

  [string]$AgentShell = 'codex-ps', # kept for forward compatibility; not used for sources

  [switch]$Quiet,
  [switch]$Force,
  [switch]$AutoSetup
)

set-strictmode -version latest
$ErrorActionPreference = 'Stop'

function Join-PathSafe([string]$a, [string]$b) { return [System.IO.Path]::Combine($a,$b) }
function Ensure-Dir([string]$p) { if (-not (Test-Path -LiteralPath $p)) { New-Item -ItemType Directory -Path $p | Out-Null } }

$repoRoot = (Resolve-Path .).Path

# Local source roots (src-only friendly)
$promptsRoot = Join-PathSafe $repoRoot '.codex/prompts'
$promptsMca  = Join-PathSafe $promptsRoot 'mca'
$promptsOrg  = Join-PathSafe $promptsRoot 'org'
$templatesRoot = Join-PathSafe $repoRoot '.specify/templates'
$tmplMca = Join-PathSafe $templatesRoot 'mca'
$tmplOrg = Join-PathSafe $templatesRoot 'org'
$memoryDir = Join-PathSafe $repoRoot '.specify/memory'
$memMca = Join-PathSafe (Join-PathSafe $memoryDir 'mca') 'constitution.md'
$memOrg = Join-PathSafe (Join-PathSafe $memoryDir 'org') 'constitution.md'

Ensure-Dir $promptsRoot
Ensure-Dir $templatesRoot
Ensure-Dir $memoryDir

# Init-mode marker and current mode detection (ask-first behavior)
$markerDir  = Join-PathSafe $repoRoot '.specify'
$markerPath = Join-PathSafe $markerDir '.init-mode'
$existingMode = $null
$existingBase = $null
try {
  if (Test-Path -LiteralPath $markerPath) {
    $lines = Get-Content -LiteralPath $markerPath -Encoding UTF8
    $modeLine = $lines | Where-Object { $_ -like 'Mode=*' } | Select-Object -First 1
    $baseLine = $lines | Where-Object { $_ -like 'Base=*' } | Select-Object -First 1
    if ($modeLine) { $existingMode = $modeLine.Split('=')[1] }
    if ($baseLine) { $existingBase = $baseLine.Split('=')[1] }
  }
} catch {}
if (-not $Force -and $existingMode -and $existingBase -and $existingMode -eq $Mode -and $existingBase -eq $Base) {
  if ($Quiet) {
    Write-Host ("Already in {0}/{1}; no changes applied (Quiet)." -f $Mode,$Base) -ForegroundColor Yellow
    return
  } else {
    try { $ans = Read-Host ("Already in {0}/{1}. Switch anyway? (y/N)" -f $Mode,$Base) } catch { $ans = 'N' }
    if ($ans -notin @('y','Y','yes','YES')) {
      Write-Host 'Staying on current mode/base.' -ForegroundColor Yellow
      return
    }
  }
}

# Seed MCA prompt base if missing and current root has mc*.md (first-run convenience)
if (-not (Test-Path -LiteralPath $promptsMca)) {
  Ensure-Dir $promptsMca
  Get-ChildItem -LiteralPath $promptsRoot -Filter 'mc*.md' -File -ErrorAction SilentlyContinue | ForEach-Object {
    Copy-Item -Force -LiteralPath $_.FullName -Destination (Join-PathSafe $promptsMca $_.Name)
  }
}

# Resolve constitution base
switch ($Base) {
  'mca' { $basePath = $memMca }
  'org' { $basePath = $memOrg }
}
if (-not (Test-Path -LiteralPath $basePath)) {
  throw "Constitution base not found: $basePath"
}

# Apply constitution
$targetConst = Join-PathSafe $memoryDir 'constitution.md'
Copy-Item -LiteralPath $basePath -Destination $targetConst -Force
$changed = @($targetConst)

# Apply templates
if ($Mode -eq 'ORG') {
  if (-not (Test-Path -LiteralPath $tmplOrg)) { throw "Org templates not found: $tmplOrg" }
  Get-ChildItem -LiteralPath $tmplOrg -Filter *.md -File | ForEach-Object {
    $dest = Join-PathSafe $templatesRoot $_.Name
    Copy-Item -LiteralPath $_.FullName -Destination $dest -Force
    $changed += $dest
  }
} else {
  if (-not (Test-Path -LiteralPath $tmplMca)) { throw "MCA templates not found: $tmplMca" }
  Get-ChildItem -LiteralPath $tmplMca -Filter *.md -File | ForEach-Object {
    $dest = Join-PathSafe $templatesRoot $_.Name
    Copy-Item -LiteralPath $_.FullName -Destination $dest -Force
    $changed += $dest
  }
}

# Ensure mc00-init.md exists in prompts root (copy from MCA base if missing)
$mc00 = Join-PathSafe $promptsRoot 'mc00-init.md'
if (-not (Test-Path -LiteralPath $mc00)) {
  $mc00Base = Join-PathSafe $promptsMca 'mc00-init.md'
  if (Test-Path -LiteralPath $mc00Base) {
    Copy-Item -Force -LiteralPath $mc00Base -Destination $mc00
  }
}

# Clear active prompts (root) except mc00-init.md
Get-ChildItem -LiteralPath $promptsRoot -Filter *.md -File -ErrorAction SilentlyContinue |
  Where-Object { $_.Name -ne 'mc00-init.md' } | ForEach-Object { Remove-Item -Force -LiteralPath $_.FullName }

# Activate selected prompt set by copying into root
if ($Mode -eq 'ORG') {
  if (-not (Test-Path -LiteralPath $promptsOrg)) { throw "Org prompts not found: $promptsOrg" }
  Get-ChildItem -LiteralPath $promptsOrg -Filter *.md -File | ForEach-Object {
    Copy-Item -Force -LiteralPath $_.FullName -Destination (Join-PathSafe $promptsRoot $_.Name)
  }
} else {
  if (-not (Test-Path -LiteralPath $promptsMca)) { throw "MCA prompts not found: $promptsMca" }
  Get-ChildItem -LiteralPath $promptsMca -Filter *.md -File | ForEach-Object {
    Copy-Item -Force -LiteralPath $_.FullName -Destination (Join-PathSafe $promptsRoot $_.Name)
  }
}

# Mark init mode
"Mode=$Mode`nBase=$Base`nAgentShell=$AgentShell`nInitializedAtUTC=$((Get-Date).ToUniversalTime().ToString('o'))" |
  Set-Content -LiteralPath $markerPath -Encoding utf8
$changed += $markerPath

Write-Host "Initialization complete" -ForegroundColor Green
Write-Host "Mode: $Mode | Base: $Base | AgentShell: $AgentShell" -ForegroundColor Cyan
Write-Host "Files updated:" -ForegroundColor Yellow
$changed | ForEach-Object { Write-Host " - $_" }

# Suggest next commands (mode-specific)
if ($Mode -eq 'ORG') {
  Write-Host 'Next: /constitution -> /specify' -ForegroundColor Cyan
} else {
  Write-Host 'Next: /mc01-constitute -> /mc02-prep-next-spec' -ForegroundColor Cyan
}

# Optional auto-setup: initialize git, first commit, install pre-commit hook
if ($AutoSetup) {
  try {
    if (-not (Test-Path -LiteralPath (Join-PathSafe $repoRoot '.git'))) {
      git init -b main | Out-Null
      git add . | Out-Null
      git commit -m "chore(init): first commit" | Out-Null
    }
    $hookDir = Join-PathSafe $repoRoot '.git/hooks'
    Ensure-Dir $hookDir
    $preCommitPs1 = Join-PathSafe $repoRoot '.specify/scripts/git-hooks/pre-commit.ps1'
    if (Test-Path -LiteralPath $preCommitPs1) {
      Copy-Item -Force -LiteralPath $preCommitPs1 -Destination (Join-PathSafe $hookDir 'pre-commit.ps1')
      # Create a lightweight pre-commit launcher
      $launcher = "powershell -NoLogo -NoProfile -ExecutionPolicy Bypass -File `"$((Join-PathSafe $hookDir 'pre-commit.ps1'))`""
      Set-Content -LiteralPath (Join-PathSafe $hookDir 'pre-commit') -Encoding ascii -NoNewline -Value $launcher
    }
    Write-Host "Auto-setup completed (git init + pre-commit hook)." -ForegroundColor Green
  } catch {
    Write-Warning "Auto-setup encountered an error: $($_.Exception.Message)"
  }
}




