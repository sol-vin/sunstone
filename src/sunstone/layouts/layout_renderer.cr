require "html"
require "../models/slide"
require "../models/deck"
require "../models/palette"
require "../icon_registry"

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
        str << "      <section class=\"slide\" data-layout=\"" << slide.layout << "\" data-palette=\"" << palette.id << "\" data-slide-id=\"" << slide.id << "\" id=\"slide-" << slide.id << "\">\n"
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
      String.build do |str|
        str << "          <header class=\"slide-header\"" << split_attr << ">\n"
        str << "            <div class=\"slide-meta\">\n"
        str << "              <span class=\"badge\" data-color=\"" << slide.badge_color << "\">" << LayoutRenderer.tint_emojis(HTML.escape(slide.badge)) << "</span>\n"
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

    # Semantic Code Container with Window Header (dots rendered via CSS ::before)
    def render_code_container(title : String, lang : String, code : String, tag : String? = nil, density : String? = nil) : String
      density_attr = density ? " data-density=\"#{density}\"" : ""
      String.build do |str|
        str << "            <div class=\"code-window\" data-lang=\"" << lang.downcase << "\"" << density_attr << ">\n"
        str << "              <div class=\"window-header\">\n"
        str << "                <span class=\"window-title\">" << LayoutRenderer.tint_emojis(HTML.escape(title)) << "</span>\n"
        str << "                <span class=\"lang-tag\">" << (tag || lang.upcase) << "</span>\n"
        str << "              </div>\n"
        str << "              <pre><code class=\"language-" << lang.downcase << "\">" << HTML.escape(code.strip) << "</code></pre>\n"
        str << "            </div>"
      end
    end

    # Semantic Card with ZERO Inline Styles
    def render_card(title : String, color : String, items : Array(String), badge : String? = nil, compact : Bool = false) : String
      compact_attr = compact ? " data-density=\"compact\"" : ""
      String.build do |str|
        str << "            <div class=\"card\" data-color=\"" << color << "\"" << compact_attr << ">\n"
        str << "              <div class=\"card-header\">\n"
        str << "                <span class=\"card-title\">" << LayoutRenderer.tint_emojis(HTML.escape(title)) << "</span>\n"
        if badge
          str << "                <span class=\"badge\" data-color=\"" << color << "\">" << HTML.escape(badge) << "</span>\n"
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
  end
end
