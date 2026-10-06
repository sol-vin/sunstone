require "./layout_renderer"

module Sunstone
  class ClosingLayout < LayoutRenderer
    def render_html(slide : Slide, deck : Deck, palette : Palette, slide_num : Int32, total_slides : Int32) : String
      cards = slide.raw["cards"]?.try(&.as_a)
      quickstart = slide.raw["quickstart"]?.try(&.as_s)
      signature = slide.raw["signature"]?.try(&.as_s)
      cube_size = slide.raw["cube_size"]?.try(&.as_i) || 280

      body = String.build do |str|
        if deck.header_cube
          str << "          <div class=\"hero-cube closing-cube\" data-size=\"" << cube_size << "\"></div>\n"
        end

        str << render_slide_header(slide) << "\n"
        str << "          <div class=\"slide-body\" data-layout=\"closing\">\n"

        if cards
          str << "            <div class=\"closing-cards-grid\">\n"
          cards.each do |c|
            title = c["title"]?.try(&.as_s) || ""
            badge = c["badge"]?.try(&.as_s) || ""
            icon = c["icon"]?.try(&.as_s) || "star"
            color = c["color"]?.try(&.as_s) || "accent"
            link = c["link"]?.try(&.as_s) || ""
            desc = c["desc"]?.try(&.as_s) || ""

            str << "              <div class=\"card closing-card\" data-color=\"" << color << "\">\n"
            str << "                <div class=\"card-header\">\n"
            str << "                  <span class=\"card-title\"><span class=\"closing-icon\">" << LayoutRenderer.render_icon(icon) << "</span> " << LayoutRenderer.tint_emojis(HTML.escape(title)) << "</span>\n"
            if !badge.empty?
              str << "                  <span class=\"badge\" data-color=\"" << color << "\">" << HTML.escape(badge) << "</span>\n"
            end
            str << "                </div>\n"

            if !link.empty?
              str << "                <div class=\"closing-link\"><code>" << HTML.escape(link) << "</code></div>\n"
            end
            if !desc.empty?
              str << "                <div class=\"closing-desc\">" << LayoutRenderer.tint_emojis(desc) << "</div>\n"
            end
            str << "              </div>\n"
          end
          str << "            </div>\n"
        end

        if quickstart
          str << "            <div class=\"terminal-window closing-quickstart-bar\" data-density=\"compact\">\n"
          str << "              <div class=\"window-header\">\n"
          str << "                <span class=\"window-title\">Get Started</span>\n"
          str << "                <span class=\"lang-tag\">TERMINAL</span>\n"
          str << "              </div>\n"
          str << "              <div class=\"window-body\"><pre><code class=\"language-bash\">" << HTML.escape(quickstart.strip) << "</code></pre></div>\n"
          str << "            </div>\n"
        end

        if signature
          str << "            <div class=\"closing-signature\">" << LayoutRenderer.tint_emojis(signature) << "</div>\n"
        end

        str << "          </div>"
      end

      render_section_wrapper(slide, deck, palette, slide_num, total_slides, body)
    end

    def render_markdown(slide : Slide, deck : Deck, palette : Palette, slide_num : Int32, total_slides : Int32) : String
      cards = slide.raw["cards"]?.try(&.as_a)
      quickstart = slide.raw["quickstart"]?.try(&.as_s)

      String.build do |str|
        str << "### Slide " << slide_num << ": " << slide.title << " [Closing]\n"
        if cards
          cards.each do |c|
            str << "- **" << (c["title"]?.try(&.as_s) || "Link") << "**: " << (c["desc"]?.try(&.as_s) || "") << "\n"
            if link = c["link"]?.try(&.as_s)
              str << "  - `" << link << "`\n"
            end
          end
        end
        if quickstart
          str << "- **Quickstart**:\n  ```bash\n  " << quickstart.strip.gsub("\n", "\n  ") << "\n  ```\n"
        end
        if !slide.notes.strip.empty?
          str << "\n**Presenter Notes**:\n> " << slide.notes.strip.gsub("\n", "\n> ") << "\n"
        end
        str << "\n---\n\n"
      end
    end
  end
end
