require "html"
require "./version"
require "./assets"

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

    def self.generate(output_path : String, themes : Array(String) = Assets.available_themes)
      html = generate_html(themes)
      File.write(output_path, html)
    end

    def self.generate_html(themes : Array(String) = Assets.available_themes) : String
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
              max-width: 680px;
              margin: 70px auto;
              padding: 0 20px;
              background: #0f172a;
              color: #e2e8f0;
              line-height: 1.6;
            }
            header { margin-bottom: 32px; }
            h1 { font-size: 2rem; color: #fff; margin-bottom: 6px; }
            p.lead { color: #94a3b8; font-size: 1.05rem; }
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
              background: #1e293b;
              border: 1px solid #334155;
              border-radius: 8px;
              color: #f8fafc;
              text-decoration: none;
              font-weight: 600;
              transition: all 0.15s ease;
            }
            .theme-item a:hover {
              background: #273549;
              border-color: #38bdf8;
              color: #38bdf8;
              transform: translateX(2px);
            }
            .theme-name {
              font-size: 1.1rem;
              display: flex;
              align-items: center;
              gap: 8px;
            }
            .theme-desc {
              font-size: 0.88rem;
              font-weight: 400;
              color: #94a3b8;
            }
            footer {
              margin-top: 48px;
              padding-top: 20px;
              border-top: 1px solid #1e293b;
              font-size: 0.85rem;
              color: #64748b;
            }
            footer a { color: #38bdf8; text-decoration: none; }
            footer a:hover { text-decoration: underline; }
            @media (max-width: 540px) {
              .theme-item a { flex-direction: column; align-items: flex-start; gap: 4px; }
            }
          </style>
        </head>
        <body>
          <header>
            <h1>☀️ Sunstone</h1>
            <p class="lead">Select a theme to view the demo presentation:</p>
          </header>

          <ul class="theme-list">
        HTML

        themes.each do |theme_name|
          desc = THEME_DESCRIPTIONS[theme_name]? || "Presentation theme"
          display_name = theme_name.split(/[-_]/).map(&.capitalize).join(" ")

          str << <<-ITEM
            <li class="theme-item">
              <a href="themes/#{theme_name}/">
                <span class="theme-name">#{HTML.escape(display_name)}</span>
                <span class="theme-desc">#{HTML.escape(desc)} →</span>
              </a>
            </li>
          ITEM
        end

        str << <<-HTML
          </ul>

          <footer>
            <p><a href="https://github.com/sol-vin/sunstone">GitHub Repository</a> • Built with <a href="https://crystal-lang.org">Crystal</a></p>
          </footer>
        </body>
        </html>
        HTML
      end
    end
  end
end
