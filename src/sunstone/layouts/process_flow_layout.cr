require "./layout_renderer"

module Sunstone
  class ProcessFlowLayout < LayoutRenderer
    def render_html(slide : Slide, deck : Deck, palette : Palette, slide_num : Int32, total_slides : Int32) : String
      steps = slide.raw["steps"]?.try(&.as_a) || slide.raw["pipeline"]?.try(&.as_a) || slide.raw["cards"]?.try(&.as_a)

      body = String.build do |str|
        str << render_slide_header(slide) << "\n"
        str << "          <div class=\"slide-body\" data-layout=\"process-flow\">\n"

        if steps && !steps.empty?
          step_count = steps.size.to_s
          str << "            <div class=\"process-pipeline\" data-steps=\"" << step_count << "\">\n"
          steps.each_with_index do |s, idx|
            step_num = s["step"]?.try(&.as_s) || (idx + 1 < 10 ? "0#{idx + 1}" : (idx + 1).to_s)
            title = s["title"]?.try(&.as_s) || ""
            badge = s["badge"]?.try(&.as_s)
            color = s["color"]?.try(&.as_s) || "accent"
            desc = s["desc"]?.try(&.as_s) || s["description"]?.try(&.as_s)
            items = s["items"]?.try(&.as_a)
            icon = s["icon"]?.try(&.as_s)

            str << "              <div class=\"card process-step-card col " << color << "\" data-color=\"" << color << "\">\n"
            str << "                <div class=\"card-header\">\n"
            str << "                  <span class=\"process-step-badge " << color << "\">" << HTML.escape(step_num) << "</span>\n"
            if badge
              str << "                  <span class=\"badge " << color << "\" data-color=\"" << color << "\">" << HTML.escape(badge) << "</span>\n"
            end
            str << "                </div>\n"

            str << "                <div class=\"process-step-title\">"
            if icon
              str << "<span class=\"step-icon\">" << LayoutRenderer.render_icon(icon) << "</span> "
            end
            str << LayoutRenderer.tint_emojis(HTML.escape(title)) << "</div>\n"

            if desc
              str << "                <div class=\"process-step-desc\">" << LayoutRenderer.tint_emojis(HTML.escape(desc)) << "</div>\n"
            end

            if items
              str << "                <ul class=\"card-list\">\n"
              items.each do |it|
                str << "                  <li>" << LayoutRenderer.tint_emojis(LayoutRenderer.extract_item_text(it)) << "</li>\n"
              end
              str << "                </ul>\n"
            end

            str << "              </div>\n"
          end
          str << "            </div>\n"
        end

        str << "          </div>"
      end

      render_section_wrapper(slide, deck, palette, slide_num, total_slides, body)
    end

    def render_markdown(slide : Slide, deck : Deck, palette : Palette, slide_num : Int32, total_slides : Int32) : String
      steps = slide.raw["steps"]?.try(&.as_a) || slide.raw["pipeline"]?.try(&.as_a) || slide.raw["cards"]?.try(&.as_a)

      String.build do |str|
        str << "### Slide " << slide_num << ": " << slide.title << " [Process Flow / Pipeline]\n"
        if steps && !steps.empty?
          steps.each_with_index do |s, idx|
            step_num = s["step"]?.try(&.as_s) || (idx + 1).to_s
            title = s["title"]?.try(&.as_s) || ""
            desc = s["desc"]?.try(&.as_s)
            str << step_num << ". **" << title << "**"
            str << ": " << desc if desc
            str << "\n"
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
