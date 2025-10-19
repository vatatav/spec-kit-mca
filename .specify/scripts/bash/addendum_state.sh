#!/usr/bin/env bash
set -euo pipefail

# Compute and optionally persist an Addendum-ID from a prompt file.
# Usage:
#   addendum_state.sh -c mc07-implement [-p user_prompts/implement_prompt.md] [--set-state] [--no-prompt-rename]

command_name=""
prompt_path=""
set_state=0
no_prompt_rename=0

while [[ $# -gt 0 ]]; do
  case "$1" in
    -c|--command) command_name="$2"; shift 2;;
    -p|--prompt) prompt_path="$2"; shift 2;;
    --set-state) set_state=1; shift;;
    --no-prompt-rename) no_prompt_rename=1; shift;;
    *) echo "Unknown arg: $1"; exit 1;;
  esac
done

if [[ -z "$prompt_path" ]]; then
  if [[ -z "$command_name" ]]; then
    echo "Provide -c <command> or -p <prompt_path>" >&2; exit 1
  fi
  base=${command_name#mc??-}
  prompt_path="user_prompts/${base}_prompt.md"
fi

if [[ ! -f "$prompt_path" ]]; then
  echo "Prompt not found: $prompt_path" >&2; exit 1
fi

# Extract active Addendum block: from first line starting with "Addendum:" to the line containing "ARCHIVE BELOW"
addendum=$(awk '
  BEGIN{inblk=0}
  /^Addendum: /{inblk=1}
  /ARCHIVE BELOW/{if(inblk==1){exit} }
  { if(inblk==1) print }
' "$prompt_path")

if [[ -z "$addendum" ]]; then
  echo "Could not find an active Addendum block in $prompt_path" >&2; exit 1
fi

# Normalize: trim trailing spaces and CRLF→LF
norm=$(printf "%s\n" "$addendum" | sed -E 's/[[:space:]]+$//')

# SHA-256 (prefer sha256sum, fallback to shasum -a 256)
if command -v sha256sum >/dev/null 2>&1; then
  id=$(printf "%s" "$norm" | sha256sum | awk '{print $1}')
elif command -v shasum >/dev/null 2>&1; then
  id=$(printf "%s" "$norm" | shasum -a 256 | awk '{print $1}')
else
  echo "No sha256sum/shasum available" >&2; exit 2
fi

state_dir=".codex/state/addenda"
state_path="$state_dir/${command_name}.id"
yy="00"

if [[ -f "$state_path" ]]; then
  prev_id=$(awk -F= '/^id=/{print $2}' "$state_path" | tr -d '\r')
  prev_yy=$(awk -F= '/^yy=/{print $2}' "$state_path" | tr -d '\r')
  if [[ "$prev_id" == "$id" ]]; then
    echo "UNCHANGED id=$id yy=${prev_yy:-00}"
    exit 0
  fi
  yy=${prev_yy:-00}
fi

# next YY
printf -v next_yy "%02d" $((10#$yy + 1))
echo "CHANGED id=$id next_yy=$next_yy"

if [[ $set_state -eq 1 ]]; then
  mkdir -p "$state_dir"
  now=$(date -u +%Y-%m-%dT%H:%M:%SZ)
  {
    echo "id=$id"
    echo "yy=$next_yy"
    echo "executed_at=$now"
  } > "$state_path"
  echo "STATE WRITTEN: $state_path"

  if [[ $no_prompt_rename -eq 0 ]]; then
    rt_dir=".codex/prompts"
    if [[ -d "$rt_dir" ]]; then
      from="$rt_dir/${command_name}.md"
      if [[ ! -f "$from" ]]; then
        from=$(ls "$rt_dir/${command_name}-"*.md 2>/dev/null | sort | tail -n1 || true)
      fi
      if [[ -n "$from" && -f "$from" ]]; then
        to="$rt_dir/${command_name}-${next_yy}.md"
        cp -f "$from" "$to"
        # Prepend header if missing
        if ! head -n1 "$to" | grep -q "Last-Executed-Addendum-ID"; then
          tmp="$to.tmp.$$"
          {
            echo "<!-- Last-Executed-Addendum-ID: $id at $now -->"
            cat "$to"
          } > "$tmp"
          mv "$tmp" "$to"
        fi
      fi
    fi
  fi
fi

exit 0

