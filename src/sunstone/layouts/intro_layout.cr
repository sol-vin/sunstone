require "./layout_renderer"

module Sunstone
  class IntroLayout < LayoutRenderer
    def render_html(slide : Slide, deck : Deck, palette : Palette, slide_num : Int32, total_slides : Int32) : String
      author_name = slide.raw["author"]?.try(&.as_s) || deck.author
      author_role = slide.raw["author_role"]?.try(&.as_s) || ""
      pills = slide.raw["pills"]?.try(&.as_a)
      cube_size = slide.raw["cube_size"]?.try(&.as_i) || 280

      body = String.build do |str|
        has_cube = deck.theme.downcase.includes?("sol.vin") || deck.header_cube

        if has_cube
          str << "          <div class=\"hero-cube intro-cube\" data-size=\"" << cube_size << "\" title=\"Spinning 3D Isometric Cube • Click or Drag to Spin!\"></div>\n"
        end

        str << "          <div class=\"intro-content\">\n"
        str << "            <div class=\"intro-top-block\">\n"
        if !slide.badge.strip.empty?
          str << "              <div class=\"intro-topic-wrap\">\n"
          str << "                <span class=\"badge badge-pill " << slide.badge_color << " intro-topic-badge\" data-color=\"" << slide.badge_color << "\">" << LayoutRenderer.tint_emojis(HTML.escape(slide.badge)) << "</span>\n"
          str << "              </div>\n"
        end
        str << "              <h1 class=\"slide-title intro-title\">" << LayoutRenderer.tint_emojis(HTML.escape(slide.title)) << "</h1>\n"
        if !slide.subtitle.strip.empty?
          str << "              <p class=\"slide-subtitle intro-subtitle\">" << LayoutRenderer.tint_emojis(HTML.escape(slide.subtitle)) << "</p>\n"
        end
        str << "            </div>\n"

        if has_cube
          str << "            <div class=\"intro-cube-spacer\" data-spacer-height=\"" << cube_size << "\"></div>\n"
        elsif pills && !pills.empty?
          str << "            <div class=\"intro-middle-block\">\n"
          str << "              <div class=\"intro-pills-row\">\n"
          pills.each do |p|
            str << "                <span class=\"intro-pill\">" << LayoutRenderer.tint_emojis(p.as_s) << "</span>\n"
          end
          str << "              </div>\n"
          str << "            </div>\n"
        end

        str << "            <div class=\"intro-bottom-block\">\n"
        if !author_name.strip.empty?
          author_alias = slide.raw["author_alias"]?.try(&.as_s)
          str << "              <div class=\"intro-author-wrap\">\n"
          str << "                <div class=\"intro-author-name\">" << HTML.escape(author_name)
          if author_alias && !author_alias.strip.empty?
            str << " <span class=\"intro-author-alias\">(" << HTML.escape(author_alias) << ")</span>"
          end
          str << "</div>\n"
          if !author_role.strip.empty?
            str << "                <div class=\"intro-author-role\">" << LayoutRenderer.tint_emojis(HTML.escape(author_role)) << "</div>\n"
          end
          str << "              </div>\n"
        end

        if has_cube && pills && !pills.empty?
          str << "              <div class=\"intro-pills-row\">\n"
          pills.each do |p|
            str << "                <span class=\"intro-pill\">" << LayoutRenderer.tint_emojis(p.as_s) << "</span>\n"
          end
          str << "              </div>\n"
        end
        str << "            </div>\n"
        str << "          </div>"
      end

      render_section_wrapper(slide, deck, palette, slide_num, total_slides, body)
    end

    def render_markdown(slide : Slide, deck : Deck, palette : Palette, slide_num : Int32, total_slides : Int32) : String
      author_name = slide.raw["author"]?.try(&.as_s) || deck.author
      pills = slide.raw["pills"]?.try(&.as_a)

      String.build do |str|
        str << "### Slide " << slide_num << ": " << slide.title << " [Cover]\n"
        str << "- **Title**: " << slide.title << "\n"
        str << "- **Subtitle**: " << slide.subtitle << "\n"
        str << "- **Author**: " << author_name << "\n"
        if pills && !pills.empty?
          str << "- **Highlights**:\n"
          pills.each { |p| str << "  - " << LayoutRenderer.clean_text(p.as_s) << "\n" }
        end
        if !slide.notes.strip.empty?
          str << "\n**Presenter Notes**:\n> " << slide.notes.strip.gsub("\n", "\n> ") << "\n"
        end
        str << "\n---\n\n"
      end
    end
  end
end
