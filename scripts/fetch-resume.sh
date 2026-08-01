#!/usr/bin/env bash

# Self-host the two agent-facing resume artifacts (plain and structured
# markdown) by fetching them fresh from resume-builder's latest release.
# GitHub's release-asset download URLs redirect to a different origin and
# serve everything as application/octet-stream with Content-Disposition:
# attachment, which agent fetch tools generally refuse to read - self-hosting
# avoids that redirect and content type entirely.
#
# Nothing here is committed to git: this runs at deploy time so the copy is
# always current as of the last deploy, with no vendored file to go stale.
set -euo pipefail

releases='https://github.com/grubbyhacker/resume-builder/releases/latest/download'
target_dir='static/resume'
mkdir -p "$target_dir"

curl --fail --silent --show-error --location \
  "$releases/resume.md" -o "$target_dir/resume.txt"

curl --fail --silent --show-error --location \
  "$releases/resume.structured.md" -o "$target_dir/resume.structured.txt"
