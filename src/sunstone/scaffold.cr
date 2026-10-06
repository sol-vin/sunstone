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
  end
end
