# CARBON CHANGELOG
## [0.1.6] - 2026-10-06
### ✨ Features & Improvements
- ✦ **[THEMES]** add nordic, brutalist, academic, and tokyo-night themes with custom theme authoring and developer pressure points guides ([`6e31826`](https://github.com/sol-vin/sunstone/commit/6e31826))

---
## [0.1.5] - 2026-10-06
### ✨ Features & Improvements
- ✦ **[THEMES]** add nordic, brutalist, academic, and tokyo-night themes with custom theme authoring and developer pressure points guides ([`6e31826`](https://github.com/sol-vin/sunstone/commit/6e31826))

### 🛠️ Chores & Tooling
- • Added interactive multi-theme landing page gallery featuring a live 16:9 interactive slide preview stage, theme switcher tabs, palette swatches, and 15 layout overviews.
- • Added 'sunstone build --all-themes' flag to compile slide presentations for all 6 themes into dist/themes/<name>/ alongside the root landing page.
- • Added sleek in-deck navigation bar (.sunstone-nav-bar) with 1-click theme switching, slide hash preservation, and gallery return link.
- • Added '--theme <name>' option to 'sunstone build' and 'sunstone serve' to override deck.yml theme dynamically.
- • Updated GitHub Actions workflow to build and deploy the complete multi-theme gallery and demo slideshow to GitHub Pages.

---
## [0.1.4] - 2026-10-06
### 🐛 Bug Fixes
- ✓ **[CI]** use latest Crystal and shards build for jasper ([`90db9a8`](https://github.com/sol-vin/sunstone/commit/90db9a8))
- ✓ **[CI]** ensure bin directory exists before crystal build ([`239e8e7`](https://github.com/sol-vin/sunstone/commit/239e8e7))

### 📚 Documentation
- 📖 Added comprehensive Jasper guides for Authoring Custom Themes and Resolving Developer Pressure Points in docs_src/03_theming/.

### 🛠️ Chores & Tooling
- • Added 4 new production themes: nordic (Scandinavian minimalism), brutalist (Swiss neo-brutalism), academic (formal LaTeX/Computer Modern), and tokyo-night (cyberpunk developer IDE).
- • Added 24 theme-scoped palettes across the new themes with high-contrast accessibility and dark/light modes.
- • Added 'sunstone new-theme <name>' command to scaffold starter theme CSS and companion palettes JSON.
- • Supported direct custom theme file loading (e.g. 'theme: ./themes/brand.css') with companion palette resolution.
- • Consolidated dynamic palette CSS rules directly into theme.css, eliminating embedded style tags in HTML.
- • Supported inline slide definitions in deck.yml in addition to modular external files.

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

