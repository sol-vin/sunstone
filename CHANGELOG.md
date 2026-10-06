# CARBON CHANGELOG
## [0.1.4] - 2026-10-06
### 🐛 Bug Fixes
- ✓ **[CI]** use latest Crystal and shards build for jasper ([`90db9a8`](https://github.com/sol-vin/sunstone/commit/90db9a8))
- ✓ **[CI]** ensure bin directory exists before crystal build ([`239e8e7`](https://github.com/sol-vin/sunstone/commit/239e8e7))

---
## [0.1.3] - 2026-10-06
### 🐛 Bug Fixes
- ✓ **[CI]** use latest Crystal and shards build for jasper ([`90db9a8`](https://github.com/sol-vin/sunstone/commit/90db9a8))

---
## [0.1.2] - 2026-10-06
---
## [0.1.1] - 2026-10-06
---
## [0.1.0] - 2026-10-06
> Initial release of Sunstone — Generic YAML-driven slide presentation engine with zero-inline-style semantic HTML.
### 📚 Documentation
- 📖 Comprehensive showcase deck in examples/showcase demonstrating all 15 layouts and palettes.

### 🛠️ Chores & Tooling
- • Strict Zero-Inline-Styles architecture using semantic classes and data-* attributes (data-layout, data-ratio, data-density, data-palette, data-cols).
- • 15 semantic layouts: intro, chapter, two-column, code-comparison (2-step critique), three-column, four-column, matrix, timeline, architecture, media, profile, dual-mode, demo-roadmap, closing, quote.
- • Theme-scoped palettes supporting per-slide palette switching: generic (8 modern palettes) and sol.vin (46 retro palettes).
- • Terminal window chrome and architectural flow arrows rendered purely via CSS pseudo-elements (::before, ::after).
- • Opal CLI application with build, serve, validate, new, init, add-slide, and discovery commands.
- • Live HTTP static preview server with port hunting (8000..8020) and automatic OS browser launching.
- • Jasper structured multi-track documentation books in docs_src/ integrated with crystal docs.
- • Carbon changelog, release management, README badges, and repo doctor audit integration.
- • Scaffolded user presentation CI workflow (.github/workflows/deploy.yml) for one-click GitHub Pages deployment.

