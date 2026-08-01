#!/usr/bin/env bash
set -euo pipefail

pdf_validation=false

case "${1:-}" in
  "") ;;
  --pdf) pdf_validation=true ;;
  *)
    echo "Usage: $0 [--pdf]" >&2
    exit 2
    ;;
esac

if [[ ! -f themes/PaperMod/theme.toml ]]; then
  echo "PaperMod theme submodule is not initialized; run: git submodule update --init --recursive" >&2
  exit 1
fi

if "$pdf_validation"; then
  make pdf
fi

hugo --minify --noBuildLock

test -f public/about/index.html
grep -Fq 'url=http://fleig.us/' public/about/index.html

test -f public/index.md
test -f public/llms.txt
cmp public/index.md public/llms.txt

resume_artifacts=(
  'resume.pdf'
  'resume.docx'
  'resume.md'
  'resume.structured.md'
)

for artifact in "${resume_artifacts[@]}"; do
  grep -Fq "$artifact" public/index.md
done

while IFS= read -r markdown; do
  [[ -n "$markdown" ]] || continue
  test -f "public$markdown"
  grep -Fq "$markdown" public/index.md
done < <(sed -nE 's/^[[:space:]]*markdown:[[:space:]]*//p' data/anthology.yaml)

# Font Awesome attribution comments remain in the HTML, but the rendered site
# must not load assets from a third-party origin.
if rg -uuu -q --glob '*.html' '<(link|script|img)[^>]+(fontawesome\.com|cdnjs|fonts\.googleapis\.com|substackcdn\.com)' public; then
  echo "Built HTML loads a third-party asset" >&2
  exit 1
fi

post_action_icons="$(rg -uuu -o --no-filename --glob '*.html' '<svg[^>]*post-action-icon[^>]*>' public || true)"
if [[ -z "$post_action_icons" ]]; then
  echo "No inlined action icons found in built HTML" >&2
  exit 1
fi
while IFS= read -r icon; do
  [[ "$icon" == *'fill=currentColor'* || "$icon" == *'fill="currentColor"'* ]] || { echo "Inlined icon does not use currentColor" >&2; exit 1; }
  [[ "$icon" == *'height='* ]] && [[ "$icon" == *'width=auto'* || "$icon" == *'width="auto"'* ]] || { echo "Inlined icon is not sized by height with automatic width" >&2; exit 1; }
done <<< "$post_action_icons"

anthology_images="$(grep -oE '<img [^>]*>' public/index.html || true)"
if [[ -z "$anthology_images" ]]; then
  echo "No anthology images found in built HTML" >&2
  exit 1
fi
while IFS= read -r image; do
  [[ "$image" =~ (^|[[:space:]])width= ]] || { echo "Anthology image has no width" >&2; exit 1; }
  [[ "$image" =~ (^|[[:space:]])height= ]] || { echo "Anthology image has no height" >&2; exit 1; }
  [[ "$image" =~ (^|[[:space:]])alt([=[:space:]>]) ]] || { echo "Anthology image has no alt" >&2; exit 1; }
done <<< "$anthology_images"

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

  if "$pdf_validation" && [[ -n "$pdf" ]]; then
    test -f ".generated/static/writing/$slug/$pdf"
    test -f "$public_dir/$pdf"
    grep -Fq "href=/writing/$slug/$pdf" "$public_dir/index.html"
  fi
done
