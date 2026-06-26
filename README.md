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

CI and deploy use the prebuilt `ghcr.io/grubbyhacker/thoughts-build:ci`
toolchain image, which contains the pinned Hugo/Pandoc versions, XeLaTeX,
and PDF fonts.
If the image is missing or the toolchain definition changes, workflows build it
locally as a fallback.

## Publishing a new essay

1. Create `content/writing/<slug>/index.md`
2. Run `mise run pdf`
3. Commit markdown and source assets only; PDFs are generated under `.generated/` by CI/deploy
4. Push to main — GitHub Actions deploys automatically
