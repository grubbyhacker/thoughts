#!/usr/bin/env bash

# Fetch published Substack artifacts and make self-hosted thumbnails.
# Markdown cleanup remains intentionally manual: inspect static/md/ after this
# script runs and remove Substack UI residue before committing.
set -euo pipefail

publication='https://rogerfleig.substack.com'
archive_url="$publication/api/v1/archive?sort=new&limit=50"
thumb_dir='static/thumbs'
markdown_dir='static/md'
slugs=(
  infrastructure-as-code-is-an-agent
  the-work-that-was-never-mine
  stop-calling-coding-agents-eager
  the-case-for-architectural-linting
  the-pipe-was-always-narrow
  wayfinding-not-roadmaps
  the-parallelism-thesis
  the-250000-vanity-metric
  the-narrow-pipe
)

for command in curl jq pandoc magick; do
  if ! command -v "$command" >/dev/null 2>&1; then
    echo "error: $command is unavailable; run 'mise install' first" >&2
    exit 127
  fi
done

mkdir -p "$thumb_dir" "$markdown_dir"
temp_dir=$(mktemp -d)
trap 'rm -rf "$temp_dir"' EXIT

curl --fail --silent --show-error --location "$archive_url" >"$temp_dir/archive.json"

word_count() {
  LC_ALL=C tr -cs '[:alpha:][:digit:]' '\n' <"$1" | awk 'NF { count += 1 } END { print count + 0 }'
}

for slug in "${slugs[@]}"; do
  archive_post="$temp_dir/$slug.archive.json"
  jq --arg slug "$slug" '.[] | select(.slug == $slug)' "$temp_dir/archive.json" >"$archive_post"
  if [[ ! -s "$archive_post" || $(jq -r '.slug // empty' "$archive_post") != "$slug" ]]; then
    echo "error: $slug is missing from the Substack archive" >&2
    exit 1
  fi

  post="$temp_dir/$slug.post.json"
  curl --fail --silent --show-error --location "$publication/api/v1/posts/$slug" >"$post"
  body="$temp_dir/$slug.html"
  jq -r '.body_html // empty' "$post" >"$body"
  if [[ ! -s "$body" ]]; then
    echo "error: $slug has no body_html" >&2
    exit 1
  fi

  converted="$temp_dir/$slug.md"
  pandoc -f html -t gfm --wrap=none "$body" >"$converted"
  expected=$(jq -r '.wordcount' "$archive_post")
  actual=$(word_count "$converted")
  minimum=$((expected * 80 / 100))
  if (( actual < minimum )); then
    echo "error: $slug converted to $actual words; archive reports $expected (below 80%)" >&2
    exit 1
  fi
  printf '%s: %s/%s converted words\n' "$slug" "$actual" "$expected"

  title=$(jq -r '.title' "$archive_post")
  date=$(jq -r '.post_date | split("T")[0]' "$archive_post")
  canonical=$(jq -r '.canonical_url // ("https://rogerfleig.substack.com/p/" + .slug)' "$archive_post")
  {
    printf '%s\n' '---'
    printf 'title: %s\n' "$title"
    printf '%s\n' 'author: Roger Fleig'
    printf 'date: %s\n' "$date"
    printf 'canonical: %s\n' "$canonical"
    printf '%s\n' 'source: Substack'
    printf '%s\n' 'license: http://fleig.us/license/'
    printf '%s\n\n' '---'
    cat "$converted"
  } >"$markdown_dir/$slug.md"

  cover=$(jq -r '.cover_image // empty' "$archive_post")
  if [[ -z "$cover" ]]; then
    cover=$(jq -r '.publishedBylines[0].photo_url // empty' "$archive_post")
  fi
  if [[ -z "$cover" ]]; then
    echo "error: $slug has neither a cover image nor a byline photo" >&2
    exit 1
  fi
  source_image="$temp_dir/$slug.source"
  curl --fail --silent --show-error --location "$cover" >"$source_image"
  # The Vanity Metric is deliberately positioned by hand after inspecting the
  # headshot. All other covers are center-cropped by the batch pipeline.
  if [[ $slug == 'the-250000-vanity-metric' ]]; then
    magick "$source_image" -auto-orient -gravity north -crop '100%x66.67%+0+145' +repage -resize '192x128!' -quality 80 "$thumb_dir/$slug.webp"
  else
    magick "$source_image" -auto-orient -resize '192x128^' -gravity center -extent '192x128' -quality 80 "$thumb_dir/$slug.webp"
  fi
done

# The long-form thumbnails are local derivatives too. Autotrack has its own
# bundle artwork; the two related essays deliberately reuse their companion
# Substack cover rather than importing a remote image at render time.
magick content/writing/autotrack/gameplay.png -auto-orient -resize '192x128^' -gravity center -extent '192x128' -quality 80 "$thumb_dir/autotrack.webp"
cp "$thumb_dir/the-narrow-pipe.webp" "$thumb_dir/narrowpipe.webp"
cp "$thumb_dir/the-work-that-was-never-mine.webp" "$thumb_dir/if-you-give-an-agent-a-token.webp"

magick identify -format '%f %wx%h\n' "$thumb_dir"/*.webp
