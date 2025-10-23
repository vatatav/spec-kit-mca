@echo off
setlocal

REM Use current folder name as base title (e.g., spec-kit-mca-ps-0.1.0)
set "ROOT=%CD%"
for %%A in ("%ROOT%") do set "TITLE=%%~nxA"


REM Locate shared banner script robustly
REM Primary: parent of this BAT's directory (repo root) + scripts\codex-banner.ps1
pushd "%~dp0.." >nul 2>&1
set "REPO_ROOT=%CD%"
popd >nul 2>&1

if exist "%REPO_ROOT%\scripts\codex-banner.ps1" (
  set "BANNER_PS1=%REPO_ROOT%\scripts\codex-banner.ps1"
) else if exist "%ROOT%\scripts\codex-banner.ps1" (
  REM Fallback: a local scripts folder under the current root
  set "BANNER_PS1=%ROOT%\scripts\codex-banner.ps1"
) else (
  REM Last resort: relative to this BAT's folder
  set "BANNER_PS1=%~dp0scripts\codex-banner.ps1"
)

REM Title base for banner: show Default or the explicit CODEX_HOME value
if defined CODEX_HOME (
  set "TITLE_BASE=%CODEX_HOME%"
) else (
  set "TITLE_BASE=Default"
)

start "" wt.exe --title "%TITLE%" -d "%ROOT%" -- pwsh -NoLogo -NoExit -File "%BANNER_PS1%" -TitleBase "%TITLE_BASE%"

endlocal

endlocal
