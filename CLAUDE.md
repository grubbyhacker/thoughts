# CLAUDE.md — thoughts.fleig.us

Hugo site for long-form essays on software engineering and AI by Roger Fleig.
Live at https://fleig.us. Theme: PaperMod. Deployed via GitHub Actions to GitHub Pages.

## Key commands

```bash
mise install       # Install pinned local tools, including Hugo extended
mise run serve     # Hugo dev server
mise run build     # Build the site
mise run validate  # Build and verify generated article Markdown alternates
make pdf           # Generate PDFs for all essays (requires devcontainer with pandoc/texlive)
```

## Agentic directives for Claude Code

**IMPORTANT**: Claude Code must follow these rules autonomously — do not wait to be asked:

- **Always work on a feature branch.** Never commit or push to `main` directly. Branch protection will reject it anyway — don't waste the attempt.
- **Own the full Git workflow.** Create the branch, stage files, commit, push, and open the PR without prompting the user.
- **Run `make pdf` via the devcontainer CLI** (not bare shell — pandoc/texlive only exist inside the container):
  ```bash
  devcontainer up --workspace-folder /home/roger/src/thoughts
  devcontainer exec --workspace-folder /home/roger/src/thoughts make pdf
  ```
- **Delete branches after merge.** Once a PR is merged, delete both the remote branch (GitHub may do this automatically) and the local branch.

## Content workflow

Essays live in `content/writing/<slug>/index.md`. To publish:
1. Create a feature branch: `git checkout -b feat/<slug>`
2. Create the essay file with frontmatter (see below)
3. Run `make pdf` via the devcontainer CLI (see above)
4. Commit both the markdown and generated PDF
5. Push and open a PR against `main` — CI build check must pass before merging
6. To preview: open a Codespace from the PR on GitHub.com → hugo server auto-starts →
   click the forwarded port 1313 link to browse the PR's version of the site
7. Merge the PR → GitHub Actions deploys automatically
8. Delete the feature branch (local and remote)

## File structure

```
content/
  writing/          # Essays (each in its own directory with index.md)
  license/          # Standalone license page at /license/
  disclaimer/       # Standalone disclaimer page at /disclaimer/
layouts/
  _default/
    single.html     # Custom single-page template (extends PaperMod)
  index.html        # Home page template
static/
  writing/          # Generated PDFs
hugo.toml           # Site config, nav menu, PaperMod params
Makefile            # pdf and serve targets
```

## Frontmatter conventions

### Essays

```yaml
---
title: "Essay Title"
date: YYYY-MM-DD
description: "One-line description for the list page"
pdf: "slug.pdf"        # relative path to PDF in same directory's static mirror
ShowToc: true
TocOpen: true
---
```

### Standalone pages (license, disclaimer)

```yaml
---
title: "Page Title"
date: YYYY-MM-DD
hideMeta: true         # suppresses author/date/reading-time bar
ShowToc: false
---
```

## Layout notes

- `layouts/_default/single.html` is a custom override of PaperMod's single template
- It adds a "Download PDF" link when `pdf:` frontmatter is set
- `hideMeta: true` is checked via `(.Param "hideMeta")` — works for both page params and site params
- Nav menu is defined in `hugo.toml` under `[[menu.main]]` entries (Writing, Disclaimer, License)

## PDF generation

The `make pdf` target strips the YAML frontmatter (everything up to the second `---`) and pipes the markdown body through pandoc with xelatex. Requires the devcontainer environment (pandoc + texlive-xetex + DejaVu fonts).
