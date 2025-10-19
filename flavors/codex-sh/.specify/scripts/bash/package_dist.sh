#!/usr/bin/env bash
set -euo pipefail

version="${1:-}"
flavor="codex-sh"

root=$(pwd)
dist_dir="$root/flavors/$flavor"
[[ -d "$dist_dir" ]] || { echo "Flavor not found: $dist_dir" >&2; exit 2; }

stamp=${version:-$(date -u +%Y%m%d-%H%M%S)}
stage="$root/out/package-$flavor-$stamp"
rm -rf "$stage" && mkdir -p "$stage"

cp -R "$dist_dir/"* "$stage/"

# Remove runtime .codex artifacts if any
rm -rf "$stage/.codex/log" "$stage/.codex/sessions" "$stage/.codex/auth.json" "$stage/.codex/history.jsonl" "$stage/.codex/config.toml" "$stage/.codex/version.json" || true

# Include user_prompts if present
if [[ -d "$root/user_prompts" ]]; then
  cp -R "$root/user_prompts" "$stage/" 
fi

mkdir -p "$root/packages"
zip_path="$root/packages/spec-kit-mca-$flavor-$stamp.zip"
rm -f "$zip_path"
(cd "$stage" && zip -qr "$zip_path" .)
echo "Package created: $zip_path"
