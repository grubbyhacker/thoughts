# Agent instructions

- Initialize the checked-out PaperMod theme before running Hugo directly: `git submodule update --init --recursive`. Both validation gates fail loudly with this command when the submodule is unavailable.
- Repository tools come through mise. A bare `hugo`, `pandoc`, or `node` missing from `PATH` is expected; use `mise run <task>` or `mise exec -- <tool>`.
- Use `mise run validate` for the fast HTML and Markdown gate; it does not invoke Pandoc or TinyTeX. Use `mise run validate:pdf` to generate PDFs and check PDF assets as well.
- Essay content, essay front matter, and `hugo.toml` belong to Roger. Do not edit them unless the task explicitly calls for it.
- `.generated/static/writing/` and `public/` are generated output, not source; do not commit them.
