#!/usr/bin/env bash
set -euo pipefail

root=$(pwd)
out_dir="$root/exports"
mkdir -p "$out_dir"
stamp=$(date -u +%Y%m%d-%H%M%S)
zip_path="$out_dir/export-$stamp.zip"

tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT

mkdir -p "$tmp/.specify/templates" "$tmp/.codex/prompts"
cp -R .specify/templates "$tmp/.specify/"
cp -R .codex/prompts "$tmp/.codex/"
if [[ -f .specify/memory/constitution.md ]]; then
  mkdir -p "$tmp/.specify/memory" && cp .specify/memory/constitution.md "$tmp/.specify/memory/"
fi

(cd "$tmp" && zip -qr "$zip_path" .)
echo "Export created: $zip_path"
