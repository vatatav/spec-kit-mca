#!/usr/bin/env bash
set -euo pipefail

mode="MCA"
base="mca"
flavor="codex-sh"

usage(){
  echo "Usage: $0 [-m MCA|ORG] [-b mca|org]" >&2
}

while getopts ":m:b:h" opt; do
  case "$opt" in
    m) mode="$OPTARG" ;;
    b) base="$OPTARG" ;;
    h) usage; exit 0 ;;
    \?) usage; exit 2 ;;
  esac
done

project_root=$(git rev-parse --show-toplevel 2>/dev/null || pwd)

if [[ -d "$project_root/.kit/modes/constitutions" ]]; then
  constitutions_dir="$project_root/.kit/modes/constitutions"
else
  constitutions_dir="$project_root/.specify/templates/constitutions"
fi
case "$base" in
  mca) base_path="$constitutions_dir/mca_constitution_base.md" ;;
  org) base_path="$constitutions_dir/org_constitution_base.md" ;;
  *) echo "Invalid base: $base" >&2; exit 2 ;;
esac

if [[ ! -f "$base_path" ]]; then
  echo "Constitution base not found: $base_path" >&2; exit 3
fi

memory_dir="$project_root/.specify/memory"
mkdir -p "$memory_dir"
target_const="$memory_dir/constitution.md"
cp -f "$base_path" "$target_const"

if [[ "$mode" == "ORG" ]]; then
  if [[ -d "$project_root/.kit/modes/org/templates" ]]; then
    org_src="$project_root/.kit/modes/org/templates"
  else
    org_src="$project_root/.specify/templates/org"
  fi
  dst="$project_root/.specify/templates"
  mkdir -p "$dst"
  cp -f "$org_src"/*.md "$dst"/
fi

marker_path="$project_root/.specify/.init-mode"
mkdir -p "$project_root/.specify"
printf "Mode=%s\nBase=%s\nAgentShell=%s\nInitializedAtUTC=%s\n" \
  "$mode" "$base" "$flavor" "$(date -u +%Y-%m-%dT%H:%M:%SZ)" > "$marker_path"

echo "Initialization complete"
echo "Mode: $mode | Base: $base | Flavor: $flavor"
echo "Files updated:"; printf " - %s\n" "$target_const" "$marker_path"
