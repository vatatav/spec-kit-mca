#!/usr/bin/env bash
set -euo pipefail

path=""
generator=""
check_only=0
force=0

usage(){
  echo "Usage: $0 -p <path> [-g <generator>] [-c] [-f]" >&2
}

while getopts ":p:g:cfh" opt; do
  case "$opt" in
    p) path="$OPTARG" ;;
    g) generator="$OPTARG" ;;
    c) check_only=1 ;;
    f) force=1 ;;
    h) usage; exit 0 ;;
    \?) usage; exit 2 ;;
  esac
done

[[ -n "$path" ]] || { usage; exit 2; }
[[ -f "$path" ]] || { echo "File not found: $path" >&2; exit 3; }

timestamp_utc=$(date -u +%Y-%m-%dT%H:%M:%SZ)
header="<!-- Generated-by: ${generator:-manual} | Timestamp: $timestamp_utc -->"

read -r firstline < "$path" || true
if [[ "$check_only" -eq 1 ]]; then
  if [[ "$firstline" =~ ^<!--[[:space:]]*Generated-by:.*\|[[:space:]]*Timestamp:.*-->[[:space:]]*$ ]]; then
    if [[ -n "$generator" ]] && [[ "$firstline" != *"Generated-by: $generator"* ]]; then
      echo "Header present but generator mismatch"; exit 1
    fi
    echo "Provenance header OK"; exit 0
  else
    echo "Missing provenance header"; exit 2
  fi
fi

tmp=$(mktemp)
trap 'rm -f "$tmp"' EXIT

if [[ "$firstline" =~ ^<!--[[:space:]]*Generated-by:.*\|[[:space:]]*Timestamp:.*-->[[:space:]]*$ ]]; then
  if [[ "$force" -eq 1 ]]; then
    tail -n +2 "$path" > "$tmp"
    { echo "$header"; cat "$tmp"; } > "$path"
  else
    echo "Header already present. Use -f to update."; exit 0
  fi
else
  { echo "$header"; cat "$path"; } > "$tmp" && mv "$tmp" "$path"
fi

echo "Provenance header written to: $path"

