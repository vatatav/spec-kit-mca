@echo off
setlocal

rem child shells inherit this
set "CODEX_HOME=%CD%\.codex"

start "" wt.exe -d "%CD%" ^
  pwsh -NoLogo -NoExit ^
  -Command "Write-Host \"CODEX_HOME = $env:CODEX_HOME\""

endlocal
