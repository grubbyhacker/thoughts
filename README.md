# thoughts.fleig.us

Long-form essays on software engineering and AI by Roger Fleig.

Live at: https://fleig.us

## Local development

```bash
# Install pinned local tools (Hugo, pandoc, TinyTeX, devcontainer CLI)
mise install

# Serve locally
mise run serve

# Fast validation: build and verify HTML and Markdown article assets
mise run validate

# Generate PDFs and validate PDF assets
mise run validate:pdf

# Generate PDFs without validation
mise run pdf
```

## Publishing a new essay

1. Create `content/writing/<slug>/index.md`
2. Run `mise run pdf`
3. Commit markdown and source assets only; PDFs are generated under `.generated/` by CI/deploy
4. Push to main — GitHub Actions deploys automatically
