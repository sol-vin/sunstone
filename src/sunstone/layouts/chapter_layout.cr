require "./layout_renderer"

module Sunstone
  class ChapterLayout < LayoutRenderer
    def render_html(slide : Slide, deck : Deck, palette : Palette, slide_num : Int32, total_slides : Int32) : String
      act_label = slide.raw["act"]?.try(&.as_s) || slide.raw["chapter"]?.try(&.as_s) || slide.badge
      cube_size = slide.raw["cube_size"]?.try(&.as_i) || 160
      pillars = slide.raw["pillars"]?.try(&.as_a)

      body = String.build do |str|
        str << "          <div class=\"chapter-content\">\n"
        str << "            <div class=\"chapter-top\">\n"
        if !act_label.strip.empty?
          str << "              <span class=\"badge\" data-color=\"" << slide.badge_color << "\">" << LayoutRenderer.tint_emojis(HTML.escape(act_label)) << "</span>\n"
        end
        str << "              <h1 class=\"chapter-title\">" << LayoutRenderer.tint_emojis(HTML.escape(slide.title)) << "</h1>\n"
        if !slide.subtitle.strip.empty?
          str << "              <p class=\"chapter-subtitle\">" << LayoutRenderer.tint_emojis(HTML.escape(slide.subtitle)) << "</p>\n"
        end
        str << "            </div>\n"

        if deck.header_cube
          str << "            <div class=\"chapter-cube-wrap\"><div class=\"hero-cube chapter-cube\" data-size=\"" << cube_size << "\"></div></div>\n"
        end

        if pillars && !pillars.empty?
          str << "            <div class=\"chapter-pillars-row\">\n"
          pillars.each do |p|
            if h = p.as_h?
              p_title = h["title"]?.try(&.as_s) || ""
              p_desc = h["desc"]?.try(&.as_s) || ""
              p_icon = h["icon"]?.try(&.as_s) || "sparkles"
              p_color = h["color"]?.try(&.as_s) || "accent"

              str << "              <div class=\"chapter-pillar-card\" data-color=\"" << p_color << "\">\n"
              str << "                <div class=\"chapter-pillar-header\">\n"
              str << "                  <span class=\"chapter-pillar-icon\">" << LayoutRenderer.render_icon(p_icon) << "</span>\n"
              str << "                  <span class=\"chapter-pillar-title\">" << LayoutRenderer.tint_emojis(HTML.escape(p_title)) << "</span>\n"
              str << "                </div>\n"
              if !p_desc.empty?
                str << "                <div class=\"chapter-pillar-desc\">" << LayoutRenderer.tint_emojis(p_desc) << "</div>\n"
              end
              str << "              </div>\n"
            else
              str << "              <div class=\"chapter-pillar-card\"><span class=\"chapter-pillar-title\">" << LayoutRenderer.tint_emojis(p.as_s) << "</span></div>\n"
            end
          end
          str << "            </div>\n"
        end

        str << "          </div>"
      end

      render_section_wrapper(slide, deck, palette, slide_num, total_slides, body)
    end

    def render_markdown(slide : Slide, deck : Deck, palette : Palette, slide_num : Int32, total_slides : Int32) : String
      act_label = slide.raw["act"]?.try(&.as_s) || slide.raw["chapter"]?.try(&.as_s) || slide.badge
      pillars = slide.raw["pillars"]?.try(&.as_a)

      String.build do |str|
        str << "### Slide " << slide_num << ": " << slide.title << " (" << act_label << ")\n"
        str << "- **Title**: " << slide.title << "\n"
        unless slide.subtitle.strip.empty?
          str << "- **Subtitle**: " << slide.subtitle << "\n"
        end
        if pillars && !pillars.empty?
          str << "- **Chapter Highlights**:\n"
          pillars.each do |p|
            if h = p.as_h?
              str << "  - **" << LayoutRenderer.clean_text(h["title"]?.try(&.as_s) || "") << "**: " << LayoutRenderer.clean_text(h["desc"]?.try(&.as_s) || "") << "\n"
            else
              str << "  - " << LayoutRenderer.clean_text(p.as_s) << "\n"
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
