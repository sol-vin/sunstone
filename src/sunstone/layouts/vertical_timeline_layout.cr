require "./layout_renderer"

module Sunstone
  class VerticalTimelineLayout < LayoutRenderer
    def render_html(slide : Slide, deck : Deck, palette : Palette, slide_num : Int32, total_slides : Int32) : String
      events = slide.raw["events"]?.try(&.as_a) || slide.raw["milestones"]?.try(&.as_a) || slide.raw["cards"]?.try(&.as_a)

      body = String.build do |str|
        str << render_slide_header(slide) << "\n"
        str << "          <div class=\"slide-body layout-vertical-timeline\" data-layout=\"vertical-timeline\">\n"
        str << "            <div class=\"vtimeline-container\">\n"

        if events && !events.empty?
          events.each_with_index do |ev, idx|
            date_label = ev["date"]?.try(&.as_s) || ev["time"]?.try(&.as_s) || ev["version"]?.try(&.as_s) || ev["year"]?.try(&.as_s) || "STEP #{idx + 1}"
            title = ev["title"]?.try(&.as_s) || "Milestone"
            status = ev["status"]?.try(&.as_s) || (idx == 0 ? "done" : (idx == 1 ? "active" : "pending"))
            color = ev["color"]?.try(&.as_s) || (status == "done" ? "emerald" : (status == "active" ? "accent" : "amber"))
            badge = ev["badge"]?.try(&.as_s) || status.upcase
            desc = ev["desc"]?.try(&.as_s) || ev["description"]?.try(&.as_s)
            raw_items = ev["items"]?.try(&.as_a)

            str << "              <div class=\"vtimeline-item\" data-status=\"" << status << "\" data-color=\"" << color << "\">\n"
            str << "                <div class=\"vtimeline-time-col\">\n"
            str << "                  <span class=\"vtimeline-time-pill " << color << "\">" << LayoutRenderer.tint_emojis(HTML.escape(date_label)) << "</span>\n"
            str << "                </div>\n"
            str << "                <div class=\"vtimeline-spine\">\n"
            str << "                  <span class=\"vtimeline-dot " << color << "\" data-status=\"" << status << "\"></span>\n"
            str << "                  <span class=\"vtimeline-line\"></span>\n"
            str << "                </div>\n"
            str << "                <div class=\"card vtimeline-card col " << color << "\" data-color=\"" << color << "\">\n"
            str << "                  <div class=\"card-header\">\n"
            str << "                    <span class=\"card-title\">" << LayoutRenderer.tint_emojis(HTML.escape(title)) << "</span>\n"
            str << "                    <span class=\"badge " << color << "\" data-color=\"" << color << "\">" << HTML.escape(badge) << "</span>\n"
            str << "                  </div>\n"
            if desc
              str << "                  <p class=\"vtimeline-desc\">" << LayoutRenderer.tint_emojis(HTML.escape(desc)) << "</p>\n"
            end
            if raw_items
              str << "                  <ul class=\"card-list\">\n"
              raw_items.each do |it|
                str << "                    <li>" << LayoutRenderer.tint_emojis(LayoutRenderer.extract_item_text(it)) << "</li>\n"
              end
              str << "                  </ul>\n"
            end
            str << "                </div>\n"
            str << "              </div>\n"
          end
        end

        str << "            </div>\n"
        str << "          </div>"
      end

      render_section_wrapper(slide, deck, palette, slide_num, total_slides, body)
    end

    def render_markdown(slide : Slide, deck : Deck, palette : Palette, slide_num : Int32, total_slides : Int32) : String
      events = slide.raw["events"]?.try(&.as_a) || slide.raw["milestones"]?.try(&.as_a) || slide.raw["cards"]?.try(&.as_a)

      String.build do |str|
        str << "### Slide " << slide_num << ": " << slide.title << " [Vertical Timeline]\n"
        str << "- **Theme Palette**: `" << palette.id << "` (" << palette.name << ")\n"
        str << "- **Title**: " << slide.title << "\n\n"

        if events && !events.empty?
          events.each do |ev|
            date_label = ev["date"]?.try(&.as_s) || ev["version"]?.try(&.as_s) || "Milestone"
            title = ev["title"]?.try(&.as_s) || ""
            status = ev["status"]?.try(&.as_s) || "status"
            str << "- **" << date_label << " [" << status.upcase << "] — " << title << "**\n"
            if desc = ev["desc"]?.try(&.as_s)
              str << "  " << desc << "\n"
            end
            if items = ev["items"]?.try(&.as_a)
              items.each { |it| str << "  - " << LayoutRenderer.clean_text(LayoutRenderer.extract_item_text(it)) << "\n" }
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
