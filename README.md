# thoughts.fleig.us

Long-form essays on software engineering and AI by Roger Fleig.

Live at: https://fleig.us

## Local development

```bash
# Install pinned local tools (Hugo, pandoc, TinyTeX, devcontainer CLI)
mise install

# Serve locally
mise run serve

# Build and validate generated article assets
mise run validate

# Generate PDFs
mise run pdf
```

## Publishing a new essay

1. Create `content/writing/<slug>/index.md`
2. Run `mise run pdf`
3. Commit markdown + generated PDF
4. Push to main — GitHub Actions deploys automatically
