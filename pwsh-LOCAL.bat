@echo off
setlocal

rem Root = where this BAT is executed from
set "ROOT=%CD%"
rem child shells inherit this
set "CODEX_HOME=%ROOT%\.codex"

rem Title = leaf name of ROOT (e.g., spec-kit-mca-private-test)
for %%A in ("%ROOT%") do set "TITLE=%%~nxA"

rem Determine variant via marker files in CODEX_HOME (prefer atav)
set "VARIANT="
if exist "%CODEX_HOME%\auth.atav" set "VARIANT=atav"
if not defined VARIANT if exist "%CODEX_HOME%\auth.aiki" set "VARIANT=aiki"
set "WT_TITLE=%TITLE%"
if defined VARIANT set "WT_TITLE=%VARIANT%->%TITLE%"

start "" wt.exe --title "%WT_TITLE%" -d "%ROOT%" -- pwsh -NoLogo -NoExit -Command "Write-Host ( 'Using ' + $( if (Test-Path (Join-Path $env:CODEX_HOME 'auth.atav')) { 'atav' } elseif (Test-Path (Join-Path $env:CODEX_HOME 'auth.aiki')) { 'aiki' } else { 'unknown' } ) + ' authorization' + [System.Environment]::NewLine + 'CODEX_HOME = ' + $env:CODEX_HOME )"

endlocal
