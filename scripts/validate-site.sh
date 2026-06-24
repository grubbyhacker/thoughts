#!/usr/bin/env bash
set -euo pipefail

hugo --minify --noBuildLock

for article in content/writing/*/index.md; do
  slug="$(basename "$(dirname "$article")")"
  public_dir="public/writing/$slug"

  test -f "$public_dir/index.md"
  cmp "$article" "$public_dir/index.md"
  grep -Fq "<link rel=alternate type=text/markdown href=/writing/$slug/index.md>" "$public_dir/index.html"

  pdf="$(
    awk '
      NR == 1 && $0 == "---" { in_frontmatter = 1; next }
      in_frontmatter && $0 == "---" { exit }
      in_frontmatter && /^pdf:[[:space:]]*/ {
        sub(/^pdf:[[:space:]]*/, "")
        gsub(/^"|"$/, "")
        print
        exit
      }
    ' "$article"
  )"

  if [[ -n "$pdf" ]]; then
    test -f "static/writing/$slug/$pdf"
    test -f "$public_dir/$pdf"
    grep -Fq "href=/writing/$slug/$pdf" "$public_dir/index.html"
  fi
done
