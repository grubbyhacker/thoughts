#!/usr/bin/env bash

# Self-host the two markdown resume artifacts (plain and structured) by
# fetching them fresh from resume-builder's latest release. Uses `gh release
# download` rather than the public release-asset download URL: that URL
# redirects twice and serves everything as application/octet-stream with
# Content-Disposition: attachment (agent fetch tools generally refuse to
# read that), whereas `gh` goes through the GitHub API directly and resolves
# "latest" without a hardcoded URL shape.
#
# The visible page's pills link the .md files directly - they're ordinary
# markdown, same as every essay's "markdown" link, and there's nothing wrong
# with .md for a human or a tool without a strict content-type allowlist.
# .txt twins exist alongside them for the machine-readable index
# (/index.md, /llms.txt) and the copy-a-prompt text, same reasoning as the
# essay .txt twins: GitHub Pages serves .md as text/markdown by extension,
# which some agent fetch tools reject outright.
#
# Nothing here is committed to git: this runs at deploy time so the copy is
# always current as of the last deploy, with no vendored file to go stale.
set -euo pipefail

repo='grubbyhacker/resume-builder'
target_dir='static/resume'
mkdir -p "$target_dir"

gh release download --repo "$repo" --pattern 'resume.md' \
  --output "$target_dir/resume.md" --clobber

gh release download --repo "$repo" --pattern 'resume.structured.md' \
  --output "$target_dir/resume.structured.md" --clobber

cp "$target_dir/resume.md" "$target_dir/resume.txt"
cp "$target_dir/resume.structured.md" "$target_dir/resume.structured.txt"
