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

  [string]$AgentShell = 'codex-ps',

  [switch]$AutoSetup
)

set-strictmode -version latest
$ErrorActionPreference = 'Stop'

function Join-PathSafe([string]$a, [string]$b) { return [System.IO.Path]::Combine($a,$b) }
function Ensure-Dir([string]$p) { if (-not (Test-Path -LiteralPath $p)) { New-Item -ItemType Directory -Path $p | Out-Null } }

$repoRoot = (Resolve-Path .).Path

# Source roots in flavors (development structure)
$flavorRoot = Join-PathSafe (Join-PathSafe $repoRoot 'flavors') $AgentShell
if (-not (Test-Path -LiteralPath $flavorRoot)) {
  throw "Flavor not found: $flavorRoot"
}

$constitutionsDir = Join-PathSafe $flavorRoot '.specify/templates/constitutions'
switch ($Base) {
  'mca' { $basePath = Join-PathSafe $constitutionsDir 'mca_constitution_base.md' }
  'org' { $basePath = Join-PathSafe $constitutionsDir 'org_constitution_base.md' }
}

if (-not (Test-Path -LiteralPath $basePath)) {
  throw "Constitution base not found: $basePath"
}

# Target locations
$memoryDir = Join-PathSafe $repoRoot '.specify/memory'
Ensure-Dir $memoryDir
$targetConst = Join-PathSafe $memoryDir 'constitution.md'

Copy-Item -LiteralPath $basePath -Destination $targetConst -Force

$changed = @($targetConst)

if ($Mode -eq 'ORG') {
  # Replace local templates with ORG variants from flavor
  $orgTmplDir = Join-PathSafe $flavorRoot '.specify/templates/org'
  $localTmplDir = Join-PathSafe $repoRoot '.specify/templates'
  if (-not (Test-Path -LiteralPath $orgTmplDir)) { throw "Org templates not found: $orgTmplDir" }
  Ensure-Dir $localTmplDir
  Get-ChildItem -LiteralPath $orgTmplDir -Filter *.md | ForEach-Object {
    $dest = Join-PathSafe $localTmplDir $_.Name
    Copy-Item -LiteralPath $_.FullName -Destination $dest -Force
    $changed += $dest
  }

  # Update active prompts: hide MCA mc* and expose ORG prompts
  $activePrompts = Join-PathSafe $repoRoot '.codex/prompts'
  Ensure-Dir $activePrompts
  $mcaDisabled = Join-PathSafe $activePrompts '_mca_disabled'
  Ensure-Dir $mcaDisabled
  Get-ChildItem -LiteralPath $activePrompts -Filter 'mc*.md' -File -ErrorAction SilentlyContinue | ForEach-Object {
    Move-Item -Force -LiteralPath $_.FullName -Destination (Join-PathSafe $mcaDisabled $_.Name)
  }
  $orgSrc = Join-PathSafe $flavorRoot '.codex/prompts/org'
  if (Test-Path -LiteralPath $orgSrc) {
    Copy-Item -Recurse -Force -Path (Join-PathSafe $orgSrc '*') -Destination (Join-PathSafe $activePrompts 'org')
  }
}

# Mark init mode
$markerDir = Join-PathSafe $repoRoot '.specify'
$markerPath = Join-PathSafe $markerDir '.init-mode'
"Mode=$Mode`nBase=$Base`nAgentShell=$AgentShell`nInitializedAtUTC=$((Get-Date).ToUniversalTime().ToString('o'))" |
  Set-Content -LiteralPath $markerPath -Encoding utf8
$changed += $markerPath

Write-Host "Initialization complete" -ForegroundColor Green
Write-Host "Mode: $Mode | Base: $Base | AgentShell: $AgentShell" -ForegroundColor Cyan
Write-Host "Files updated:" -ForegroundColor Yellow
$changed | ForEach-Object { Write-Host " - $_" }

# Suggest next step based on latest feature artifacts
try {
  $specRoot = Join-PathSafe $repoRoot 'specs'
  if (Test-Path $specRoot) {
    $latest = Get-ChildItem -Path $specRoot -Directory | Where-Object { $_.Name -match '^(\d{3})-' } | Sort-Object Name -Descending | Select-Object -First 1
    if ($latest) {
      $specPath  = Join-PathSafe $latest.FullName 'spec.md'
      $planPath  = Join-PathSafe $latest.FullName 'plan.md'
      $tasksPath = Join-PathSafe $latest.FullName 'tasks.md'
      $next = '/mc02-specify'
      if (Test-Path $specPath) { $next = '/mc04-plan' }
      if (Test-Path $planPath) { $next = '/mc05-tasks' }
      if (Test-Path $tasksPath) { $next = '/mc06-analyze' }
      Write-Host ("Suggested next command: {0}" -f $next) -ForegroundColor Cyan
    }
  }
} catch {}

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


