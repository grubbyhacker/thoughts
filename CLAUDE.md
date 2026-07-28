# Agent instructions

- Initialize the checked-out theme before running Hugo directly: `git submodule update --init --recursive`. `mise run validate` does this itself.
- Repository tools come through mise. A bare `hugo`, `pandoc`, or `node` missing from `PATH` is expected; use `mise run <task>` or `mise exec -- <tool>`.
- Use `mise run validate` to verify changes. It initializes PaperMod, generates PDFs, builds the site, and checks every essay's Markdown and PDF outputs. `mise run build` only builds the site.
- Essay content, essay front matter, and `hugo.toml` belong to Roger. Do not edit them unless the task explicitly calls for it.
- `.generated/static/writing/` and `public/` are generated output, not source; do not commit them.
