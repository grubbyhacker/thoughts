# CLAUDE.md — thoughts.fleig.us

Hugo site for long-form essays on software engineering and AI by Roger Fleig.
Live at https://fleig.us. Theme: PaperMod. Deployed via GitHub Actions to GitHub Pages.

## Key commands

```bash
make serve   # Hugo dev server (requires Hugo extended)
make pdf     # Generate PDFs for all essays (requires devcontainer with pandoc/texlive)
```

## Content workflow

Essays live in `content/writing/<slug>/index.md`. To publish:
1. Create the essay file with frontmatter (see below)
2. Run `make pdf` inside the devcontainer — outputs to `static/writing/<slug>/<slug>.pdf`
3. Commit both the markdown and generated PDF
4. Push to `main` — GitHub Actions deploys automatically

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
