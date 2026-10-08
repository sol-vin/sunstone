require "file_utils"
require "./assets"
require "./layouts/router"

module Sunstone
  module Scaffold
    def self.new_project(directory : String, theme : String = "generic", title : String? = nil, author : String? = nil)
      Dir.mkdir_p(directory)
      slides_dir = File.join(directory, "slides")
      Dir.mkdir_p(slides_dir)

      deck_title = title || File.basename(File.expand_path(directory)).capitalize
      deck_author = author || "Presenter"

      # 1. deck.yml
      deck_yml = <<-YAML
      title: "#{deck_title}"
      subtitle: "High-Impact Slides Driven by YAML & CSS"
      author: "#{deck_author}"
      theme: "#{theme}"
      width: 1920
      height: 1080

      footer_left: "☀️ {title}"
      footer_center: "{author}"
      footer_right: "{slide_num} / {total_slides}"

      slides:
        - slides/01_intro.yml
        - slides/02_features.yml
        - slides/03_closing.yml
      YAML

      File.write(File.join(directory, "deck.yml"), deck_yml)

      # 2. Starter slides
      slide_01 = <<-YAML
      id: "intro"
      layout: "intro"
      badge: "SUNSTONE"
      badge_color: "accent"
      palette: "#{theme == "sol.vin" ? "spaces_98" : "slate_dark"}"
      title: "#{deck_title}"
      subtitle: "A clean, modern, zero-inline-style presentation engine"
      author: "#{deck_author}"
      role: "Lead Architect"
      pillars:
        - "⚡ YAML-Driven"
        - "🎨 CSS-Powered"
        - "📦 Zero Inline Styles"
      notes: |
        Welcome to your Sunstone presentation!
        Press Space or Right Arrow to advance through slides.
        Press S to open the speaker view.
      YAML
      File.write(File.join(slides_dir, "01_intro.yml"), slide_01)

      slide_02 = <<-YAML
      id: "features"
      layout: "two-column"
      badge: "ARCHITECTURE"
      badge_color: "emerald"
      palette: "#{theme == "sol.vin" ? "warm_paper" : "emerald_matrix"}"
      ratio: "1:1"
      title: "Clean Semantic Output"
      subtitle: "Structure lives in YAML, layout in CSS, styling in themes"
      code_title: "deck.yml"
      code_lang: "yaml"
      code: |
        title: "Microservices v3"
        theme: "generic"
        slides:
          - slides/intro.yml
          - slides/architecture.yml
      cards:
        - title: "Pure Separation of Concerns"
          color: "emerald"
          items:
            - "No style='...' attributes generated anywhere"
            - "Geometry and ratios configured via data attributes"
            - "CSS pseudo-elements provide chrome & decorations"
        - title: "Developer First"
          color: "accent"
          items:
            - "Git-friendly line-by-line slide diffs"
            - "Live preview server with instant reloading"
            - "Automated GitHub Pages deployment"
      notes: |
        Explain how Sunstone completely eliminates messy HTML blobs from slide generation.
      YAML
      File.write(File.join(slides_dir, "02_features.yml"), slide_02)

      slide_03 = <<-YAML
      id: "closing"
      layout: "closing"
      badge: "THANK YOU"
      badge_color: "accent"
      palette: "#{theme == "sol.vin" ? "neon_cyber" : "indigo_night"}"
      title: "Build Your Next Presentation"
      subtitle: "Fast, reproducible, and beautifully styled"
      author: "#{deck_author}"
      quote: "The best slide deck is the one you can review in a pull request."
      links:
        - label: "GitHub"
          url: "https://github.com/sol-vin/sunstone"
        - label: "Documentation"
          url: "https://sol-vin.github.io/sunstone"
      notes: |
        Wrap up the talk and take questions from the audience.
      YAML
      File.write(File.join(slides_dir, "03_closing.yml"), slide_03)

      # 3. custom.css
      custom_css = <<-CSS
      /* Sunstone Custom Deck Overrides */
      /* You can customize fonts, borders, cards, and animations here. */

      /* Example: Custom slide title font or drop shadow */
      /*
      .slide-title {
        letter-spacing: -0.02em;
      }
      */
      CSS
      File.write(File.join(directory, "custom.css"), custom_css)

      # 4. GitHub Actions user CI deployment workflow
      workflows_dir = File.join(directory, ".github", "workflows")
      Dir.mkdir_p(workflows_dir)
      File.write(File.join(workflows_dir, "deploy.yml"), Assets::USER_CI_YML)

      # 5. .gitignore
      gitignore = <<-IGNORE
      dist/
      .DS_Store
      IGNORE
      File.write(File.join(directory, ".gitignore"), gitignore)

      # 6. README.md
      readme = <<-MD
      # #{deck_title}

      A high-impact slide presentation built with [Sunstone](https://github.com/sol-vin/sunstone).

      ## Quick Start

      ### 1. Preview Slides Locally
      ```bash
      sunstone serve
      ```
      This builds your presentation to `dist/` and launches a local web server at `http://localhost:8000`.

      ### 2. Build for Production / Static Hosting
      ```bash
      sunstone build
      ```
      Generated files are emitted to `dist/index.html` and `dist/SLIDES.md`.

      ### 3. Deploy to GitHub Pages
      Push your repository to GitHub and enable GitHub Pages under **Settings > Pages > GitHub Actions**.
      The included workflow (`.github/workflows/deploy.yml`) will automatically build and publish your slides on every push to `main`!
      MD
      File.write(File.join(directory, "README.md"), readme)
    end

    def self.add_slide(id : String, layout : String = "two-column", title : String? = nil, target_dir : String = "slides")
      Dir.mkdir_p(target_dir)
      file_path = File.join(target_dir, "#{id}.yml")

      slide_title = title || id.split(/[-_]/).map(&.capitalize).join(" ")
      content = case layout.downcase.gsub("_", "-")
      when "intro", "hero", "title"
        <<-YAML
        id: "#{id}"
        layout: "intro"
        badge: "INTRO"
        badge_color: "accent"
        palette: "slate_dark"
        title: "#{slide_title}"
        subtitle: "Subtitle goes here"
        author: "Presenter"
        role: "Title"
        pillars:
          - "Point 1"
          - "Point 2"
          - "Point 3"
        notes: |
          Presenter notes for #{slide_title}.
        YAML
      when "chapter", "divider", "section"
        <<-YAML
        id: "#{id}"
        layout: "chapter"
        badge: "CHAPTER"
        badge_color: "accent"
        palette: "slate_dark"
        chapter_number: "01"
        title: "#{slide_title}"
        subtitle: "A deeper exploration"
        pillars:
          - "Overview"
          - "Deep Dive"
          - "Summary"
        notes: |
          Presenter notes for chapter transition.
        YAML
      when "three-column", "three_col"
        <<-YAML
        id: "#{id}"
        layout: "three-column"
        badge: "COMPARISON"
        badge_color: "accent"
        palette: "slate_dark"
        title: "#{slide_title}"
        subtitle: "Analyzing three distinct facets"
        cards:
          - title: "Phase 1"
            color: "accent"
            items:
              - "Discovery"
              - "Planning"
          - title: "Phase 2"
            color: "emerald"
            items:
              - "Implementation"
              - "Testing"
          - title: "Phase 3"
            color: "amber"
            items:
              - "Deployment"
              - "Monitoring"
        notes: |
          Speaker notes.
        YAML
      when "quote"
        <<-YAML
        id: "#{id}"
        layout: "quote"
        badge: "QUOTE"
        badge_color: "accent"
        palette: "slate_dark"
        title: "#{slide_title}"
        quote: "Simplicity is prerequisite for reliability."
        author: "Edsger W. Dijkstra"
        role: "Computer Scientist"
        notes: |
          Speaker notes.
        YAML
      when "stats", "kpi", "numbers", "dashboard"
        <<-YAML
        id: "#{id}"
        layout: "stats"
        badge: "METRICS"
        badge_color: "accent"
        palette: "slate_dark"
        title: "#{slide_title}"
        subtitle: "Key Performance Indicators"
        metrics:
          - value: "10x"
            label: "Throughput"
            delta: "+950%"
            color: "accent"
            desc: "Native AOT execution speed"
          - value: "0ms"
            label: "GC Pause"
            delta: "DETERMINISTIC"
            color: "emerald"
            desc: "Zero stop-the-world latency"
          - value: "100%"
            label: "Type Safety"
            delta: "VERIFIED"
            color: "amber"
            desc: "Compile-time nil safety guarantees"
        notes: |
          Key metrics overview.
        YAML
      when "feature-grid", "bento"
        <<-YAML
        id: "#{id}"
        layout: "feature-grid"
        badge: "ARCHITECTURE"
        badge_color: "accent"
        palette: "slate_dark"
        title: "#{slide_title}"
        subtitle: "Asymmetrical Feature Showcase"
        hero_feature:
          title: "Core Engine"
          badge: "PRIMARY"
          color: "accent"
          desc: "Main architectural component breakdown"
        features:
          - title: "Feature Alpha"
            badge: "MODULE A"
            color: "emerald"
            items:
              - "High-throughput processing"
              - "Sub-millisecond response"
          - title: "Feature Beta"
            badge: "MODULE B"
            color: "amber"
            items:
              - "Zero-allocation pathways"
              - "Cross-platform portability"
        notes: |
          Feature grid walkthrough.
        YAML
      when "process-flow", "pipeline", "workflow"
        <<-YAML
        id: "#{id}"
        layout: "process-flow"
        badge: "PIPELINE"
        badge_color: "accent"
        palette: "slate_dark"
        title: "#{slide_title}"
        subtitle: "Sequential Workflow Steps"
        steps:
          - step: "01"
            title: "Ingest"
            badge: "INPUT"
            color: "accent"
            desc: "Receive and validate raw events"
          - step: "02"
            title: "Transform"
            badge: "PROCESS"
            color: "emerald"
            desc: "Normalize and enrich payload"
          - step: "03"
            title: "Emit"
            badge: "OUTPUT"
            color: "amber"
            desc: "Deliver to subscribers with ack"
        notes: |
          Step-by-step pipeline discussion.
        YAML
      when "table", "benchmark"
        <<-YAML
        id: "#{id}"
        layout: "table"
        badge: "BENCHMARK"
        badge_color: "accent"
        palette: "slate_dark"
        title: "#{slide_title}"
        subtitle: "Comparative Benchmark Matrix"
        headers: ["System", "Language", "Latency", "Memory"]
        rows:
          - ["Engine A", "Crystal", "1.2 ms", "14 MB"]
          - ["Engine B", "Rust", "1.1 ms", "12 MB"]
          - ["Engine C", "Go", "2.8 ms", "28 MB"]
        highlight_row: 0
        footnote: "Tests conducted on standard 4-core container."
        notes: |
          Comparative benchmark matrix.
        YAML
      when "faq", "q-and-a"
        <<-YAML
        id: "#{id}"
        layout: "faq"
        badge: "FAQ"
        badge_color: "accent"
        palette: "slate_dark"
        title: "#{slide_title}"
        subtitle: "Frequently Addressed Questions"
        questions:
          - q: "What is the primary architectural differentiator?"
            a: "Zero runtime dependencies paired with strict semantic zero-inline-style HTML."
            color: "accent"
          - q: "How is styling isolated across decks?"
            a: "Scoped CSS variables bound dynamically per slide section."
            color: "emerald"
        notes: |
          Q&A discussion.
        YAML
      when "one-left-two-right", "1l-2r"
        <<-YAML
        id: "#{id}"
        layout: "one-left-two-right"
        badge: "ASYMMETRIC SPLIT"
        badge_color: "accent"
        palette: "slate_dark"
        ratio: "3:2"
        title: "#{slide_title}"
        subtitle: "One column on left, two stacked containers on right"
        left:
          type: "code"
          title: "kernel.cr"
          lang: "crystal"
          code: |
            def execute
              puts "Primary column content"
            end
        right_top:
          title: "Upper Container"
          color: "emerald"
          items:
            - "First stacked element"
            - "Key architectural point"
        right_bottom:
          title: "Lower Container"
          color: "accent"
          items:
            - "Second stacked element"
            - "Supporting specification"
        notes: |
          Speaker notes for #{slide_title}.
        YAML
      when "vertical-timeline", "timeline-vertical"
        <<-YAML
        id: "#{id}"
        layout: "vertical-timeline"
        badge: "TIMELINE"
        badge_color: "accent"
        palette: "slate_dark"
        title: "#{slide_title}"
        subtitle: "Sequential milestone progression"
        events:
          - date: "PHASE 1"
            title: "Foundation & Prototype"
            status: "done"
            color: "emerald"
            desc: "Core architectural requirements established."
          - date: "PHASE 2"
            title: "Production Hardening"
            status: "active"
            color: "accent"
            desc: "Zero-inline style verification."
          - date: "PHASE 3"
            title: "General Availability"
            status: "pending"
            color: "amber"
            desc: "Public shard distribution."
        notes: |
          Speaker notes for #{slide_title}.
        YAML
      when "roadmap-timeline", "gantt"
        <<-YAML
        id: "#{id}"
        layout: "roadmap-timeline"
        badge: "ROADMAP"
        badge_color: "accent"
        palette: "slate_dark"
        title: "#{slide_title}"
        subtitle: "Multi-track quarterly deliverable schedule"
        periods: ["Q1 2026", "Q2 2026", "Q3 2026", "Q4 2026"]
        tracks:
          - name: "Core Engine"
            badge: "BACKEND"
            color: "accent"
            bars:
              - title: "Compiler Pipeline"
                start: 1
                span: 2
                color: "emerald"
                badge: "DONE"
          - name: "Layout Design"
            badge: "FRONTEND"
            color: "purple"
            bars:
              - title: "Semantic Layouts"
                start: 2
                span: 2
                color: "accent"
                badge: "ACTIVE"
        notes: |
          Speaker notes for #{slide_title}.
        YAML
      when "calendar-month", "calendar"
        <<-YAML
        id: "#{id}"
        layout: "calendar-month"
        badge: "CALENDAR"
        badge_color: "emerald"
        palette: "slate_dark"
        title: "#{slide_title}"
        subtitle: "Monthly release and sprint calendar"
        month: "OCTOBER 2026"
        start_day_offset: 3
        total_days: 31
        active_day: 15
        events:
          - day: 8
            title: "Release Candidate"
            color: "emerald"
            badge: "RC"
          - day: 15
            title: "Demo Day"
            color: "accent"
            badge: "LIVE"
        notes: |
          Speaker notes for #{slide_title}.
        YAML
      when "calendar-schedule", "schedule"
        <<-YAML
        id: "#{id}"
        layout: "calendar-schedule"
        badge: "SCHEDULE"
        badge_color: "accent"
        palette: "slate_dark"
        title: "#{slide_title}"
        subtitle: "Multi-track conference timetable"
        columns:
          - title: "Day 1 • Architecture"
            color: "accent"
            sessions:
              - time: "09:00 - 10:30"
                title: "Opening Keynote"
                speaker: "Lead Architect"
                badge: "KEYNOTE"
                desc: "Welcome and high-level architectural overview."
          - title: "Day 2 • Deep Dives"
            color: "emerald"
            sessions:
              - time: "10:00 - 11:30"
                title: "Systems Workshop"
                speaker: "Core Engineer"
                badge: "WORKSHOP"
                desc: "Hands-on implementation lab."
        notes: |
          Speaker notes for #{slide_title}.
        YAML
      when "radial-cycle", "cycle", "flywheel"
        <<-YAML
        id: "#{id}"
        layout: "radial-cycle"
        badge: "FLYWHEEL"
        badge_color: "accent"
        palette: "slate_dark"
        title: "#{slide_title}"
        subtitle: "Continuous circular refinement loop"
        hub:
          title: "CORE PROCESS"
          subtitle: "Feedback Engine"
          badge: "FLYWHEEL"
        steps:
          - step: "01"
            title: "Ingest"
            color: "accent"
            desc: "Streaming input payload."
          - step: "02"
            title: "Transform"
            color: "emerald"
            desc: "Type-safe normalization."
          - step: "03"
            title: "Emit"
            color: "purple"
            desc: "Zero-inline style artifact."
          - step: "04"
            title: "Verify"
            color: "amber"
            desc: "Automated test assertions."
        notes: |
          Speaker notes for #{slide_title}.
        YAML
      when "editorial-split", "magazine"
        <<-YAML
        id: "#{id}"
        layout: "editorial-split"
        badge: "EDITORIAL"
        badge_color: "rose"
        palette: "slate_dark"
        title: "#{slide_title}"
        subtitle: "Magazine aesthetic with typographic emphasis"
        numeral: "01"
        headline: "High-Impact Architectural Statement"
        quote: "Design is not just what it looks like, it is how it works."
        attribution: "Design Manifesto"
        cards:
          - title: "Core Principle"
            color: "accent"
            desc: "Separation of structure and presentation style."
        notes: |
          Speaker notes for #{slide_title}.
        YAML
      when "convergence", "venn"
        <<-YAML
        id: "#{id}"
        layout: "convergence"
        badge: "CONVERGENCE"
        badge_color: "accent"
        palette: "slate_dark"
        title: "#{slide_title}"
        subtitle: "Multiple paradigms meeting at synthesis core"
        pillars:
          - title: "Pillar A"
            color: "accent"
            desc: "First requirement stream"
          - title: "Pillar B"
            color: "emerald"
            desc: "Second requirement stream"
        core:
          title: "The Synthesis"
          badge: "SWEET SPOT"
          color: "accent"
          desc: "Unifying solution satisfying all requirements."
        notes: |
          Speaker notes for #{slide_title}.
        YAML
      else
        <<-YAML
        id: "#{id}"
        layout: "#{layout}"
        badge: "KEYNOTE"
        badge_color: "accent"
        palette: "slate_dark"
        ratio: "1:1"
        title: "#{slide_title}"
        subtitle: "Subtitle description"
        code_title: "example.cr"
        code_lang: "crystal"
        code: |
          def hello
            puts "Hello from Sunstone!"
          end
        cards:
          - title: "Key Highlights"
            color: "accent"
            items:
              - "First highlight item"
              - "Second highlight item"
        notes: |
          Speaker notes.
        YAML
      end

      File.write(file_path, content)
      file_path
    end

    def self.new_theme(name : String, directory : String = "themes") : Tuple(String, String)
      Dir.mkdir_p(directory)
      clean_name = name.downcase.gsub(/[^a-z0-9_-]/, "_")
      css_file = File.join(directory, "#{clean_name}.css")
      json_file = File.join(directory, "#{clean_name}_palettes.json")

      css_content = <<-CSS
      /**
       * Sunstone Custom Theme: #{clean_name.capitalize}
       *
       * Sunstone uses a strict Zero-Inline-Styles architecture.
       * All geometry, layout, and colors are governed via CSS classes,
       * data-* attributes, and the CSS custom properties below.
       */

      :root {
        /* 1. Typography */
        --sunstone-font-sans: 'Inter', system-ui, -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif;
        --sunstone-font-mono: 'JetBrains Mono', 'Cascadia Code', Consolas, monospace;

        /* 2. Geometry & Radii */
        --sunstone-radius-sm: 6px;
        --sunstone-radius-md: 10px;
        --sunstone-radius-lg: 16px;
        --sunstone-shadow: 0 10px 25px -5px rgba(0, 0, 0, 0.4);

        /* 3. Default Palette Colors (Overridden per slide via data-palette) */
        --sunstone-bg: #0f172a;
        --sunstone-surface: #1e293b;
        --sunstone-surface-hover: #273549;
        --sunstone-text-primary: #f8fafc;
        --sunstone-text-secondary: #cbd5e1;
        --sunstone-text-muted: #94a3b8;
        --sunstone-accent: #38bdf8;
        --sunstone-accent-secondary: #818cf8;
        --sunstone-accent-tertiary: #34d399;
        --sunstone-border: #334155;
        --sunstone-border-active: #38bdf8;
        --sunstone-code-bg: #090d16;
      }

      /* Base Presentation Container */
      .reveal {
        font-family: var(--sunstone-font-sans);
        color: var(--sunstone-text-secondary);
        background-color: var(--sunstone-bg);
      }

      /* Slide Headers */
      .slide-title {
        font-weight: 700;
        letter-spacing: -0.02em;
      }

      /* Cards & Containers */
      .card {
        background: var(--sunstone-surface);
        border: 1px solid var(--sunstone-border);
        border-radius: var(--sunstone-radius-md);
        box-shadow: var(--sunstone-shadow);
        transition: border-color 0.2s ease;
      }

      .card:hover {
        border-color: var(--sunstone-border-active);
      }

      /* Code Windows */
      .code-window {
        background: var(--sunstone-code-bg);
        border: 1px solid var(--sunstone-border);
        border-radius: var(--sunstone-radius-md);
      }

      .code-window .window-header {
        background: var(--sunstone-surface);
        border-bottom: 1px solid var(--sunstone-border);
      }

      /* Badges */
      .badge {
        border-radius: var(--sunstone-radius-sm);
        font-weight: 600;
        text-transform: uppercase;
      }
      CSS

      json_content = <<-JSON
      [
        {
          "id": "#{clean_name}_dark",
          "name": "#{clean_name.capitalize} Dark (Default)",
          "colors": {
            "bg_color": "#0f172a",
            "surface_color": "#1e293b",
            "surface_hover": "#273549",
            "text_primary": "#f8fafc",
            "text_secondary": "#cbd5e1",
            "text_muted": "#94a3b8",
            "accent_color": "#38bdf8",
            "accent_secondary": "#818cf8",
            "accent_tertiary": "#34d399",
            "border_color": "#334155",
            "border_active": "#38bdf8",
            "code_bg": "#090d16"
          }
        },
        {
          "id": "#{clean_name}_light",
          "name": "#{clean_name.capitalize} Light",
          "colors": {
            "bg_color": "#f8fafc",
            "surface_color": "#ffffff",
            "surface_hover": "#f1f5f9",
            "text_primary": "#0f172a",
            "text_secondary": "#334155",
            "text_muted": "#64748b",
            "accent_color": "#2563eb",
            "accent_secondary": "#4f46e5",
            "accent_tertiary": "#059669",
            "border_color": "#e2e8f0",
            "border_active": "#2563eb",
            "code_bg": "#1e293b"
          }
        }
      ]
      JSON

      File.write(css_file, css_content)
      File.write(json_file, json_content)

      {css_file, json_file}
    end
  end
end
