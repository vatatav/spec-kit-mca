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

  [string]$AgentShell = 'codex-ps'
)

set-strictmode -version latest
$ErrorActionPreference = 'Stop'

function Join-PathSafe([string]$a, [string]$b) { return [System.IO.Path]::Combine($a,$b) }
function Ensure-Dir([string]$p) { if (-not (Test-Path -LiteralPath $p)) { New-Item -ItemType Directory -Path $p | Out-Null } }

$repoRoot = (Resolve-Path .).Path

# Source roots (packaged kits place templates at project root)
$constitutionsDir = if (Test-Path (Join-PathSafe $repoRoot '.kit/modes/constitutions')) { 
  Join-PathSafe $repoRoot '.kit/modes/constitutions' 
} else { 
  Join-PathSafe $repoRoot '.specify/templates/constitutions' 
}
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
  # Replace local templates with org variants from packaged templates
  $orgTmplDir = if (Test-Path (Join-PathSafe $repoRoot '.kit/modes/org/templates')) {
    Join-PathSafe $repoRoot '.kit/modes/org/templates'
  } else {
    Join-PathSafe $repoRoot '.specify/templates/org'
  }
  $localTmplDir = Join-PathSafe $repoRoot '.specify/templates'
  if (-not (Test-Path -LiteralPath $orgTmplDir)) { throw "Org templates not found: $orgTmplDir" }
  Ensure-Dir $localTmplDir
  Get-ChildItem -LiteralPath $orgTmplDir -Filter *.md | ForEach-Object {
    $dest = Join-PathSafe $localTmplDir $_.Name
    Copy-Item -LiteralPath $_.FullName -Destination $dest -Force
    $changed += $dest
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


