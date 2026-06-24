#!/usr/bin/env bash
set -euo pipefail

pdf_static_root="${PDF_STATIC_ROOT:-.generated/static/writing}"

frontmatter_value() {
  local key="$1"
  local file="$2"

  awk -v key="$key" '
    NR == 1 && $0 == "---" {
      in_frontmatter = 1
      next
    }

    in_frontmatter && $0 == "---" {
      exit
    }

    in_frontmatter {
      prefix = key ":[[:space:]]*"
      if ($0 ~ "^" prefix) {
        sub("^" prefix, "")
        if ((substr($0, 1, 1) == "\"" && substr($0, length($0), 1) == "\"") ||
            (substr($0, 1, 1) == "'"'"'" && substr($0, length($0), 1) == "'"'"'")) {
          print substr($0, 2, length($0) - 2)
        } else {
          print
        }
        exit
      }
    }
  ' "$file"
}

yaml_quote() {
  awk -v value="$1" 'BEGIN {
    gsub(/\\/, "\\\\", value)
    gsub(/"/, "\\\"", value)
    printf "\"%s\"", value
  }'
}

format_date() {
  local value="$1"

  if [[ ! "$value" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}$ ]]; then
    printf '%s' "$value"
    return
  fi

  local year="${value:0:4}"
  local month="${value:5:2}"
  local day="${value:8:2}"
  local month_name

  case "$month" in
    01) month_name="January" ;;
    02) month_name="February" ;;
    03) month_name="March" ;;
    04) month_name="April" ;;
    05) month_name="May" ;;
    06) month_name="June" ;;
    07) month_name="July" ;;
    08) month_name="August" ;;
    09) month_name="September" ;;
    10) month_name="October" ;;
    11) month_name="November" ;;
    12) month_name="December" ;;
    *) printf '%s' "$value"; return ;;
  esac

  printf '%s %d, %s' "$month_name" "$((10#$day))" "$year"
}

write_body_without_frontmatter() {
  local file="$1"

  awk '
    NR == 1 && $0 == "---" {
      in_frontmatter = 1
      next
    }

    in_frontmatter && $0 == "---" {
      in_frontmatter = 0
      in_body = 1
      next
    }

    in_body {
      if (!started && $0 ~ /^[[:space:]]*$/) {
        next
      }
      started = 1
      print
    }
  ' "$file"
}

for dir in content/writing/*/; do
  article="${dir}index.md"
  slug="$(basename "$dir")"
  title="$(frontmatter_value title "$article")"
  subtitle="$(frontmatter_value subtitle "$article")"
  author="$(frontmatter_value author "$article")"
  date="$(frontmatter_value date "$article")"
  pdf="$(frontmatter_value pdf "$article")"

  if [[ -z "$title" ]]; then
    echo "Missing title in $article" >&2
    exit 1
  fi

  if [[ -z "$author" ]]; then
    author="Roger Fleig"
  fi

  if [[ -z "$pdf" ]]; then
    pdf="${slug}.pdf"
  fi

  mkdir -p "$pdf_static_root/$slug"
  tmpdir="$(mktemp -d)"
  trap 'rm -rf "$tmpdir"' EXIT
  tmpfile="$tmpdir/article.md"

  {
    printf '%s\n' "---"
    printf 'title: %s\n' "$(yaml_quote "$title")"
    if [[ -n "$subtitle" ]]; then
      printf 'subtitle: %s\n' "$(yaml_quote "$subtitle")"
    fi
    printf 'author: %s\n' "$(yaml_quote "$author")"
    if [[ -n "$date" ]]; then
      printf 'date: %s\n' "$(yaml_quote "$(format_date "$date")")"
    fi
    printf '%s\n\n' "---"
    write_body_without_frontmatter "$article"
  } > "$tmpfile"

  pandoc \
    --standalone \
    --from markdown \
    --to pdf \
    --pdf-engine=xelatex \
    --resource-path="${dir}:." \
    --variable mainfont="texgyretermes-regular.otf" \
    -o "$pdf_static_root/$slug/$pdf" \
    "$tmpfile"

  rm -rf "$tmpdir"
  trap - EXIT

  echo "Generated $pdf_static_root/$slug/$pdf"
done
