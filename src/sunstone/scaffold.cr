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
