# thoughts.fleig.us

Long-form essays on software engineering and AI by Roger Fleig.

Live at: https://fleig.us

## Local development

```bash
# Install pinned local tools (Hugo extended)
mise install

# Serve locally (requires Hugo extended)
mise run serve

# Build and validate generated article Markdown alternates
mise run validate

# Generate PDFs (requires devcontainer with pandoc/texlive)
make pdf
```

## Publishing a new essay

1. Create `content/writing/<slug>/index.md`
2. Run `make pdf` inside the devcontainer
3. Commit markdown + generated PDF
4. Push to main — GitHub Actions deploys automatically
