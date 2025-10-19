<#!
.SYNOPSIS
  Adds or verifies a provenance header on Markdown/text artifacts.

.DESCRIPTION
  Ensures generated artifacts carry a top-of-file provenance header that records
  the generator and timestamp (UTC). For Markdown, the header uses an HTML
  comment so it remains invisible when rendered.

  Header format:
    <!-- Generated-by: /<command> | Timestamp: 2025-10-01T00:00:00Z -->

.PARAMETER Path
  The file to modify or check.

.PARAMETER Generator
  Identifier for the producing command/tool. Ex: "/tasks", "/plan", "manual".

.PARAMETER CheckOnly
  If specified, only verifies that a header exists (and optionally matches the
  provided Generator).

.PARAMETER Force
  If specified, updates an existing header instead of skipping.

.EXAMPLE
  # Add a provenance header for a newly generated tasks.md
  ./provenance.ps1 -Path specs/feature-x/tasks.md -Generator "/tasks"

.EXAMPLE
  # Verify that a file has a provenance header from /tasks
  ./provenance.ps1 -Path specs/feature-x/tasks.md -Generator "/tasks" -CheckOnly
#>

param(
  [Parameter(Mandatory=$true)] [string]$Path,
  [Parameter(Mandatory=$false)] [string]$Generator,
  [switch]$CheckOnly,
  [switch]$Force
)

set-strictmode -version latest
$ErrorActionPreference = 'Stop'

if (-not (Test-Path -LiteralPath $Path)) {
  throw "File not found: $Path"
}

$content = Get-Content -LiteralPath $Path -Raw -Encoding UTF8
$lines = $content -split "`r?`n"

# Support: Markdown and generic text files. For Markdown we use HTML comment.
$timestamp = (Get-Date).ToUniversalTime().ToString('o')
# Defer defaulting the generator to 'manual' until needed.
$effectiveGenerator = $null
if ($Generator) { $effectiveGenerator = $Generator }

function New-Header([string]$gen) {
  $g = 'manual'
  if ($gen) { $g = $gen }
  return "<!-- Generated-by: $g | Timestamp: $timestamp -->"
}

function Has-ProvenanceHeader([string[]]$ls) {
  if ($ls.Count -eq 0) { return $false }
  return $ls[0] -match '^<!--\s*Generated-by:\s*.*\|\s*Timestamp:\s*.*-->\s*$'
}

if ($CheckOnly) {
  if (-not (Has-ProvenanceHeader $lines)) {
    Write-Host "Missing provenance header" -ForegroundColor Red
    exit 2
  }
  if ($PSBoundParameters.ContainsKey('Generator') -and $Generator -and -not ($lines[0] -match [Regex]::Escape("Generated-by: $Generator"))) {
    Write-Host "Header present but generator mismatch" -ForegroundColor Yellow
    exit 1
  }
  Write-Host "Provenance header OK" -ForegroundColor Green
  exit 0
}

if (Has-ProvenanceHeader $lines) {
  if ($Force) {
    $lines[0] = (New-Header $effectiveGenerator)
  } else {
    Write-Host "Header already present. Use -Force to update timestamp/generator." -ForegroundColor Yellow
    Set-Content -LiteralPath $Path -Value ($lines -join "`r`n") -NoNewline -Encoding utf8
    exit 0
  }
} else {
  $lines = @((New-Header $effectiveGenerator)) + $lines
}

Set-Content -LiteralPath $Path -Value ($lines -join "`r`n") -NoNewline -Encoding utf8
Write-Host "Provenance header written to: $Path" -ForegroundColor Green

