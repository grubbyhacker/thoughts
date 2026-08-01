#!/usr/bin/env bash

# Self-host the two agent-facing resume artifacts (plain and structured
# markdown) by fetching them fresh from resume-builder's latest release.
# Uses `gh release download` rather than the public release-asset download
# URL: that URL redirects twice and serves everything as
# application/octet-stream with Content-Disposition: attachment (agent fetch
# tools generally refuse to read that), whereas `gh` goes through the GitHub
# API directly and resolves "latest" without a hardcoded URL shape.
#
# Nothing here is committed to git: this runs at deploy time so the copy is
# always current as of the last deploy, with no vendored file to go stale.
set -euo pipefail

repo='grubbyhacker/resume-builder'
target_dir='static/resume'
mkdir -p "$target_dir"

gh release download --repo "$repo" --pattern 'resume.md' \
  --output "$target_dir/resume.txt" --clobber

gh release download --repo "$repo" --pattern 'resume.structured.md' \
  --output "$target_dir/resume.structured.txt" --clobber
