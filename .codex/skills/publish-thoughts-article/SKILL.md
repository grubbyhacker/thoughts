---
name: publish-thoughts-article
description: Prepare and publish raw Markdown essays in this thoughts.fleig.us Hugo repo. Use when the user provides or references a draft article, raw Markdown essay, new writing piece, or asks to add/publish/update an essay under content/writing, including generating the PDF artifact and verifying the web/PDF/agent-readable Markdown outputs.
---

# Publish Thoughts Article

Use this skill to turn raw essay Markdown into a complete Hugo article for this repo.

## Article Shape

Create each essay at `content/writing/<slug>/index.md`. Choose a lowercase hyphenated slug from the title unless the user specifies one.

Use this frontmatter pattern:

```yaml
---
title: "Essay Title"
subtitle: "Optional subtitle"
date: YYYY-MM-DD
author: Roger Fleig
description: "One-sentence list/search description."
summary: "One-sentence feed/social summary."
tags: ["AI", "software engineering"]
pdf: "<slug>.pdf"
ShowToc: true
TocOpen: true
---
```

Prefer the current local date unless the draft or user gives a publication date. Do not silently use a future date.

Use this body opening so the PDF has visible attribution after frontmatter is stripped:

```markdown
# Essay Title

*Optional subtitle*

Month YYYY

**Author:** Roger Fleig

---
```

If the raw Markdown already has a title/subtitle/date/author block, adapt it to this shape instead of duplicating it. Keep the author/date visible in the body even though they also exist in frontmatter.

## Conversion Workflow

1. Read nearby published articles for tone and structure, especially `content/writing/narrowpipe/index.md` and `content/writing/autotrack/index.md`.
2. Create or update `content/writing/<slug>/index.md`.
3. Add any article images beside `index.md` and reference them with relative paths.
4. Run `mise install` if required tools are missing.
5. Run `mise run pdf` and commit `static/writing/<slug>/<slug>.pdf` with the article.
6. Run `mise run validate`.
7. For preview requests, run `mise run serve` or `hugo server` and verify:
   - The article page renders.
   - The "Download PDF" link points to `/writing/<slug>/<slug>.pdf`.
   - The PDF URL returns `200 OK` with `Content-Type: application/pdf`.
   - The "Agent-readable Markdown" link points to `/writing/<slug>/index.md`.

## Quality Checks

Before finishing, check:

- Frontmatter has `title`, `date`, `author`, `description` or `summary`, `pdf`, `ShowToc`, and `TocOpen`.
- The body has a visible title, date, and `**Author:** Roger Fleig` for PDF output.
- The generated PDF exists under `static/writing/<slug>/`.
- `mise run validate` passes.
- Existing unrelated article PDFs were not changed by a no-op regeneration; restore them if their source article did not change.
- The PR or commit includes both the article Markdown and generated PDF.
