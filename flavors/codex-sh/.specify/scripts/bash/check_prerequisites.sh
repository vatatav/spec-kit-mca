#!/usr/bin/env bash
set -euo pipefail

require_tasks=0
json=0

usage(){ echo "Usage: $0 [--json] [--require-tasks]" >&2; }

while [[ $# -gt 0 ]]; do
  case "$1" in
    --json) json=1; shift ;;
    --require-tasks) require_tasks=1; shift ;;
    -h|--help) usage; exit 0 ;;
    *) echo "Unknown arg: $1" >&2; usage; exit 2 ;;
  esac
done

root=$(pwd)
specs_dir="$root/specs"
[[ -d "$specs_dir" ]] || { echo "Specs directory not found: $specs_dir" >&2; exit 3; }

# Pick the first feature dir that contains at least spec.md
feature=""
while IFS= read -r -d '' d; do
  if [[ -f "$d/spec.md" ]]; then feature="$d"; break; fi
done < <(find "$specs_dir" -mindepth 1 -maxdepth 2 -type d -print0)

[[ -n "$feature" ]] || { echo "No feature directory with spec.md found under specs/" >&2; exit 4; }

has_spec=0; has_plan=0; has_tasks=0
[[ -f "$feature/spec.md" ]] && has_spec=1
[[ -f "$feature/plan.md" ]] && has_plan=1
[[ -f "$feature/tasks.md" ]] && has_tasks=1

if [[ $require_tasks -eq 1 && $has_tasks -ne 1 ]]; then
  echo "tasks.md not found in $feature (required)" >&2; exit 5
fi

if [[ $json -eq 1 ]]; then
  # Minimal JSON
  printf '{"FEATURE_DIR":"%s","AVAILABLE_DOCS":[%s]}' \
    "${feature//"/\"}" \
    "$( \
      first=1; \
      for n in spec plan tasks; do \
        f="$feature/$n.md"; \
        if [[ -f "$f" ]]; then \
          if [[ $first -eq 1 ]]; then printf '"%s"' "$n"; first=0; else printf ',"%s"' "$n"; fi; \
        fi; \
      done )"
  echo
else
  echo "FEATURE_DIR=$feature"
  echo -n "AVAILABLE_DOCS="
  docs=()
  [[ $has_spec -eq 1 ]] && docs+=(spec)
  [[ $has_plan -eq 1 ]] && docs+=(plan)
  [[ $has_tasks -eq 1 ]] && docs+=(tasks)
  (IFS=,; echo "${docs[*]}" )
fi

exit 0

