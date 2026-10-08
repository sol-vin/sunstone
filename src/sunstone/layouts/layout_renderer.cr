require "html"
require "base64"
require "../models/slide"
require "../models/deck"
require "../models/palette"
require "../icon_registry"
require "../chart"

module Sunstone
  abstract class LayoutRenderer
    abstract def render_html(slide : Slide, deck : Deck, palette : Palette, slide_num : Int32, total_slides : Int32) : String
    abstract def render_markdown(slide : Slide, deck : Deck, palette : Palette, slide_num : Int32, total_slides : Int32) : String

    # Default slide count is 1; 2-step layouts can override to 2
    def slide_count(slide : Slide) : Int32
      1
    end

    def render_html_all(slide : Slide, deck : Deck, palette : Palette, slide_num : Int32, total_slides : Int32) : String
      render_html(slide, deck, palette, slide_num, total_slides)
    end

    def render_markdown_all(slide : Slide, deck : Deck, palette : Palette, slide_num : Int32, total_slides : Int32) : String
      render_markdown(slide, deck, palette, slide_num, total_slides)
    end

    # Shared text and icon helpers
    def self.escape(text : String) : String
      HTML.escape(text)
    end

    def self.render_icon(name : String, extra_class : String = "") : String
      IconRegistry.render(name, extra_class)
    end

    def self.tint_emojis(text : String) : String
      IconRegistry.replace_icons(text)
    end

    def self.extract_item_text(node : YAML::Any) : String
      if h = node.as_h?
        h.map { |k, v| "#{k} #{v}" }.join(" ")
      else
        node.as_s? || node.to_s
      end
    end

    def self.clean_text(html : String) : String
      html.gsub(/<[^>]+>/, "")
          .gsub("&amp;", "&")
          .gsub("&lt;", "<")
          .gsub("&gt;", ">")
          .gsub("&quot;", "\"")
          .gsub("&#123;", "{")
          .gsub("&#125;", "}")
          .gsub("&mdash;", "—")
          .strip
    end

    def format_footer_template(template : String, slide : Slide, deck : Deck, palette : Palette, slide_num : Int32, total_slides : Int32) : String
      template
        .gsub("{title}", deck.title)
        .gsub("{subtitle}", deck.subtitle)
        .gsub("{author}", deck.author)
        .gsub("{palette}", palette.name)
        .gsub("{palette_id}", palette.id)
        .gsub("{slide_num}", slide_num.to_s)
        .gsub("{total_slides}", total_slides.to_s)
        .gsub("{slide_title}", slide.title)
    end

    # Strictly Semantic Section Wrapper with ZERO Inline Styles
    def render_section_wrapper(slide : Slide, deck : Deck, palette : Palette, slide_num : Int32, total_slides : Int32, inner_body : String, custom_notes : String? = nil) : String
      footer_left = format_footer_template(deck.footer_left, slide, deck, palette, slide_num, total_slides)
      footer_center = format_footer_template(deck.footer_center, slide, deck, palette, slide_num, total_slides)
      footer_right = format_footer_template(deck.footer_right, slide, deck, palette, slide_num, total_slides)
      notes_to_show = custom_notes || slide.notes

      String.build do |str|
        str << "      <!-- Slide " << slide_num << ": " << palette.name << " (" << slide.title << ") -->\n"
        str << "      <section class=\"slide solvin-slide " << palette.id << "\" data-layout=\"" << slide.layout << "\" data-palette=\"" << palette.id << "\" data-background-color=\"" << palette.bg_color << "\" data-palette-name=\"" << HTML.escape(palette.name) << "\" data-palette-cube=\"" << palette.cube << "\" data-palette-cube-hover=\"" << palette.cube_hover << "\" data-slide-id=\"" << slide.id << "\" id=\"slide-" << slide.id << "\">\n"
        str << "        <div class=\"palette-corner-badge\" title=\"Theme: " << HTML.escape(palette.name) << "\">\n"
        str << "          <span class=\"palette-corner-dot\"></span> PALETTE: " << HTML.escape(palette.name) << "\n"
        str << "        </div>\n"
        str << "        <div class=\"slide-container\">\n"
        str << inner_body << "\n"
        str << "          <footer class=\"slide-footer\">\n"
        str << "            <span class=\"footer-left\">" << LayoutRenderer.tint_emojis(HTML.escape(footer_left)) << "</span>\n"
        str << "            <span class=\"footer-center\">" << LayoutRenderer.tint_emojis(HTML.escape(footer_center)) << "</span>\n"
        str << "            <span class=\"footer-right\">" << HTML.escape(footer_right) << "</span>\n"
        str << "          </footer>\n"
        str << "        </div>\n"
        if !notes_to_show.strip.empty?
          str << "        <aside class=\"notes\">\n"
          str << "          " << notes_to_show.strip.gsub("\n", "\n          ") << "\n"
          str << "        </aside>\n"
        end
        str << "      </section>"
      end
    end

    # Semantic Slide Header with ZERO Inline Styles
    def render_slide_header(slide : Slide, right_element : String? = nil) : String
      split_attr = right_element ? " data-align=\"split\"" : ""
      badge_color = slide.badge_color.empty? ? "accent" : slide.badge_color
      String.build do |str|
        str << "          <header class=\"slide-header\"" << split_attr << ">\n"
        str << "            <div class=\"slide-meta\">\n"
        str << "              <span class=\"badge badge-pill " << badge_color << "\" data-color=\"" << badge_color << "\">" << LayoutRenderer.tint_emojis(HTML.escape(slide.badge)) << "</span>\n"
        if right_element
          str << "              " << right_element << "\n"
        end
        str << "            </div>\n"
        str << "            <h2 class=\"slide-title\">" << LayoutRenderer.tint_emojis(HTML.escape(slide.title)) << "</h2>\n"
        unless slide.subtitle.strip.empty?
          str << "            <p class=\"slide-subtitle\">" << LayoutRenderer.tint_emojis(HTML.escape(slide.subtitle)) << "</p>\n"
        end
        str << "          </header>"
      end
    end

    # Semantic Code Container with Window Header (dots and window controls)
    def render_code_container(title : String, lang : String, code : String, tag : String? = nil, density : String? = nil) : String
      line_count = code.strip.lines.size
      effective_density = density || (line_count >= 16 ? "compact" : nil)
      density_attr = effective_density ? " data-density=\"#{effective_density}\"" : ""
      density_cls = case effective_density
                    when "compact" then " code-compact"
                    when "dense" then " code-dense"
                    else ""
                    end
      lang_display = tag || lang.upcase
      String.build do |str|
        str << "            <div class=\"code-window code-container col" << density_cls << "\" data-lang=\"" << lang.downcase << "\"" << density_attr << ">\n"
        str << "              <div class=\"window-header code-header\">\n"
        str << "                <div class=\"terminal-dots\">\n"
        str << "                  <span class=\"terminal-dot dot-1 red\" title=\"Close\"></span>\n"
        str << "                  <span class=\"terminal-dot dot-2 yellow\" title=\"Minimize\"></span>\n"
        str << "                  <span class=\"terminal-dot dot-3 green\" title=\"Maximize\"></span>\n"
        str << "                </div>\n"
        str << "                <span class=\"window-title code-title\">" << LayoutRenderer.tint_emojis(HTML.escape(title)) << "</span>\n"
        str << "                <div class=\"window-controls\">\n"
        str << "                  <span class=\"lang-tag code-lang-tag\">" << HTML.escape(lang_display) << "</span>\n"
        str << "                  <span class=\"window-btn close\" title=\"Close\"><svg class=\"fa-icon fa-xmark\" viewBox=\"0 0 384 512\" aria-hidden=\"true\"><path fill=\"currentColor\" d=\"M55.1 73.4c-12.5-12.5-32.8-12.5-45.3 0s-12.5 32.8 0 45.3L147.2 256 9.9 393.4c-12.5 12.5-12.5 32.8 0 45.3s32.8 12.5 45.3 0L192.5 301.3 329.9 438.6c12.5 12.5 32.8 12.5 45.3 0s12.5-32.8 0-45.3L237.8 256 375.1 118.6c12.5-12.5 12.5-32.8 0-45.3s-32.8-12.5-45.3 0L192.5 210.7 55.1 73.4z\"/></svg></span>\n"
        str << "                </div>\n"
        str << "              </div>\n"
        str << "              <pre><code class=\"language-" << lang.downcase << density_cls << "\">" << HTML.escape(code.strip) << "</code></pre>\n"
        str << "            </div>"
      end
    end

    # Semantic Card with ZERO Inline Styles
    def render_card(title : String, color : String, items : Array(String), badge : String? = nil, compact : Bool = false) : String
      is_compact = compact || items.size >= 5
      compact_attr = is_compact ? " data-density=\"compact\"" : ""
      compact_cls = is_compact ? " compact" : ""
      String.build do |str|
        str << "            <div class=\"card col " << color << compact_cls << "\" data-color=\"" << color << "\"" << compact_attr << ">\n"
        str << "              <div class=\"card-header card-title " << color << "\">\n"
        str << "                <span>" << LayoutRenderer.tint_emojis(HTML.escape(title)) << "</span>\n"
        if badge
          str << "                <span class=\"badge " << color << "\" data-color=\"" << color << "\">" << HTML.escape(badge) << "</span>\n"
        end
        str << "              </div>\n"
        str << "              <ul class=\"card-list\">\n"
        items.each do |item|
          str << "                <li>" << LayoutRenderer.tint_emojis(item) << "</li>\n"
        end
        str << "              </ul>\n"
        str << "            </div>"
      end
    end

    def render_column_content(str : String::Builder, data : YAML::Any, slide : Slide)
      if data.as_a?
        data.as_a.each { |item| render_slot_item(str, item, slide) }
      else
        render_slot_item(str, data, slide)
      end
    end

    def render_slot_item(str : String::Builder, data : YAML::Any, slide : Slide)
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

        cast_file = if File.exists?(cast_rel)
                      cast_rel
                    elsif File.exists?(File.expand_path(cast_rel, Dir.current))
                      File.expand_path(cast_rel, Dir.current)
                    else
                      nil
                    end

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
      when "image"
        src = data["src"]?.try(&.as_s) || ""
        alt = data["alt"]?.try(&.as_s) || "Slide Image"
        str << "            <div class=\"card image-card col\">\n"
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
  end
end
