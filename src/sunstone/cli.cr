require "opal"
require "./version"
require "./models/deck"
require "./models/palette"
require "./layouts/router"
require "./generator"
require "./server"
require "./scaffold"

module Sunstone
  class CLI < Opal::CLI::App
    def initialize
      super("sunstone", Sunstone::VERSION)
      description "☀️ Sunstone — Generic YAML-driven slide presentation engine with zero-inline-style semantic HTML"

      # -------------------------------------------------------------
      # Command: build
      # -------------------------------------------------------------
      command "build", "Compile slide deck into production HTML, Markdown, and static assets" do |cmd|
        cmd.option :deck, "--deck", "-d", "Path to presentation deck.yml", default: "deck.yml"
        cmd.option :out, "--out", "-o", "Output directory for compiled slides", default: "dist"
        cmd.option :theme, "--theme", "-t", "Override theme specified in deck.yml"
        cmd.flag :all_themes, "--all-themes", description: "Build showcase for all themes and emit an interactive landing page gallery at index.html"
        cmd.flag :no_vendor, "--no-vendor", description: "Skip extracting vendor assets (Reveal.js, Highlight.js, Asciinema)"

        cmd.run do |ctx|
          deck_file = ctx.string(:deck)
          out_dir = ctx.string(:out)
          no_vendor = ctx.flag?(:no_vendor)

          unless File.exists?(deck_file)
            STDERR.puts "\e[31mError:\e[0m Deck file '#{deck_file}' not found."
            exit 1
          end

          deck = Deck.load(deck_file)

          if ctx.flag?(:all_themes)
            puts "\e[36m☀️  Sunstone v#{Sunstone::VERSION} — Multi-Theme Showcase & Landing Page\e[0m"
            puts "  Deck:           \e[1m#{deck.title}\e[0m"
            puts "  Output Dir:     #{File.expand_path(out_dir)}"

            themes_list = Assets.available_themes
            themes_list.each do |theme_name|
              theme_deck = Deck.load(deck_file)
              theme_deck.theme = theme_name
              theme_out_dir = File.join(out_dir, "themes", theme_name)

              Generator.new(theme_deck).build(theme_out_dir, copy_vendor: !no_vendor)
              puts "  • Compiled theme '\e[33m#{theme_name}\e[0m' -> #{theme_out_dir}"
            end

            # Generate Root Landing Page
            landing_html_path = File.join(out_dir, "index.html")
            LandingPage.generate(landing_html_path, themes_list)
            puts "  • Generated Landing Page Gallery -> #{landing_html_path}"

            puts "\e[32m✓ Multi-theme gallery build complete!\e[0m"
            puts "  Open #{landing_html_path} to explore all #{themes_list.size} theme options."
            next 0
          end

          if theme_override = ctx.string?(:theme)
            deck.theme = theme_override
          end

          generator = Generator.new(deck)

          puts "\e[36m☀️  Sunstone v#{Sunstone::VERSION}\e[0m"
          puts "  Compiling deck: \e[1m#{deck.title}\e[0m"
          puts "  Theme:          \e[33m#{deck.theme}\e[0m"
          puts "  Output Dir:     #{File.expand_path(out_dir)}"

          html_path, md_path = generator.build(out_dir, copy_vendor: !no_vendor)

          puts "\e[32m✓ Presentation compiled successfully!\e[0m"
          puts "  • HTML Deck:     #{html_path} (#{generator.total_slides} slides)"
          puts "  • Reference Doc: #{md_path}"
          puts "  • Theme Assets:  #{File.join(out_dir, "theme.css")}"
          0
        end
      end

      # -------------------------------------------------------------
      # Command: serve
      # -------------------------------------------------------------
      command "serve", "Build deck and launch local live preview web server" do |cmd|
        cmd.option :deck, "--deck", "-d", "Path to presentation deck.yml", default: "deck.yml"
        cmd.option :out, "--out", "-o", "Temporary compilation directory", default: "dist"
        cmd.option :theme, "--theme", "-t", "Override theme specified in deck.yml"
        cmd.option :port, "--port", "-p", "Server port", default: 8000
        cmd.flag :no_browser, "--no-browser", description: "Do not automatically launch web browser"

        cmd.run do |ctx|
          deck_file = ctx.string(:deck)
          out_dir = ctx.string(:out)
          port = ctx.int?(:port) || 8000
          no_browser = ctx.flag?(:no_browser)

          unless File.exists?(deck_file)
            STDERR.puts "\e[31mError:\e[0m Deck file '#{deck_file}' not found."
            exit 1
          end

          deck = Deck.load(deck_file)
          if theme_override = ctx.string?(:theme)
            deck.theme = theme_override
          end

          generator = Generator.new(deck)
          generator.build(out_dir)

          Sunstone::Server.run(out_dir, port: port, open_browser: !no_browser)
          0
        end
      end

      # -------------------------------------------------------------
      # Command: validate
      # -------------------------------------------------------------
      command "validate", "Verify syntax, slide references, layouts, and palettes in a deck" do |cmd|
        cmd.option :deck, "--deck", "-d", "Path to presentation deck.yml", default: "deck.yml"

        cmd.run do |ctx|
          deck_file = ctx.string(:deck)
          unless File.exists?(deck_file)
            STDERR.puts "\e[31mError:\e[0m Deck file '#{deck_file}' not found."
            exit 1
          end

          puts "Validating presentation: \e[1m#{deck_file}\e[0m"
          deck = Deck.load(deck_file)
          palettes = Palette.load_for_theme(deck.theme, deck.palettes)

          errors = 0
          warnings = 0

          puts "  • Deck Title:    #{deck.title}"
          puts "  • Theme:         #{deck.theme}"
          puts "  • Slides Found:  #{deck.slides.size}"

          deck.slides.each_with_index do |slide, idx|
            # Validate layout
            layout = LayoutRouter.resolve(slide.layout)
            if layout.nil?
              STDERR.puts "  \e[31m[ERROR]\e[0m Slide #{idx + 1} ('#{slide.id}'): Unknown layout '#{slide.layout}'"
              errors += 1
            end

            # Validate palette
            unless palettes.has_key?(slide.palette)
              STDERR.puts "  \e[33m[WARN]\e[0m Slide #{idx + 1} ('#{slide.id}'): Palette '#{slide.palette}' not found in theme '#{deck.theme}' (will fall back to default palette)"
              warnings += 1
            end
          end

          if errors == 0
            puts "\n\e[32m✓ Deck validation passed!\e[0m (#{deck.slides.size} slides, #{warnings} warnings)"
            0
          else
            puts "\n\e[31m✗ Deck validation failed with #{errors} errors.\e[0m"
            1
          end
        end
      end

      # -------------------------------------------------------------
      # Command: new
      # -------------------------------------------------------------
      command "new", "Create a new slide presentation project" do |cmd|
        cmd.argument :name, "Project directory name"
        cmd.option :theme, "--theme", "-t", "Slide theme (generic or sol.vin)", default: "generic"
        cmd.option :title, "--title", description: "Presentation title"
        cmd.option :author, "--author", description: "Presentation author"

        cmd.run do |ctx|
          name = ctx.args.first? || "slideshow"
          theme = ctx.string(:theme)
          title = ctx.string?(:title)
          author = ctx.string?(:author)

          Scaffold.new_project(name, theme: theme, title: title, author: author)
          puts "\e[32m✓ Created new Sunstone project in '#{name}'\e[0m"
          puts "  cd #{name}"
          puts "  sunstone serve"
          0
        end
      end

      # -------------------------------------------------------------
      # Command: init
      # -------------------------------------------------------------
      command "init", "Initialize a Sunstone presentation in the current directory" do |cmd|
        cmd.option :theme, "--theme", "-t", "Slide theme (generic or sol.vin)", default: "generic"
        cmd.option :title, "--title", description: "Presentation title"
        cmd.option :author, "--author", description: "Presentation author"

        cmd.run do |ctx|
          theme = ctx.string(:theme)
          title = ctx.string?(:title)
          author = ctx.string?(:author)

          Scaffold.new_project(".", theme: theme, title: title, author: author)
          puts "\e[32m✓ Initialized Sunstone presentation in current directory\e[0m"
          0
        end
      end

      # -------------------------------------------------------------
      # Command: add-slide
      # -------------------------------------------------------------
      command "add-slide", "Generate a new slide YAML file" do |cmd|
        cmd.argument :id, "Unique slide ID"
        cmd.option :layout, "--layout", "-l", "Slide layout", default: "two-column"
        cmd.option :title, "--title", "-t", "Slide title"
        cmd.option :dir, "--dir", "-d", "Slides directory", default: "slides"

        cmd.run do |ctx|
          id = ctx.args.first?
          unless id
            STDERR.puts "\e[31mError:\e[0m Slide ID is required. Example: sunstone add-slide architecture"
            exit 1
          end

          layout = ctx.string(:layout)
          title = ctx.string?(:title)
          target_dir = ctx.string(:dir)

          file_path = Scaffold.add_slide(id, layout: layout, title: title, target_dir: target_dir)
          puts "\e[32m✓ Added slide:\e[0m #{file_path}"
          puts "  Remember to add '- #{file_path}' to your deck.yml slides list!"
          0
        end
      end

      # -------------------------------------------------------------
      # Command: list-layouts
      # -------------------------------------------------------------
      command "list-layouts", "List all available semantic slide layouts" do |cmd|
        cmd.run do |_ctx|
          puts "\e[1mAvailable Sunstone Slide Layouts:\e[0m\n"
          puts "  • \e[36mintro\e[0m            Hero / Title slide with badges, subtitle, and speaker pillars"
          puts "  • \e[36mchapter\e[0m          Section divider with chapter number and topic pillars"
          puts "  • \e[36mtwo-column\e[0m       Code on left/right + cards, notes, or highlights (supports 1:1, 3:2, 2:3, 1:2, 2:1 ratios)"
          puts "  • \e[36mcode-comparison\e[0m  Two-step critique or before/after side-by-side code blocks"
          puts "  • \e[36mthree-column\e[0m     Three equal or weighted informational cards/columns"
          puts "  • \e[36mfour-column\e[0m      Four-card grid for quadrants, pillars, or comparisons"
          puts "  • \e[36mmatrix\e[0m           2x2 quadrant analysis with custom labels and colors"
          puts "  • \e[36mtimeline\e[0m         Horizontal milestone rail with status indicators and dates"
          puts "  • \e[36marchitecture\e[0m     Multi-tier technology stack with CSS flow indicators"
          puts "  • \e[36mmedia\e[0m            Images, video, or embedded Asciinema terminal recordings"
          puts "  • \e[36mprofile\e[0m          Speaker / team bio with avatar, social links, and credentials"
          puts "  • \e[36mdual-mode\e[0m        Interactive tabbed comparison (e.g. Traditional vs Sunstone)"
          puts "  • \e[36mdemo-roadmap\e[0m     Interactive live-demo task list and checklist"
          puts "  • \e[36mclosing\e[0m          Outro slide with takeaways, key quote, and contact links"
          puts "  • \e[36mquote\e[0m            High-impact typographic quote / testimonial slide"
          0
        end
      end

      # -------------------------------------------------------------
      # Command: new-theme
      # -------------------------------------------------------------
      command "new-theme", "Scaffold a starter custom theme and palette catalog" do |cmd|
        cmd.argument :name, "Theme name (e.g. corporate, synthwave, minimal)"
        cmd.option :dir, "--dir", "-d", "Directory to write theme files", default: "themes"

        cmd.run do |ctx|
          name = ctx.args.first?
          unless name
            STDERR.puts "\e[31mError:\e[0m Theme name is required. Example: sunstone new-theme corporate"
            exit 1
          end

          target_dir = ctx.string(:dir)
          css_path, json_path = Scaffold.new_theme(name, directory: target_dir)

          puts "\e[32m✓ Created custom theme in '#{target_dir}':\e[0m"
          puts "  • Stylesheet: #{css_path}"
          puts "  • Palettes:   #{json_path}"
          puts ""
          puts "  To use this theme in your presentation, update deck.yml:"
          puts "    \e[36mtheme: #{css_path.gsub("\\", "/")}\e[0m"
          0
        end
      end

      # -------------------------------------------------------------
      # Command: list-themes
      # -------------------------------------------------------------
      command "list-themes", "List available presentation themes" do |cmd|
        cmd.run do |_ctx|
          puts "\e[1mAvailable Sunstone Presentation Themes:\e[0m\n"
          puts "  • \e[32mgeneric\e[0m (Default)   Modern, clean, high-contrast engineering aesthetic."
          puts "                      Includes 8 modern palettes (slate_dark, emerald_matrix, clean_light, etc.)."
          puts "                      Zero inline styles, pure semantic CSS classes and variables."
          puts ""
          puts "  • \e[33msol.vin\e[0m             Retro Sol.vin aesthetic inspired by terminal engineering."
          puts "                      Includes 46 retro palettes (spaces_98, warm_paper, neon_cyber, etc.)."
          puts "                      Embeds 3D spinning isometric wireframe cube (cube.js) and SVG chromatic filters."
          puts ""
          puts "  • \e[36mnordic\e[0m              Airy Scandinavian minimalism with cool slate, frosted glass, and arctic cyan/teal."
          puts "                      Includes 6 palettes (fjord_deep, aurora_night, glacier_frost, etc.)."
          puts ""
          puts "  • \e[31mbrutalist\e[0m           Swiss neo-brutalist aesthetic with 2.5px solid borders, offset drop shadows, and high contrast."
          puts "                      Includes 6 palettes (yellow_hazard, paper_ink, electric_lime, orange_warning, etc.)."
          puts ""
          puts "  • \e[35macademic\e[0m            Formal publication & LaTeX / Computer Modern styling with serif headings and hairlines."
          puts "                      Includes 6 palettes (computer_modern, cambridge_blue, oxford_crimson, etc.)."
          puts ""
          puts "  • \e[34mtokyo-night\e[0m         Sleek developer IDE & cyberpunk aesthetic with glowing neon borders and dark editor styling."
          puts "                      Includes 6 palettes (tokyo_night, tokyo_storm, catppuccin_mocha, dracula_vampire, etc.)."
          puts ""
          puts "  • \e[90mCustom Theme\e[0m        Point 'theme:' in deck.yml directly to any CSS file (e.g. theme: ./themes/brand.css)."
          0
        end
      end

      # -------------------------------------------------------------
      # Command: list-palettes
      # -------------------------------------------------------------
      command "list-palettes", "List available palettes for a theme" do |cmd|
        cmd.option :theme, "--theme", "-t", "Theme name (generic, sol.vin, nordic, brutalist, academic, tokyo-night)", default: "generic"

        cmd.run do |ctx|
          theme = ctx.string(:theme)
          palettes = Palette.load_for_theme(theme)

          puts "\e[1mPalettes for theme '#{theme}' (#{palettes.size} total):\e[0m\n"
          palettes.each_value do |p|
            accent = p.accent_color
            bg = p.bg_color
            puts "  • \e[36m%-22s\e[0m %s (bg: %s, accent: %s)" % [p.id, p.name, bg, accent]
          end
          0
        end
      end
    end

    def self.run(args = ARGV)
      new.run(args)
    end
  end
end
