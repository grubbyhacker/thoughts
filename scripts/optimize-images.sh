#!/usr/bin/env bash

set -euo pipefail

if ! command -v oxipng >/dev/null 2>&1; then
  echo "error: oxipng is unavailable; run 'mise install' to install the declared tool" >&2
  exit 127
fi

if stat -c '%s' -- . >/dev/null 2>&1; then
  file_size() {
    stat -c '%s' -- "$1"
  }
else
  file_size() {
    stat -f '%z' "$1"
  }
fi

pngs=()
while IFS= read -r -d '' png; do
  pngs+=("$png")
done < <(find content -type f -name '*.png' -print0)

if ((${#pngs[@]} == 0)); then
  echo "No PNG images found under content/."
  exit 0
fi

before=0
sizes_before=()
for png in "${pngs[@]}"; do
  size=$(file_size "$png")
  sizes_before+=("$size")
  before=$((before + size))
done

printf '%s\0' "${pngs[@]}" | xargs -0 -n 1 -P 4 oxipng --quiet --opt max --threads 1 --

changed=0
for index in "${!pngs[@]}"; do
  png=${pngs[index]}
  size_before=${sizes_before[index]}
  size_after=$(file_size "$png")

  if ((size_before != size_after)); then
    printf 'Optimized %s: %d -> %d bytes (saved %d bytes)\n' \
      "$png" "$size_before" "$size_after" "$((size_before - size_after))"
    changed=$((changed + 1))
  fi
done

after=0
for png in "${pngs[@]}"; do
  after=$((after + $(file_size "$png")))
done

printf 'PNG total: %d -> %d bytes (saved %d bytes); changed %d file(s).\n' \
  "$before" "$after" "$((before - after))" "$changed"
