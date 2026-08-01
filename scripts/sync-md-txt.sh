#!/usr/bin/env bash

# Refresh the .txt twins of static/md/*.md. GitHub Pages serves .md files as
# text/markdown by file extension, which some agent fetch tools reject; the
# .txt twin is the same content served as text/plain instead. Re-run this
# after hand-cleaning a static/md/<slug>.md file so the twin stays in sync -
# it does not touch the network, so it's safe to run any time.
set -euo pipefail

for markdown in static/md/*.md; do
  cp "$markdown" "${markdown%.md}.txt"
done
