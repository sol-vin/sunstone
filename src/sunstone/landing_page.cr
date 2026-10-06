require "html"
require "./version"
require "./assets"

module Sunstone
  module LandingPage
    struct ThemeInfo
      getter id : String
      getter name : String
      getter badge : String
      getter badge_color : String
      getter description : String
      getter font_sans : String
      getter font_mono : String
      getter key_features : Array(String)
      getter preview_swatches : Array(String)

      def initialize(
        @id : String,
        @name : String,
        @badge : String,
        @badge_color : String,
        @description : String,
        @font_sans : String,
        @font_mono : String,
        @key_features : Array(String),
        @preview_swatches : Array(String)
      )
      end
    end

    THEMES_INFO = [
      ThemeInfo.new(
        id: "generic",
        name: "Generic Modern",
        badge: "DEFAULT TECH DECK",
        badge_color: "#38bdf8",
        description: "Modern, clean, high-contrast engineering aesthetic. Neutral slate surfaces with vivid cyan accents and pure semantic styling.",
        font_sans: "Inter, system-ui",
        font_mono: "JetBrains Mono, monospace",
        key_features: ["Zero inline styles", "8 modern palettes", "Sleek 10px rounded cards", "Universal engineering fit"],
        preview_swatches: ["#0f172a", "#1e293b", "#38bdf8", "#34d399", "#818cf8"]
      ),
      ThemeInfo.new(
        id: "nordic",
        name: "Nordic Minimalist",
        badge: "SCANDINAVIAN",
        badge_color: "#2dd4bf",
        description: "Subdued cool slate surfaces, arctic cyan and teal highlights, restrained 6px geometry, and high-readability Scandinavian design.",
        font_sans: "Inter, SF Pro Display",
        font_mono: "JetBrains Mono, Consolas",
        key_features: ["Cool dark slate & glacier frost", "6 cool-toned palettes", "Restrained 6px radii", "Calm conference clarity"],
        preview_swatches: ["#090d16", "#111827", "#38bdf8", "#2dd4bf", "#f0f4f8"]
      ),
      ThemeInfo.new(
        id: "brutalist",
        name: "Neo-Brutalist",
        badge: "SWISS BRUTALISM",
        badge_color: "#ffde00",
        description: "High-voltage neo-brutalist aesthetic with 2.5px solid borders, hard 4px offset drop shadows, zero border radii, and fierce contrast.",
        font_sans: "Impactful Grotesk, system-ui",
        font_mono: "Consolas, Courier New",
        key_features: ["Hard 4px offset shadows", "2.5px solid borders", "0px border radius", "Maximum projector punch"],
        preview_swatches: ["#0a0a0a", "#181818", "#ffde00", "#ff5500", "#00ff66"]
      ),
      ThemeInfo.new(
        id: "academic",
        name: "Academic Publication",
        badge: "FORMAL LATEX",
        badge_color: "#1e3a8a",
        description: "LaTeX and Computer Modern-inspired typography with serif headings, scholarly paper tones, delicate hairlines, and formal poise.",
        font_sans: "Computer Modern, Georgia, serif",
        font_mono: "JetBrains Mono, Consolas",
        key_features: ["Serif academic headings", "Delicate hairline borders", "6 scholarly palettes", "Publication-ready tables"],
        preview_swatches: ["#faf9f5", "#ffffff", "#1e3a8a", "#881337", "#065f46"]
      ),
      ThemeInfo.new(
        id: "tokyo-night",
        name: "Tokyo Night",
        badge: "CYBERPUNK IDE",
        badge_color: "#7dcfff",
        description: "Sleek developer IDE and cyberpunk aesthetic with luminous neon borders, dark code editor surfaces, and syntax-aligned accents.",
        font_sans: "Inter, system-ui",
        font_mono: "JetBrains Mono, Menlo",
        key_features: ["Luminous neon borders", "Dark editor background", "6 IDE-inspired palettes", "Developer conference favorite"],
        preview_swatches: ["#1a1b26", "#24283b", "#7dcfff", "#bb9af7", "#f7768e"]
      ),
      ThemeInfo.new(
        id: "sol.vin",
        name: "Sol.vin Retro 90s",
        badge: "RETRO CYBER",
        badge_color: "#ff007f",
        description: "Nostalgic 90s desktop and terminal engineering aesthetic featuring an interactive 3D spinning isometric wireframe cube.",
        font_sans: "System-ui, sans-serif",
        font_mono: "Courier New, monospace",
        key_features: ["Interactive 3D spinning cube", "46 retro palettes", "SVG color matrix filters", "Playful retro character"],
        preview_swatches: ["#faf6ee", "#000000", "#ff007f", "#00f5d4", "#2563eb"]
      )
    ]

    LAYOUTS_INFO = [
      {"intro", "Title & Keynote", "Cover slide with category badges, subtitle, presenter bio, and tag pills."},
      {"chapter", "Section Chapter", "Major section transition with oversized chapter numerals and agenda pillars."},
      {"two-column", "Two-Column Split", "Flexible side-by-side card and code panes with 1:1, 2:1, or 3:2 ratios."},
      {"code-comparison", "Code Critique", "Two-column comparison with side-by-side critique and takeaway banner."},
      {"three-column", "Three-Column Cards", "Tri-pillar architecture, comparisons, or multi-faceted feature breakdowns."},
      {"four-column", "Four-Column Grid", "Compact quadrant or multi-column layout for comprehensive overviews."},
      {"matrix", "Feature Matrix", "Comparison tables with column headers, status markers, and takeaway notes."},
      {"timeline", "Milestone Railway", "Chronological track with connecting rails, milestone dots, and cards."},
      {"architecture", "System Stack", "Tiered architecture diagram with column blocks and CSS flow arrows."},
      {"media", "Visual Media Frame", "Side-by-side figure illustration and bullet takeaway panel."},
      {"profile", "Speaker Bio", "Presenter profile card with avatar, social links, and credentials."},
      {"dual-mode", "Dual-Step Split", "Automatic two-step slide transition presenting problem then solution."},
      {"demo-roadmap", "Live Agenda", "Phased walkthrough agenda with copyable terminal commands."},
      {"quote", "Focused Quote", "Minimalist centered quote slide with large italic typography."},
      {"closing", "Outro & Links", "Closing slide with callout cards, quickstart command, and signature."}
    ]

    def self.generate(output_path : String, themes : Array(String) = Assets.available_themes)
      html = generate_html(themes)
      File.write(output_path, html)
    end

    def self.generate_html(themes : Array(String) = Assets.available_themes) : String
      active_themes = THEMES_INFO.select { |t| themes.includes?(t.id) }
      active_themes = THEMES_INFO if active_themes.empty?
      default_theme = active_themes.first

      String.build do |str|
        str << <<-HTML
        <!DOCTYPE html>
        <html lang="en">
        <head>
          <meta charset="UTF-8">
          <meta name="viewport" content="width=device-width, initial-scale=1.0">
          <title>Sunstone ☀️ — Modular Presentation Engine & Theme Showcase</title>
          <meta name="description" content="Explore Sunstone's production slide presentation themes with live interactive preview, zero inline styles, and theme-scoped palettes.">
          <style>
            :root {
              --bg: #0b0f19;
              --bg-surface: #111827;
              --bg-card: #162032;
              --bg-card-hover: #1e2c45;
              --text-primary: #f8fafc;
              --text-secondary: #cbd5e1;
              --text-muted: #8492a6;
              --accent: #38bdf8;
              --accent-gradient: linear-gradient(135deg, #38bdf8 0%, #818cf8 50%, #c084fc 100%);
              --border: #233149;
              --border-light: rgba(255, 255, 255, 0.1);
              --radius-sm: 6px;
              --radius-md: 12px;
              --radius-lg: 20px;
              --shadow: 0 10px 30px -10px rgba(0, 0, 0, 0.5);
              --shadow-glow: 0 0 35px rgba(56, 189, 248, 0.15);
              --font-sans: 'Inter', system-ui, -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif;
              --font-mono: 'JetBrains Mono', 'Cascadia Code', Consolas, monospace;
            }

            * {
              box-sizing: border-box;
              margin: 0;
              padding: 0;
            }

            body {
              background-color: var(--bg);
              color: var(--text-secondary);
              font-family: var(--font-sans);
              line-height: 1.6;
              -webkit-font-smoothing: antialiased;
              overflow-x: hidden;
            }

            a {
              color: var(--accent);
              text-decoration: none;
              transition: color 0.15s ease;
            }

            a:hover {
              color: #7dd3fc;
            }

            /* Container */
            .container {
              max-width: 1280px;
              margin: 0 auto;
              padding: 0 24px;
            }

            /* Header Nav */
            header.site-header {
              position: sticky;
              top: 0;
              z-index: 100;
              background: rgba(11, 15, 25, 0.85);
              backdrop-filter: blur(16px);
              -webkit-backdrop-filter: blur(16px);
              border-bottom: 1px solid var(--border);
            }

            .nav-inner {
              display: flex;
              align-items: center;
              justify-content: space-between;
              height: 72px;
            }

            .brand {
              display: flex;
              align-items: center;
              gap: 10px;
              font-size: 1.35rem;
              font-weight: 800;
              color: var(--text-primary);
              letter-spacing: -0.02em;
            }

            .brand-sun {
              font-size: 1.5rem;
              filter: drop-shadow(0 0 8px rgba(251, 191, 36, 0.5));
            }

            .brand-badge {
              font-size: 0.68rem;
              font-weight: 700;
              padding: 2px 8px;
              border-radius: 9999px;
              background: rgba(56, 189, 248, 0.15);
              color: var(--accent);
              border: 1px solid rgba(56, 189, 248, 0.3);
              text-transform: uppercase;
              letter-spacing: 0.05em;
            }

            .nav-links {
              display: flex;
              align-items: center;
              gap: 24px;
              font-size: 0.92rem;
              font-weight: 500;
            }

            .nav-links a {
              color: var(--text-secondary);
            }

            .nav-links a:hover {
              color: var(--text-primary);
            }

            .btn {
              display: inline-flex;
              align-items: center;
              gap: 8px;
              padding: 9px 18px;
              border-radius: var(--radius-sm);
              font-weight: 600;
              font-size: 0.9rem;
              cursor: pointer;
              transition: all 0.2s ease;
              border: none;
            }

            .btn-primary {
              background: var(--accent-gradient);
              color: #0b0f19;
              font-weight: 700;
              box-shadow: 0 4px 15px rgba(56, 189, 248, 0.35);
            }

            .btn-primary:hover {
              color: #000;
              box-shadow: 0 6px 22px rgba(56, 189, 248, 0.55);
              transform: translateY(-1px);
            }

            .btn-secondary {
              background: var(--bg-surface);
              color: var(--text-primary);
              border: 1px solid var(--border);
            }

            .btn-secondary:hover {
              background: var(--bg-card);
              border-color: var(--accent);
              color: #ffffff;
            }

            /* Hero Section */
            section.hero {
              padding: 70px 0 40px;
              text-align: center;
              position: relative;
            }

            .hero-badge-pill {
              display: inline-flex;
              align-items: center;
              gap: 8px;
              padding: 6px 16px;
              border-radius: 9999px;
              background: rgba(56, 189, 248, 0.1);
              border: 1px solid rgba(56, 189, 248, 0.3);
              color: var(--accent);
              font-size: 0.82rem;
              font-weight: 600;
              margin-bottom: 24px;
            }

            h1.hero-title {
              font-size: clamp(2.4rem, 5vw, 4rem);
              font-weight: 900;
              letter-spacing: -0.03em;
              line-height: 1.15;
              color: var(--text-primary);
              margin-bottom: 20px;
            }

            .gradient-text {
              background: var(--accent-gradient);
              -webkit-background-clip: text;
              -webkit-text-fill-color: transparent;
            }

            p.hero-subtitle {
              font-size: clamp(1.05rem, 2vw, 1.25rem);
              color: var(--text-secondary);
              max-width: 780px;
              margin: 0 auto 32px;
            }

            .hero-cta {
              display: flex;
              align-items: center;
              justify-content: center;
              gap: 16px;
              flex-wrap: wrap;
              margin-bottom: 40px;
            }

            .hero-badges-row {
              display: flex;
              justify-content: center;
              gap: 20px;
              flex-wrap: wrap;
              font-size: 0.85rem;
              color: var(--text-muted);
            }

            .hero-badges-row span {
              display: inline-flex;
              align-items: center;
              gap: 6px;
            }

            /* Interactive Preview Stage */
            section.stage-section {
              padding: 20px 0 60px;
            }

            .stage-box {
              background: var(--bg-surface);
              border: 1px solid var(--border);
              border-radius: var(--radius-lg);
              box-shadow: var(--shadow), var(--shadow-glow);
              overflow: hidden;
            }

            .stage-header {
              display: flex;
              align-items: center;
              justify-content: space-between;
              padding: 16px 24px;
              background: rgba(22, 32, 50, 0.7);
              border-bottom: 1px solid var(--border);
              flex-wrap: wrap;
              gap: 16px;
            }

            .stage-tabs {
              display: flex;
              align-items: center;
              gap: 8px;
              overflow-x: auto;
              padding-bottom: 4px;
            }

            .theme-tab {
              display: inline-flex;
              align-items: center;
              gap: 6px;
              padding: 7px 14px;
              border-radius: 9999px;
              background: rgba(255, 255, 255, 0.05);
              border: 1px solid var(--border);
              color: var(--text-secondary);
              font-size: 0.84rem;
              font-weight: 600;
              cursor: pointer;
              transition: all 0.15s ease;
              white-space: nowrap;
            }

            .theme-tab:hover {
              color: var(--text-primary);
              background: rgba(255, 255, 255, 0.1);
              border-color: rgba(255, 255, 255, 0.2);
            }

            .theme-tab.active {
              background: var(--accent);
              color: #0b0f19;
              font-weight: 700;
              border-color: var(--accent);
              box-shadow: 0 2px 10px rgba(56, 189, 248, 0.4);
            }

            .stage-actions {
              display: flex;
              align-items: center;
              gap: 12px;
            }

            .stage-meta {
              font-size: 0.85rem;
              color: var(--text-muted);
            }

            /* Responsive 16:9 Iframe Wrapper */
            .iframe-wrapper {
              position: relative;
              width: 100%;
              padding-top: 56.25%; /* 16:9 aspect ratio */
              background: #000;
            }

            .iframe-wrapper iframe {
              position: absolute;
              top: 0;
              left: 0;
              width: 100%;
              height: 100%;
              border: none;
            }

            .stage-footer {
              display: flex;
              align-items: center;
              justify-content: space-between;
              padding: 14px 24px;
              background: rgba(17, 24, 39, 0.9);
              border-top: 1px solid var(--border);
              font-size: 0.86rem;
              color: var(--text-muted);
              flex-wrap: wrap;
              gap: 12px;
            }

            .key-hints {
              display: flex;
              gap: 14px;
              align-items: center;
            }

            kbd {
              display: inline-block;
              padding: 2px 6px;
              font-family: var(--font-mono);
              font-size: 0.76rem;
              background: var(--bg-card);
              border: 1px solid var(--border);
              border-radius: 4px;
              color: var(--text-secondary);
            }

            /* Section Titles */
            .section-header {
              text-align: center;
              max-width: 680px;
              margin: 0 auto 48px;
            }

            .section-tag {
              font-size: 0.78rem;
              font-weight: 700;
              text-transform: uppercase;
              letter-spacing: 0.08em;
              color: var(--accent);
              margin-bottom: 8px;
            }

            h2.section-title {
              font-size: clamp(1.8rem, 3.5vw, 2.6rem);
              font-weight: 800;
              letter-spacing: -0.02em;
              color: var(--text-primary);
              margin-bottom: 12px;
            }

            p.section-desc {
              font-size: 1.05rem;
              color: var(--text-secondary);
            }

            /* Themes Grid */
            section.themes-grid-section {
              padding: 60px 0;
              border-top: 1px solid var(--border);
            }

            .themes-grid {
              display: grid;
              grid-template-columns: repeat(auto-fit, minmax(360px, 1fr));
              gap: 28px;
            }

            .theme-card {
              background: var(--bg-surface);
              border: 1px solid var(--border);
              border-radius: var(--radius-md);
              padding: 28px;
              display: flex;
              flex-direction: column;
              justify-content: space-between;
              transition: all 0.25s ease;
              position: relative;
            }

            .theme-card:hover {
              border-color: var(--card-accent, var(--accent));
              transform: translateY(-4px);
              box-shadow: 0 14px 30px -10px rgba(0, 0, 0, 0.6);
            }

            .theme-card-top {
              margin-bottom: 20px;
            }

            .theme-card-badge {
              display: inline-block;
              font-size: 0.72rem;
              font-weight: 700;
              text-transform: uppercase;
              letter-spacing: 0.06em;
              padding: 3px 10px;
              border-radius: 9999px;
              margin-bottom: 12px;
              background: rgba(255, 255, 255, 0.08);
              color: var(--card-accent, var(--accent));
              border: 1px solid var(--border);
            }

            .theme-card-title {
              font-size: 1.4rem;
              font-weight: 800;
              color: var(--text-primary);
              margin-bottom: 10px;
            }

            .theme-card-desc {
              font-size: 0.92rem;
              color: var(--text-secondary);
              margin-bottom: 18px;
              line-height: 1.55;
            }

            .theme-swatches {
              display: flex;
              align-items: center;
              gap: 8px;
              margin-bottom: 20px;
            }

            .swatch {
              width: 22px;
              height: 22px;
              border-radius: 50%;
              border: 2px solid rgba(255, 255, 255, 0.2);
              box-shadow: 0 2px 6px rgba(0, 0, 0, 0.4);
            }

            .theme-features-list {
              list-style: none;
              margin-bottom: 24px;
            }

            .theme-features-list li {
              font-size: 0.86rem;
              color: var(--text-muted);
              margin-bottom: 6px;
              display: flex;
              align-items: center;
              gap: 8px;
            }

            .theme-features-list li::before {
              content: "✓";
              color: var(--card-accent, var(--accent));
              font-weight: 800;
            }

            .theme-card-actions {
              display: flex;
              align-items: center;
              gap: 10px;
              padding-top: 16px;
              border-top: 1px solid var(--border);
            }

            /* Layouts Showcase Section */
            section.layouts-section {
              padding: 60px 0;
              border-top: 1px solid var(--border);
            }

            .layouts-grid {
              display: grid;
              grid-template-columns: repeat(auto-fill, minmax(260px, 1fr));
              gap: 16px;
            }

            .layout-card {
              background: var(--bg-surface);
              border: 1px solid var(--border);
              border-radius: var(--radius-sm);
              padding: 16px;
              transition: all 0.2s ease;
            }

            .layout-card:hover {
              border-color: var(--accent);
              background: var(--bg-card);
            }

            .layout-name {
              font-family: var(--font-mono);
              font-size: 0.85rem;
              font-weight: 700;
              color: var(--accent);
              margin-bottom: 6px;
            }

            .layout-title {
              font-size: 0.95rem;
              font-weight: 700;
              color: var(--text-primary);
              margin-bottom: 6px;
            }

            .layout-desc {
              font-size: 0.82rem;
              color: var(--text-muted);
              line-height: 1.45;
            }

            /* Quickstart Section */
            section.quickstart-section {
              padding: 60px 0;
              border-top: 1px solid var(--border);
            }

            .code-box {
              background: #060911;
              border: 1px solid var(--border);
              border-radius: var(--radius-md);
              padding: 24px;
              font-family: var(--font-mono);
              font-size: 0.92rem;
              color: #f1f5f9;
              position: relative;
              max-width: 800px;
              margin: 0 auto;
              box-shadow: var(--shadow);
            }

            .code-comment {
              color: #64748b;
            }

            .code-prompt {
              color: var(--accent);
            }

            /* Footer */
            footer.site-footer {
              padding: 50px 0;
              border-top: 1px solid var(--border);
              font-size: 0.88rem;
              color: var(--text-muted);
              text-align: center;
            }

            .footer-links {
              display: flex;
              justify-content: center;
              gap: 24px;
              margin-bottom: 20px;
              flex-wrap: wrap;
            }

            @media (max-width: 768px) {
              .nav-links { display: none; }
              .themes-grid { grid-template-columns: 1fr; }
            }
          </style>
        </head>
        <body>

          <!-- Header -->
          <header class="site-header">
            <div class="container nav-inner">
              <a href="#" class="brand">
                <span class="brand-sun">☀️</span>
                <span>Sunstone</span>
                <span class="brand-badge">v#{Sunstone::VERSION}</span>
              </a>
              <nav class="nav-links">
                <a href="#preview">Interactive Stage</a>
                <a href="#themes">Theme Catalog</a>
                <a href="#layouts">15 Layouts</a>
                <a href="#quickstart">Quickstart</a>
                <a href="https://github.com/sol-vin/sunstone" target="_blank" rel="noopener">GitHub ↗</a>
                <a href="#preview" class="btn btn-primary">Try Live Demo</a>
              </nav>
            </div>
          </header>

          <!-- Hero Section -->
          <section class="hero">
            <div class="container">
              <div class="hero-badge-pill">
                <span>✨ Six Built-in Themes & Custom Theme Scaffolding</span>
              </div>
              <h1 class="hero-title">
                The Presentation Engine for <span class="gradient-text">Engineers</span>.
              </h1>
              <p class="hero-subtitle">
                Author declarative YAML slides, compile zero-inline-style semantic HTML, and deliver stunning Reveal.js presentations with theme-scoped color palettes.
              </p>
              <div class="hero-cta">
                <a href="#preview" class="btn btn-primary">⚡ Explore Theme Switcher</a>
                <a href="#quickstart" class="btn btn-secondary">Terminal Quickstart</a>
              </div>
              <div class="hero-badges-row">
                <span>✓ Pure Semantic Classes & Data Attributes</span>
                <span>✓ 15 Visual Layouts</span>
                <span>✓ Zero Offline Dependencies</span>
                <span>✓ Automated GitHub Pages CI</span>
              </div>
            </div>
          </section>

          <!-- Interactive Live Stage Section -->
          <section id="preview" class="stage-section">
            <div class="container">
              <div class="stage-box">
                <div class="stage-header">
                  <div class="stage-tabs" id="themeTabs">
        HTML

        active_themes.each_with_index do |t, idx|
          is_active = (idx == 0)
          active_cls = is_active ? "theme-tab active" : "theme-tab"
          icon = case t.id
          when "nordic" then "❄️"
          when "brutalist" then "⚡"
          when "academic" then "📜"
          when "tokyo-night" then "🌃"
          when "sol.vin" then "👾"
          else "💎"
          end

          str << %(                    <button class="#{active_cls}" data-theme="#{t.id}" data-badge="#{HTML.escape(t.badge)}" data-desc="#{HTML.escape(t.description)}">#{icon} #{HTML.escape(t.name)}</button>\n)
        end

        str << <<-HTML
                  </div>
                  <div class="stage-actions">
                    <span class="stage-meta" id="stageMeta">Theme: <strong>#{HTML.escape(default_theme.name)}</strong></span>
                    <a id="fullscreenBtn" href="themes/#{default_theme.id}/index.html" target="_blank" rel="noopener" class="btn btn-secondary" title="Open slide presentation in fullscreen">
                      ⛶ Launch Full Deck
                    </a>
                  </div>
                </div>

                <!-- Live Iframe -->
                <div class="iframe-wrapper">
                  <iframe id="slideshowFrame" src="themes/#{default_theme.id}/index.html" title="Sunstone Live Presentation" allowfullscreen></iframe>
                </div>

                <div class="stage-footer">
                  <span id="themeDescriptionText">#{HTML.escape(default_theme.description)}</span>
                  <div class="key-hints">
                    <span>Navigate slides: <kbd>→</kbd> <kbd>←</kbd> <kbd>Space</kbd></span>
                    <span>Overview: <kbd>Esc</kbd></span>
                    <span>Notes: <kbd>S</kbd></span>
                  </div>
                </div>
              </div>
            </div>
          </section>

          <!-- Theme Catalog Grid Section -->
          <section id="themes" class="themes-grid-section">
            <div class="container">
              <div class="section-header">
                <div class="section-tag">Theme Ecosystem</div>
                <h2 class="section-title">Diverse Themes for Every Venue</h2>
                <p class="section-desc">From minimalist Scandinavian clarity to neo-brutalist impact and publication-ready LaTeX.</p>
              </div>

              <div class="themes-grid">
        HTML

        active_themes.each do |t|
          str << <<-CARD
                <div class="theme-card" style="--card-accent: #{t.badge_color};">
                  <div class="theme-card-top">
                    <span class="theme-card-badge">#{HTML.escape(t.badge)}</span>
                    <h3 class="theme-card-title">#{HTML.escape(t.name)}</h3>
                    <p class="theme-card-desc">#{HTML.escape(t.description)}</p>
                    
                    <div class="theme-swatches" title="Signature Palette Swatches">
          CARD

          t.preview_swatches.each do |c|
            str << %(                      <span class="swatch" style="background-color: #{c};"></span>\n)
          end

          str << <<-CARD
                    </div>

                    <ul class="theme-features-list">
          CARD

          t.key_features.each do |f|
            str << %(                      <li>#{HTML.escape(f)}</li>\n)
          end

          str << <<-CARD
                    </ul>
                  </div>

                  <div class="theme-card-actions">
                    <button class="btn btn-primary" onclick="switchTheme('#{t.id}')">Preview Above ↑</button>
                    <a href="themes/#{t.id}/index.html" target="_blank" rel="noopener" class="btn btn-secondary">Launch Deck ↗</a>
                  </div>
                </div>
          CARD
        end

        str << <<-HTML
              </div>
            </div>
          </section>

          <!-- 15 Layouts Matrix Section -->
          <section id="layouts" class="layouts-section">
            <div class="container">
              <div class="section-header">
                <div class="section-tag">Architecture</div>
                <h2 class="section-title">15 Semantic Layouts</h2>
                <p class="section-desc">Tailored layouts crafted for high-retention technical storytelling, code critiques, and system architectures.</p>
              </div>

              <div class="layouts-grid">
        HTML

        LAYOUTS_INFO.each do |layout_id, layout_title, layout_desc|
          str << <<-LAYOUT
                <div class="layout-card">
                  <div class="layout-name">layout: #{layout_id}</div>
                  <div class="layout-title">#{HTML.escape(layout_title)}</div>
                  <div class="layout-desc">#{HTML.escape(layout_desc)}</div>
                </div>
          LAYOUT
        end

        str << <<-HTML
              </div>
            </div>
          </section>

          <!-- Quickstart Section -->
          <section id="quickstart" class="quickstart-section">
            <div class="container">
              <div class="section-header">
                <div class="section-tag">Get Started</div>
                <h2 class="section-title">From YAML to Presentation in Seconds</h2>
                <p class="section-desc">Zero runtime dependencies, reproducible native binaries, and automatic GitHub Actions CI.</p>
              </div>

              <div class="code-box">
                <p class="code-comment"># 1. Install Sunstone or clone repository</p>
                <p><span class="code-prompt">$</span> shards install && bin/sunstone --help</p>
                <br>
                <p class="code-comment"># 2. Scaffold a brand-new presentation</p>
                <p><span class="code-prompt">$</span> bin/sunstone new my-talk --theme nordic</p>
                <br>
                <p class="code-comment"># 3. Live local preview with auto-reload and browser opening</p>
                <p><span class="code-prompt">$</span> bin/sunstone serve</p>
                <br>
                <p class="code-comment"># 4. Compile all themes and landing gallery for production</p>
                <p><span class="code-prompt">$</span> bin/sunstone build --all-themes --out dist</p>
              </div>
            </div>
          </section>

          <!-- Footer -->
          <footer class="site-footer">
            <div class="container">
              <div class="footer-links">
                <a href="https://github.com/sol-vin/sunstone" target="_blank" rel="noopener">GitHub</a>
                <a href="https://github.com/sol-vin/opal" target="_blank" rel="noopener">Opal CLI</a>
                <a href="https://github.com/sol-vin/carbon" target="_blank" rel="noopener">Carbon</a>
                <a href="https://github.com/sol-vin/jasper" target="_blank" rel="noopener">Jasper</a>
                <a href="https://sol.vin" target="_blank" rel="noopener">Sol.vin</a>
              </div>
              <p>☀️ Crafted with pride by the Sol.vin team. Released under the MIT License.</p>
            </div>
          </footer>

          <!-- Interactive Switcher Script -->
          <script>
            function switchTheme(themeId) {
              const frame = document.getElementById('slideshowFrame');
              const fullscreenBtn = document.getElementById('fullscreenBtn');
              const stageMeta = document.getElementById('stageMeta');
              const descText = document.getElementById('themeDescriptionText');
              const tabs = document.querySelectorAll('.theme-tab');

              tabs.forEach(tab => {
                if (tab.getAttribute('data-theme') === themeId) {
                  tab.classList.add('active');
                  const badge = tab.getAttribute('data-badge');
                  const desc = tab.getAttribute('data-desc');
                  stageMeta.innerHTML = 'Theme: <strong>' + tab.textContent.trim() + '</strong> (' + badge + ')';
                  descText.textContent = desc;
                } else {
                  tab.classList.remove('active');
                }
              });

              // Update iframe source and fullscreen link
              frame.src = 'themes/' + themeId + '/index.html';
              fullscreenBtn.href = 'themes/' + themeId + '/index.html';

              // Smoothly scroll up to preview stage if not in viewport
              const stageEl = document.getElementById('preview');
              const rect = stageEl.getBoundingClientRect();
              if (rect.top < -50 || rect.bottom > window.innerHeight + 100) {
                stageEl.scrollIntoView({ behavior: 'smooth', block: 'center' });
              }
            }

            // Bind click handlers to theme tabs
            document.querySelectorAll('.theme-tab').forEach(tab => {
              tab.addEventListener('click', () => {
                switchTheme(tab.getAttribute('data-theme'));
              });
            });
          </script>
        </body>
        </html>
        HTML
      end
    end
  end
end
