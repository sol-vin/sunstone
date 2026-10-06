# ☀️ Sunstone

<!-- carbon:badges -->
[![CI](https://github.com/sol-vin/sunstone/actions/workflows/ci.yml/badge.svg)](https://github.com/sol-vin/sunstone/actions/workflows/ci.yml)
[![Crystal](https://img.shields.io/badge/crystal-%3E%3D%201.10.0-black.svg)](https://crystal-lang.org)
[![Version](https://img.shields.io/badge/version-0.1.3-blue.svg)](https://github.com/sol-vin/sunstone/releases)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![Docs](https://img.shields.io/badge/docs-available-blue.svg)](https://sol-vin.github.io/sunstone/)
<!-- /carbon:badges -->

> **Modular, generic YAML-driven slide presentation engine with zero-inline-style semantic HTML and theme-scoped palettes.**

Sunstone transforms human-authored YAML slide definitions into high-impact, presentation-ready Reveal.js web presentations with **strictly zero inline styles**. All geometry, aspect ratios, density levels, and visual chrome are governed purely via semantic CSS classes, `data-*` attributes, and CSS pseudo-elements.

---

## ⚡ Core Highlights

- 📦 **Strict Zero-Inline-Styles**: Every HTML element produced is clean and semantic. No `style="..."` attributes on presentation DOM elements — making custom theming, overrides, and responsive design effortless.
- 🎨 **Theme-Scoped Palettes**: Choose themes (`generic`, `sol.vin`) or author custom ones. Each theme provides its own catalog of palettes (8 modern dark/light palettes in `generic`, 46 retro palettes in `sol.vin`), switchable on a **per-slide basis** via `palette: <id>`.
- 📐 **15 Semantic Layouts**:
  - `intro`: Hero / Title slide with badges, subtitle, speaker bio, and pillars
  - `chapter`: Section divider with chapter numbers and topic pillars
  - `two-column`: Split code and cards with customizable grid ratios (`1:1`, `3:2`, `2:3`, `1:2`, `2:1`)
  - `code-comparison`: Side-by-side or two-step progressive critique (code first, analysis second)
  - `three-column`: Three-pillar architecture and feature cards
  - `four-column`: Four-card grid for quadrants and pillars
  - `matrix`: 2x2 or tabular feature matrices with summary callouts
  - `timeline`: Horizontal milestone rail with status indicators
  - `architecture`: Multi-tier technology stack with CSS pseudo-element flow arrows (`▼`)
  - `media`: Embedded images, video, and Asciinema terminal playback synchronized to slide focus
  - `profile`: Speaker credentials with statistic chips and bento cards
  - `dual-mode`: Tabbed comparison of workflows or execution modes
  - `demo-roadmap`: Step-by-step interactive CLI and live demo checklists
  - `closing`: Outro with takeaways, links, and quickstart commands
  - `quote`: Typographic quote and testimonial slides
- 🔮 **Opal CLI App**: Fast, type-safe command-line interface with subcommands, validation, and ANSI color formatting.
- 🌐 **Live Preview Server**: Built-in HTTP server with automatic port hunting (`8000`..`8020`) and OS browser launching.
- 📖 **Jasper Documentation**: Complete multi-track documentation book in `docs_src/` compiled into native Crystal doc modules.
- 🚀 **One-Click GitHub Pages CI**: Scaffolded presentations include automated GitHub Actions workflows to build and publish slides upon `git push`.

---

## 🚀 Quick Start

### 1. Installation

Build Sunstone from source using Crystal:

```bash
git clone https://github.com/sol-vin/sunstone.git
cd sunstone
shards install
crystal build src/sunstone.cr -o bin/sunstone --release
```

### 2. Scaffold a Presentation

Create a new presentation project:

```bash
bin/sunstone new my-talk --title "High-Performance Systems" --author "Jane Doe"
cd my-talk
```

This creates:
- `deck.yml`: Presentation manifest and slide sequence
- `slides/`: Starter slides (`01_intro.yml`, `02_features.yml`, `03_closing.yml`)
- `custom.css`: Optional custom styling overrides
- `.github/workflows/deploy.yml`: Ready-to-go GitHub Pages automated CI

### 3. Live Preview

Launch the local development preview server:

```bash
sunstone serve
```

Your default browser will automatically open to `http://localhost:8000/index.html`.

### 4. Build for Production

Compile static presentation assets into `dist/`:

```bash
sunstone build --out dist
```

Outputs:
- `dist/index.html`: Fully rendered presentation
- `dist/SLIDES.md`: Terminal/plain-text speaker reference
- `dist/theme.css`: Consolidated base layout + theme stylesheet
- `dist/vendor/`: Reveal.js, Highlight.js, and Asciinema player assets

---

## 📑 Slide Authoring Example

Slides are authored in clean, human-readable YAML:

```yaml
id: "concurrency"
layout: "two-column"
badge: "CONCURRENCY"
badge_color: "emerald"
palette: "emerald_matrix"
ratio: "3:2"
title: "Non-Blocking Fibers"
subtitle: "Cooperative multitasking scheduled across event loops"
code_title: "fibers.cr"
code_lang: "crystal"
code: |
  channel = Channel(String).new
  spawn do
    channel.send("Hello from fiber!")
  end
  puts channel.receive
cards:
  - title: "Key Principles"
    color: "emerald"
    items:
      - "Lightweight green threads with minimal stack overhead"
      - "Cooperative scheduling via Event Loop integration"
notes: |
  Explain the performance difference between OS threads and fibers.
```

---

## 🎨 Themes & Palettes

Sunstone cleanly separates themes from palettes:

| Theme | Aesthetic | Palettes Included | Special Features |
| :--- | :--- | :--- | :--- |
| **`generic`** (Default) | Modern, clean, high-contrast engineering | 8 modern palettes (`slate_dark`, `clean_light`, `emerald_matrix`, `midnight_indigo`, `nordic_ice`, `cyber_neon`, `sunset_amber`, `crimson_obsidian`) | Zero extraneous elements, pure semantic CSS |
| **`sol.vin`** | Retro terminal & desktop engineering | 46 retro palettes (`spaces_98`, `warm_paper`, `neon_cyber`, `monokai`, `candy`, etc.) | 3D spinning isometric wireframe cube (`cube.js`), SVG chromatic filters |

Discover available layouts and palettes anytime:

```bash
sunstone list-layouts
sunstone list-themes
sunstone list-palettes --theme generic
sunstone list-palettes --theme sol.vin
```

---

## 🛠️ CLI Command Reference

| Command | Description |
| :--- | :--- |
| `sunstone build [options]` | Compile deck into HTML, Markdown, and static assets |
| `sunstone serve [options]` | Build deck and launch local preview server with auto-browser launch |
| `sunstone validate [options]` | Verify syntax, slide references, layouts, and palettes |
| `sunstone new <name>` | Create a new slide presentation project |
| `sunstone init` | Initialize a Sunstone presentation in the current directory |
| `sunstone add-slide <id>` | Generate a boilerplate slide YAML file |
| `sunstone list-layouts` | Display all 15 supported semantic layouts |
| `sunstone list-themes` | Display available presentation themes |
| `sunstone list-palettes` | List available palettes for a given theme |

---

## 📖 Ecosystem Integration

Sunstone is designed to pair seamlessly with the Sol.vin shard ecosystem:

- **[sol-vin/opal](https://github.com/sol-vin/opal)**: Powers the command-line interface, option parsing, and ANSI styling.
- **[sol-vin/carbon](https://github.com/sol-vin/carbon)**: Version management, YAML changelogs, README badges, and repo doctor audits.
- **[sol-vin/jasper](https://github.com/sol-vin/jasper)**: Documentation compiler converting structured guide books into native `crystal docs` modules.

Compile documentation:

```bash
bin/jasper build
crystal docs
```

---

## 📜 License

Licensed under the MIT License. Copyright © 2026 sol-vin.
