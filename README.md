# ☀️ Sunstone

<!-- carbon:badges -->
[![CI](https://github.com/sol-vin/sunstone/actions/workflows/ci.yml/badge.svg)](https://github.com/sol-vin/sunstone/actions/workflows/ci.yml)
[![Crystal](https://img.shields.io/badge/crystal-%3E%3D%201.10.0-black.svg)](https://crystal-lang.org)
[![Version](https://img.shields.io/badge/version-0.1.26-blue.svg)](https://github.com/sol-vin/sunstone/releases)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![Docs](https://img.shields.io/badge/docs-GitHub%20Pages-blue.svg)](https://sol-vin.github.io/sunstone/)
<!-- /carbon:badges -->

> **Modular, generic YAML-driven slide presentation engine with zero-inline-style semantic HTML and theme-scoped palettes.**

Sunstone transforms human-authored YAML slide definitions into high-impact, presentation-ready Reveal.js web presentations with **strictly zero inline styles**. All geometry, aspect ratios, density levels, and visual chrome are governed purely via semantic CSS classes, `data-*` attributes, and CSS pseudo-elements.

---

## ⚡ Core Highlights

- 📦 **Strict Zero-Inline-Styles**: Every HTML element produced is clean and semantic. No `style="..."` attributes on presentation DOM elements — making custom theming, overrides, and responsive design effortless.
- 🎨 **Theme-Scoped Palettes**: 6 built-in themes (`generic`, `sol.vin`, `nordic`, `brutalist`, `academic`, `tokyo-night`) or author custom ones. Each theme provides its own catalog of palettes (8 modern dark/light palettes in `generic`, 102 authentic retro palettes in `sol.vin`, 6 in `academic`, `nordic`, `brutalist`, and `tokyo-night`), switchable on a **per-slide basis** via `palette: <id>` with zero cross-theme pollution.
- 📐 **33 Semantic Layouts**:
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
  - `stats`: Key metrics / KPI dashboard with large numbers, badges, and deltas
  - `feature-grid`: Asymmetrical Bento Grid showcasing primary feature + side cards
  - `process-flow`: Step-by-step pipeline with directional chevron connectors
  - `table`: Classical Booktabs and comparative benchmark data tables
  - `faq`: Two-column Q&A inquiry cards for questions and clarifications
  - `one-left-two-right`: Single full-height column on left, two stacked containers on right
  - `two-left-one-right`: Two vertically stacked containers on left, single full-height column on right
  - `one-top-two-bottom`: Full-width hero container across top, two side-by-side columns below
  - `two-top-one-bottom`: Two side-by-side columns across top, full-width container below
  - `one-left-three-right`: Dominant showcase column on left, three stacked checkpoint cards on right
  - `three-left-one-right`: Three stacked principle cards on left, dominant showcase column on right
  - `vertical-timeline`: Continuous vertical railway track with milestone status dots & cards
  - `roadmap-timeline`: Gantt-style quarterly/phase roadmap with semantic duration bars
  - `calendar-month`: 7-day monthly sprint & release grid with event chips and legend
  - `calendar-schedule`: Multi-day or multi-track conference timetable with time slots
  - `radial-cycle`: Circular flywheel / feedback loop with central hub and orbital nodes
  - `editorial-split`: High-impact magazine layout with giant numeral, pull-quote & offset cards
  - `convergence`: Converging multi-pillar streams meeting at a central synthesis core
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

Sunstone cleanly separates themes from palettes. Themes provide layout geometry, typography, and container structures, while palettes provide per-slide color schemes.

| Theme | Aesthetic | Palettes Included | Special Features |
| :--- | :--- | :--- | :--- |
| **`generic`** (Default) | Modern, clean, high-contrast engineering | 8 modern palettes (`slate_dark`, `clean_light`, `emerald_matrix`, `midnight_indigo`, `nordic_ice`, `cyber_neon`, `sunset_amber`, `crimson_obsidian`) | Zero extraneous elements, pure semantic CSS |
| **`sol.vin`** | Retro terminal & desktop engineering | 46 retro palettes (`spaces_98`, `warm_paper`, `neon_cyber`, `monokai`, `candy`, etc.) | 3D spinning isometric wireframe cube (`cube.js`), SVG chromatic filters |
| **`nordic`** | Scandinavian minimalism | 6 cool palettes (`fjord_deep`, `aurora_night`, `glacier_frost`, `arctic_twilight`, `lichen_moss`, `polar_monochrome`) | Clean lines, cool blues and slate surfaces, high clarity |
| **`brutalist`** | Swiss neo-brutalism | 6 high-contrast palettes (`yellow_hazard`, `paper_ink`, `electric_lime`, `orange_warning`, `cobalt_blueprint`, `hot_magenta`) | 2.5px solid high-contrast borders, hard 4px offset drop shadows, 0px border radii |
| **`academic`** | LaTeX / Computer Modern formal typography | 6 scholarly palettes (`computer_modern`, `cambridge_blue`, `oxford_crimson`, `gothic_dark`, `emerald_manuscript`, `blackboard_latex`) | Serif headings, understated hairlines, formal mathematical presentation |
| **`tokyo-night`** | Cyberpunk dark IDE developer styling | 6 luminous palettes (`tokyo_night`, `tokyo_storm`, `cyber_pulse`, `catppuccin_mocha`, `dracula_vampire`, `monokai_pro`) | Neon luminous accents, dark editor surfaces, syntax-aligned borders |

Discover available layouts, themes, and palettes anytime:

```bash
sunstone list-layouts
sunstone list-themes
sunstone list-palettes --theme nordic
sunstone list-palettes --theme brutalist
```

### Authoring Custom Themes

Create your own organization or conference theme in seconds:

```bash
sunstone new-theme brand --dir themes
```

This scaffolds:
- `themes/brand.css`: Theme stylesheet adhering to Sunstone's Zero-Inline-Styles contract
- `themes/brand_palettes.json`: Companion JSON defining slide-switchable color schemes

Reference your custom theme directly in `deck.yml`:

```yaml
title: "Quarterly Review"
theme: ./themes/brand.css
```

---

## 🛠️ CLI Command Reference

| Command | Description |
| :--- | :--- |
| `sunstone build [options]` | Compile deck into HTML, Markdown, and static assets. Supports `--theme <name>` and `--all-themes` (generates multi-theme gallery & landing page) |
| `sunstone serve [options]` | Build deck and launch local preview server with auto-browser launch. Supports `--theme <name>` override |
| `sunstone validate [options]` | Verify syntax, slide references, layouts, and palettes |
| `sunstone new <name>` | Create a new slide presentation project |
| `sunstone new-theme <name>` | Scaffold a custom theme CSS and companion palettes JSON |
| `sunstone init` | Initialize a Sunstone presentation in the current directory |
| `sunstone add-slide <id>` | Generate a boilerplate slide YAML file |
| `sunstone list-layouts` | Display all 33 supported semantic layouts |
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
