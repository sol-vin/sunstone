require "base64"
require "./layout_renderer"

module Sunstone
  class TwoColumnLayout < LayoutRenderer
    def render_html(slide : Slide, deck : Deck, palette : Palette, slide_num : Int32, total_slides : Int32) : String
      ratio = slide.raw["ratio"]?.try(&.as_s) || "1:1"
      left_data = slide.raw["left"]?
      right_data = slide.raw["right"]?

      # Graceful fallback: synthesize left / right if top-level code or cards are given
      if left_data.nil? && (slide.raw["code"]? || slide.raw["code_title"]?)
        left_h = Hash(YAML::Any, YAML::Any).new
        left_h[YAML::Any.new("type")] = YAML::Any.new("code")
        left_h[YAML::Any.new("title")] = slide.raw["code_title"]? || YAML::Any.new("Code")
        left_h[YAML::Any.new("lang")] = slide.raw["code_lang"]? || YAML::Any.new("crystal")
        left_h[YAML::Any.new("code")] = slide.raw["code"]? || YAML::Any.new("")
        if tag = slide.raw["code_tag"]?
          left_h[YAML::Any.new("tag")] = tag
        end
        if density = slide.raw["code_density"]? || slide.raw["density"]?
          left_h[YAML::Any.new("density")] = density
        end
        left_data = YAML::Any.new(left_h)
      end

      if right_data.nil? && slide.raw["cards"]?
        right_data = slide.raw["cards"]?
      end

      body = String.build do |str|
        str << render_slide_header(slide) << "\n"
        str << "          <div class=\"slide-body\" data-layout=\"two-column\" data-ratio=\"" << ratio << "\">\n"

        if left_data
          str << "            <div class=\"column col\" data-slot=\"left\">\n"
          render_column_content(str, left_data, slide, deck)
          str << "            </div>\n"
        end

        if right_data
          str << "            <div class=\"column col\" data-slot=\"right\">\n"
          render_column_content(str, right_data, slide, deck)
          str << "            </div>\n"
        end

        str << "          </div>"
      end

      render_section_wrapper(slide, deck, palette, slide_num, total_slides, body)
    end

    private def render_column_content(str : String::Builder, data : YAML::Any, slide : Slide, deck : Deck)
      if data.as_a?
        data.as_a.each { |item| render_single_item(str, item, slide, deck) }
      else
        render_single_item(str, data, slide, deck)
      end
    end

    private def render_single_item(str : String::Builder, data : YAML::Any, slide : Slide, deck : Deck)
      item_type = data["type"]?.try(&.as_s) || "card"

      case item_type
      when "code"
        title = data["title"]?.try(&.as_s) || "Code"
        lang = data["lang"]?.try(&.as_s) || "crystal"
        code = data["code"]?.try(&.as_s) || ""
        tag = data["tag"]?.try(&.as_s)
        density = data["density"]?.try(&.as_s)
        str << render_code_container(title, lang, code, tag, density) << "\n"
      when "terminal"
        title = data["title"]?.try(&.as_s) || "Terminal"
        code = data["code"]?.try(&.as_s) || ""
        density = data["density"]?.try(&.as_s)
        density_attr = density ? " data-density=\"#{density}\"" : ""
        str << "            <div class=\"terminal-window col\"" << density_attr << ">\n"
        str << "              <div class=\"window-header terminal-header\">\n"
        str << "                <div class=\"terminal-dots\">\n"
        str << "                  <span class=\"terminal-dot dot-1 red\" title=\"Close\"></span>\n"
        str << "                  <span class=\"terminal-dot dot-2 yellow\" title=\"Minimize\"></span>\n"
        str << "                  <span class=\"terminal-dot dot-3 green\" title=\"Maximize\"></span>\n"
        str << "                </div>\n"
        str << "                <span class=\"window-title terminal-title\">" << LayoutRenderer.escape(title) << "</span>\n"
        str << "                <div class=\"window-controls\">\n"
        str << "                  <span class=\"lang-tag terminal-badge\">BASH</span>\n"
        str << "                  <span class=\"window-btn close\" title=\"Close\"><svg class=\"fa-icon fa-xmark\" viewBox=\"0 0 384 512\" aria-hidden=\"true\"><path fill=\"currentColor\" d=\"M55.1 73.4c-12.5-12.5-32.8-12.5-45.3 0s-12.5 32.8 0 45.3L147.2 256 9.9 393.4c-12.5 12.5-12.5 32.8 0 45.3s32.8 12.5 45.3 0L192.5 301.3 329.9 438.6c12.5 12.5 32.8 12.5 45.3 0s12.5-32.8 0-45.3L237.8 256 375.1 118.6c12.5-12.5 12.5-32.8 0-45.3s-32.8-12.5-45.3 0L192.5 210.7 55.1 73.4z\"/></svg></span>\n"
        str << "                </div>\n"
        str << "              </div>\n"
        str << "              <div class=\"window-body terminal-body\">\n"
        str << "                <pre><code class=\"language-bash\">" << LayoutRenderer.escape(code.strip) << "</code></pre>\n"
        str << "              </div>\n"
        str << "            </div>\n"
      when "asciinema", "cast"
        title = data["title"]?.try(&.as_s) || "Terminal Replay"
        cast_rel = data["cast"]?.try(&.as_s) || ""
        speed = data["speed"]?.try { |v| v.as_f? || v.as_i?.try(&.to_f) } || 1.0_f64
        loop_play = data["loop"]?.try(&.as_bool) != false
        autoplay = data["autoplay"]?.try(&.as_bool) != false
        theme = data["theme"]?.try(&.as_s) || "monokai"
        cols = data["cols"]?.try(&.as_i) || 80
        rows = data["rows"]?.try(&.as_i) || 18

        # Inlining cast data as base64 data URI if file exists locally
        candidates = [
          cast_rel,
          File.expand_path(cast_rel, deck.deck_dir),
          File.expand_path(cast_rel, File.join(deck.deck_dir, "..")),
          File.expand_path(cast_rel, Dir.current),
        ]
        cast_file = candidates.find { |c| File.exists?(c) }

        cast_src = if cast_file
                     content = File.read(cast_file)
                     "data:text/plain;base64,#{Base64.strict_encode(content)}"
                   else
                     cast_rel
                   end

        str << "            <div class=\"terminal-window asciinema-window col\">\n"
        str << "              <div class=\"window-header terminal-header\">\n"
        str << "                <div class=\"terminal-dots\">\n"
        str << "                  <span class=\"terminal-dot dot-1 red\" title=\"Close\"></span>\n"
        str << "                  <span class=\"terminal-dot dot-2 yellow\" title=\"Minimize\"></span>\n"
        str << "                  <span class=\"terminal-dot dot-3 green\" title=\"Maximize\"></span>\n"
        str << "                </div>\n"
        str << "                <span class=\"window-title terminal-title\">" << LayoutRenderer.escape(title) << "</span>\n"
        str << "                <div class=\"window-controls\">\n"
        str << "                  <span class=\"lang-tag code-lang-tag terminal-badge\">REPLAY</span>\n"
        str << "                  <span class=\"window-btn close\" title=\"Close\">✕</span>\n"
        str << "                </div>\n"
        str << "              </div>\n"
        str << "              <div class=\"window-body asciinema-body\">\n"
        str << "                <div class=\"asciinema-player-mount\" data-cast-url=\"" << LayoutRenderer.escape(cast_rel) << "\" data-cast-src=\"" << LayoutRenderer.escape(cast_src) << "\""
        str << " data-speed=\"" << speed << "\" data-loop=\"" << loop_play << "\" data-autoplay=\"" << autoplay << "\""
        str << " data-theme=\"" << LayoutRenderer.escape(theme) << "\" data-cols=\"" << cols << "\" data-rows=\"" << rows << "\"></div>\n"
        str << "              </div>\n"
        str << "            </div>\n"
      when "chart", "svg_chart"
        title = data["title"]?.try(&.as_s) || "Performance Chart"
        badge = data["badge"]?.try(&.as_s)
        color = data["color"]?.try(&.as_s) || "#38bdf8"
        chart_svg = Sunstone::Chart.from_yaml(data, color) || ""

        str << "            <div class=\"card chart-card col\">\n"
        str << "              <div class=\"card-header\">\n"
        str << "                <span class=\"card-title\">" << LayoutRenderer.tint_emojis(LayoutRenderer.escape(title)) << "</span>\n"
        if badge
          str << "                <span class=\"badge\">" << LayoutRenderer.escape(badge) << "</span>\n"
        end
        str << "              </div>\n"
        str << "              <div class=\"chart-container\">\n"
        str << "                " << chart_svg << "\n"
        str << "              </div>\n"
        str << "            </div>\n"
      when "barchart"
        str << render_barchart(data)
      when "image"
        src = data["src"]?.try(&.as_s) || ""
        alt = data["alt"]?.try(&.as_s) || "Slide Image"
        str << "            <div class=\"card image-card\">\n"
        str << "              <img src=\"" << LayoutRenderer.escape(src) << "\" alt=\"" << LayoutRenderer.escape(alt) << "\" class=\"slide-img\">\n"
        str << "            </div>\n"
      else
        title = data["title"]?.try(&.as_s) || ""
        color = data["color"]?.try(&.as_s) || "accent"
        badge = data["badge"]?.try(&.as_s)
        items = Array(String).new
        if raw_items = data["items"]?.try(&.as_a)
          raw_items.each { |it| items << LayoutRenderer.extract_item_text(it) }
        end
        compact = data["compact"]?.try(&.as_bool) || (items.size >= 5)
        str << render_card(title, color, items, badge, compact: compact) << "\n"
      end
    end

    def render_markdown(slide : Slide, deck : Deck, palette : Palette, slide_num : Int32, total_slides : Int32) : String
      left_data = slide.raw["left"]?
      right_data = slide.raw["right"]?

      String.build do |str|
        str << "### Slide " << slide_num << ": " << slide.title << "\n"
        str << "- **Theme Palette**: `" << palette.id << "` (" << palette.name << ")\n"
        str << "- **Badge**: `" << slide.badge << "`\n"
        str << "- **Title**: " << slide.title << "\n"
        unless slide.subtitle.strip.empty?
          str << "- **Subtitle**: " << slide.subtitle << "\n"
        end

        [left_data, right_data].compact.each do |col|
          items = col.as_a? || [col]
          items.each do |it|
            t = it["type"]?.try(&.as_s) || "card"
            case t
            when "code"
              str << "- **Code (" << (it["title"]?.try(&.as_s) || "Snippet") << ")**:\n"
              str << "  ```" << (it["lang"]?.try(&.as_s) || "crystal") << "\n"
              str << "  " << (it["code"]?.try(&.as_s) || "").strip.gsub("\n", "\n  ") << "\n"
              str << "  ```\n"
            when "terminal"
              str << "- **Terminal (" << (it["title"]?.try(&.as_s) || "Console") << ")**:\n"
              str << "  ```bash\n  " << (it["code"]?.try(&.as_s) || "").strip.gsub("\n", "\n  ") << "\n  ```\n"
            else
              card_title = it["title"]?.try(&.as_s) || "Details"
              str << "- **" << card_title << "**:\n"
              if c_items = it["items"]?.try(&.as_a)
                c_items.each do |c_it|
                  str << "  - " << LayoutRenderer.clean_text(LayoutRenderer.extract_item_text(c_it)) << "\n"
                end
              end
            end
          end
        end

        if !slide.notes.strip.empty?
          str << "\n**Presenter Notes**:\n> " << slide.notes.strip.gsub("\n", "\n> ") << "\n"
        end
        str << "\n---\n\n"
      end
    end
  end
end
