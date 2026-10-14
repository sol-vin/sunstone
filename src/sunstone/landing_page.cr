require "html"
require "./version"
require "./assets"
require "./palette_component"

module Sunstone
  module LandingPage
    THEME_DESCRIPTIONS = {
      "generic"     => "Modern, clean high-contrast tech deck",
      "nordic"      => "Scandinavian minimalism & icy cool tones",
      "brutalist"   => "Neo-brutalist solid borders & hard drop shadows",
      "academic"    => "Formal LaTeX & Computer Modern typography",
      "tokyo-night" => "Cyberpunk developer dark IDE aesthetic",
      "sol.vin"     => "Retro 90s aesthetic with 3D wireframe cube",
    }

    THEME_ICONS = {
      "generic"     => "bolt.svg",
      "nordic"      => "sparkles.svg",
      "brutalist"   => "box.svg",
      "academic"    => "scroll.svg",
      "tokyo-night" => "terminal.svg",
      "sol.vin"     => "cube.svg",
    }

    def self.generate(output_path : String, themes : Array(String) = Assets.available_themes)
      out_dir = File.dirname(output_path)
      Dir.mkdir_p(out_dir)
      File.write(File.join(out_dir, "hold_click.js"), PaletteComponent.hold_click_js)
      File.write(File.join(out_dir, "palette_engine.js"), PaletteComponent.palette_engine_js)

      html = generate_html(themes)
      File.write(output_path, html)
    end

    def self.generate_html(themes : Array(String) = Assets.available_themes) : String
      palette_bundle = PaletteComponent.build do |c|
        c.theme("sol.vin")
        c.button do |b|
          b.default_label("Warm Paper (Default)")
        end
      end

      logo_icon = PaletteComponent::Icons.render("sparkles.svg", "landing-logo-icon")
      arrow_icon = PaletteComponent::Icons.render("arrow-right.svg", "landing-arrow-icon")
      github_icon = PaletteComponent::Icons.render("github.svg", "landing-footer-icon")
      gem_icon = PaletteComponent::Icons.render("gem.svg", "landing-footer-icon")

      String.build do |str|
        str << <<-HTML
        <!DOCTYPE html>
        <html lang="en">
        <head>
          <meta charset="UTF-8">
          <meta name="viewport" content="width=device-width, initial-scale=1.0">
          <title>Sunstone — Slide Theme Demos</title>
          <style>
            * { box-sizing: border-box; margin: 0; padding: 0; }
            body {
              font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif;
              max-width: 720px;
              margin: 70px auto;
              padding: 0 20px;
              background: var(--bg-color, #0f172a);
              color: var(--text-color, #e2e8f0);
              line-height: 1.6;
              transition: background-color 0.2s ease, color 0.2s ease;
            }
            header {
              margin-bottom: 32px;
              display: flex;
              justify-content: space-between;
              align-items: flex-start;
              gap: 16px;
              flex-wrap: wrap;
            }
            h1 {
              font-size: 2rem;
              color: var(--text-color, #fff);
              margin-bottom: 6px;
              display: flex;
              align-items: center;
              gap: 10px;
            }
            p.lead { color: var(--text-dim, #94a3b8); font-size: 1.05rem; }
            .project-icon-svg {
              width: 1em;
              height: 1em;
              vertical-align: -0.125em;
              fill: currentColor;
              flex-shrink: 0;
            }
            .landing-logo-icon {
              color: var(--accent-color, #38bdf8);
            }
            .theme-list {
              list-style: none;
              display: flex;
              flex-direction: column;
              gap: 12px;
            }
            .theme-item a {
              display: flex;
              justify-content: space-between;
              align-items: center;
              padding: 16px 20px;
              background: var(--bg-window, #1e293b);
              border: 1px solid var(--border-color, #334155);
              border-radius: 8px;
              color: var(--text-color, #f8fafc);
              text-decoration: none;
              font-weight: 600;
              box-shadow: 3px 3px 0px var(--shadow-color, transparent);
              transition: all 0.15s ease;
            }
            .theme-item a:hover {
              background: var(--sunstone-surface-hover, var(--bg-window, #273549));
              border-color: var(--border-active, #38bdf8);
              color: var(--accent-color, #38bdf8);
              transform: translateX(2px);
            }
            .theme-name {
              font-size: 1.1rem;
              display: flex;
              align-items: center;
              gap: 10px;
            }
            .theme-desc {
              font-size: 0.88rem;
              font-weight: 400;
              color: var(--text-dim, #94a3b8);
              display: inline-flex;
              align-items: center;
              gap: 6px;
            }
            footer {
              margin-top: 48px;
              padding-top: 20px;
              border-top: 1px solid var(--border-color, #1e293b);
              font-size: 0.85rem;
              color: var(--text-dim, #64748b);
            }
            footer a {
              color: var(--link-color, var(--accent-color, #38bdf8));
              text-decoration: none;
              display: inline-flex;
              align-items: center;
              gap: 5px;
            }
            footer a:hover { text-decoration: underline; }
            @media (max-width: 540px) {
              .theme-item a { flex-direction: column; align-items: flex-start; gap: 4px; }
            }
        #{palette_bundle.stylesheet}
          </style>
          <script>
            window.SOLVIN_PALETTE_ICONS = #{PaletteComponent::Icons.js_icons_json};
            window.SITE_PALETTES = #{palette_bundle.palettes_json};
          </script>
          <script src="hold_click.js"></script>
          <script src="palette_engine.js"></script>
          <script>
            if (window.PaletteEngine) {
              window.PaletteEngine.initHead(window.SITE_PALETTES);
            }
          </script>
        </head>
        <body>
        #{palette_bundle.spinner_html}
        #{palette_bundle.toolbar_html}
        #{palette_bundle.modal_html}
          <header>
            <div>
              <h1>#{logo_icon} Sunstone</h1>
              <p class="lead">Select a theme to view the demo presentation:</p>
            </div>
          </header>

          <ul class="theme-list">
        HTML

        themes.each do |theme_name|
          desc = THEME_DESCRIPTIONS[theme_name]? || "Presentation theme"
          icon_file = THEME_ICONS[theme_name]? || "palette.svg"
          theme_icon = PaletteComponent::Icons.render(icon_file, "theme-item-icon")
          display_name = theme_name.split(/[-_]/).map(&.capitalize).join(" ")

          str << <<-ITEM
            <li class="theme-item">
              <a href="themes/#{theme_name}/">
                <span class="theme-name">#{theme_icon} #{HTML.escape(display_name)}</span>
                <span class="theme-desc">#{HTML.escape(desc)} #{arrow_icon}</span>
              </a>
            </li>
          ITEM
        end

        str << <<-HTML
          </ul>

          <footer>
            <p><a href="https://github.com/sol-vin/sunstone">#{github_icon} GitHub Repository</a> • Built with <a href="https://crystal-lang.org">#{gem_icon} Crystal</a></p>
          </footer>
          <script>
            if (window.PaletteEngine) {
              window.PaletteEngine.initDom();
            }
          </script>
        </body>
        </html>
        HTML
      end
    end
  end
end
