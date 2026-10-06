require "./layout_renderer"

module Sunstone
  class DualModeLayout < LayoutRenderer
    def render_html(slide : Slide, deck : Deck, palette : Palette, slide_num : Int32, total_slides : Int32) : String
      modes = slide.raw["modes"]?.try(&.as_a)
      banner = slide.raw["banner"]?.try(&.as_s)
      summary = slide.raw["summary"]?.try(&.as_s)

      body = String.build do |str|
        str << render_slide_header(slide) << "\n"
        str << "          <div class=\"slide-body\" data-layout=\"dual-mode\">\n"

        if banner
          str << "            <div class=\"dual-mode-banner\">\n"
          str << "              <span class=\"banner-icon\">" << LayoutRenderer.render_icon("bolt") << "</span>\n"
          str << "              <span class=\"banner-text\">" << LayoutRenderer.tint_emojis(banner) << "</span>\n"
          str << "            </div>\n"
        end

        if modes
          str << "            <div class=\"dual-mode-grid\">\n"
          modes.each do |m|
            title = m["title"]?.try(&.as_s) || ""
            badge = m["badge"]?.try(&.as_s) || ""
            flow = m["flow"]?.try(&.as_s) || ""
            color = m["color"]?.try(&.as_s) || "accent"
            desc = m["desc"]?.try(&.as_s) || ""

            str << "              <div class=\"card dual-mode-card\" data-color=\"" << color << "\">\n"
            str << "                <div class=\"card-header\">\n"
            str << "                  <span class=\"card-title\">" << LayoutRenderer.tint_emojis(HTML.escape(title)) << "</span>\n"
            if !badge.empty?
              str << "                  <span class=\"badge\" data-color=\"" << color << "\">" << HTML.escape(badge) << "</span>\n"
            end
            str << "                </div>\n"

            if !flow.empty?
              str << "                <div class=\"dual-mode-flow\"><code>" << LayoutRenderer.tint_emojis(flow) << "</code></div>\n"
            end

            if specs = m["specs"]?.try(&.as_a)
              str << "                <div class=\"dual-mode-specs\">\n"
              specs.each do |s|
                label = s["label"]?.try(&.as_s) || ""
                value = s["value"]?.try(&.as_s) || ""
                icon = s["icon"]?.try(&.as_s) || "bullseye"
                str << "                  <div class=\"dual-mode-spec-row\">\n"
                str << "                    <span class=\"spec-label\"><span class=\"spec-icon\">" << LayoutRenderer.render_icon(icon) << "</span> " << HTML.escape(label) << "</span>\n"
                str << "                    <span class=\"spec-value\">" << LayoutRenderer.tint_emojis(value) << "</span>\n"
                str << "                  </div>\n"
              end
              str << "                </div>\n"
            end

            if !desc.empty?
              str << "                <div class=\"dual-mode-desc\">" << LayoutRenderer.tint_emojis(desc) << "</div>\n"
            end

            str << "              </div>\n"
          end
          str << "            </div>\n"
        end

        if summary
          str << "            <div class=\"takeaway-banner\">\n"
          str << "              <span class=\"badge\" data-color=\"accent\">SUMMARY</span>\n"
          str << "              <span class=\"takeaway-text\">" << LayoutRenderer.tint_emojis(summary) << "</span>\n"
          str << "            </div>\n"
        end

        str << "          </div>"
      end

      render_section_wrapper(slide, deck, palette, slide_num, total_slides, body)
    end

    def render_markdown(slide : Slide, deck : Deck, palette : Palette, slide_num : Int32, total_slides : Int32) : String
      modes = slide.raw["modes"]?.try(&.as_a)
      String.build do |str|
        str << "### Slide " << slide_num << ": " << slide.title << " [Dual-Mode]\n"
        if banner = slide.raw["banner"]?.try(&.as_s)
          str << "**Overview**: " << LayoutRenderer.clean_text(banner) << "\n\n"
        end
        if modes
          modes.each do |m|
            str << "- **" << (m["title"]?.try(&.as_s) || "Mode") << "**:\n"
            if flow = m["flow"]?.try(&.as_s)
              str << "  - *Flow*: `" << flow << "`\n"
            end
            if specs = m["specs"]?.try(&.as_a)
              specs.each do |s|
                str << "  - " << (s["label"]?.try(&.as_s) || "") << ": " << (s["value"]?.try(&.as_s) || "") << "\n"
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
