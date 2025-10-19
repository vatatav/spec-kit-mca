#!/usr/bin/env bash
set -euo pipefail

# Set CODEX_HOME under this repo so Codex CLI uses local state
export CODEX_HOME="$(pwd)/.codex"
echo "CODEX_HOME = $CODEX_HOME"

# Start an interactive shell (adjust if you want to auto-run a command)
exec bash -l

