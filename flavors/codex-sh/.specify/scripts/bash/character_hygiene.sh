#!/usr/bin/env bash
set -euo pipefail

root="."
fix=0

usage(){ echo "Usage: $0 [-r <root>] [-f]" >&2; }

while getopts ":r:fh" opt; do
  case "$opt" in
    r) root="$OPTARG" ;;
    f) fix=1 ;;
    h) usage; exit 0 ;;
    \?) usage; exit 2 ;;
  esac
done

mapfile -t files < <(find "$root" -type f \( \
  -name "*.md" -o -name "*.txt" -o -name "*.yml" -o -name "*.yaml" -o -name "*.json" -o \
  -name "*.ps1" -o -name "*.psm1" -o -name "*.sh" -o -name "*.py" -o -name "*.js" -o -name "*.ts" \) \
  ! -path "*/.git/*" ! -path "*/node_modules/*" ! -path "*/dist/*" ! -path "*/build/*" )

violations=0

py_fix='import sys,io,re\n\npath=sys.argv[1]\nwith io.open(path, "r", encoding="utf-8", errors="surrogatepass") as f:\n    s=f.read()\norig=s\n# Remove BOM / ZWNBSP\ns=s.replace("\ufeff","")\n# Remove zero-width chars\ns=re.sub("[\u200B\u200C\u200D\u2060]","",s)\n# NBSP -> space\ns=s.replace("\u00A0"," ")\n# Dashes to ASCII hyphen\ns=re.sub("[\u2010-\u2015\u2212]","-",s)\n# Quotes\ns=re.sub("[\u2018\u2019]","'",s)\ns=re.sub("[\u201C\u201D]","\"",s)\n# Ellipsis\ns=s.replace("\u2026","...")\nchanged = (s!=orig)\nif changed:\n    with io.open(path, "w", encoding="utf-8", newline="") as f:\n        f.write(s)\nprint("CHANGED" if changed else "OK")\n'

py_check='import sys,io,re\npath=sys.argv[1]\nwith io.open(path, "r", encoding="utf-8", errors="surrogatepass") as f:\n    s=f.read()\npat=re.compile("[\u00A0\u2000-\u200B\u200C\u200D\u2060\uFEFF\u2010-\u2015\u2212\u2018\u2019\u201C\u201D\u2026]")\nprint("BAD" if pat.search(s) else "OK")\n'

for f in "${files[@]}"; do
  if [[ $fix -eq 1 ]]; then
    out=$(python3 -c "$py_fix" "$f" || true)
    if [[ "$out" == "CHANGED" ]]; then echo "Fixed: $f"; fi
  else
    out=$(python3 -c "$py_check" "$f" || true)
    if [[ "$out" == "BAD" ]]; then echo "Found: $f"; violations=$((violations+1)); fi
  fi
done

if [[ $fix -eq 1 ]]; then
  echo "Character hygiene normalization complete."
else
  if [[ $violations -gt 0 ]]; then
    echo "Character hygiene check failed in $violations file(s). Run with -f to normalize." >&2
    exit 1
  else
    echo "Character hygiene check passed."
  fi
fi

