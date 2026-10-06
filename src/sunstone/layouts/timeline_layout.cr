require "./layout_renderer"

module Sunstone
  class TimelineLayout < LayoutRenderer
    def render_html(slide : Slide, deck : Deck, palette : Palette, slide_num : Int32, total_slides : Int32) : String
      body = String.build do |str|
        str << render_slide_header(slide) << "\n"
        str << "          <div class=\"slide-body timeline-container\" data-layout=\"timeline\">\n"

        if cards = slide.raw["cards"]?.try(&.as_a)
          # Visual Timeline Rail Track with Year Steps
          str << "            <div class=\"timeline-track\">\n"
          cards.each do |c|
            year = c["year"]?.try(&.as_s) || begin
              ph = c["phase"]?.try(&.as_s) || ""
              ph.includes?("•") ? ph.split("•").last.strip : "MILESTONE"
            end
            str << "              <div class=\"timeline-step\">\n"
            str << "                <span class=\"timeline-year\">" << LayoutRenderer.tint_emojis(HTML.escape(year)) << "</span>\n"
            str << "                <span class=\"timeline-dot\"></span>\n"
            str << "              </div>\n"
          end
          str << "            </div>\n"

          # Cards Grid Underneath Track
          str << "            <div class=\"timeline-cards\">\n"
          cards.each do |c|
            title = c["title"]?.try(&.as_s) || ""
            phase = c["phase"]?.try(&.as_s) || ""
            color = c["color"]?.try(&.as_s) || "accent"
            items = Array(String).new
            if raw_items = c["items"]?.try(&.as_a)
              raw_items.each { |it| items << LayoutRenderer.extract_item_text(it) }
            end

            str << "              <div class=\"card timeline-card\" data-color=\"" << color << "\">\n"
            str << "                <div class=\"card-header\">\n"
            str << "                  <span class=\"card-title\">" << LayoutRenderer.tint_emojis(HTML.escape(title)) << "</span>\n"
            if !phase.empty?
              str << "                  <span class=\"badge\" data-color=\"" << color << "\">" << LayoutRenderer.tint_emojis(HTML.escape(phase)) << "</span>\n"
            end
            str << "                </div>\n"
            str << "                <ul class=\"card-list\">\n"
            items.each do |it|
              str << "                  <li>" << LayoutRenderer.tint_emojis(it) << "</li>\n"
            end
            str << "                </ul>\n"
            str << "              </div>\n"
          end
          str << "            </div>\n"
        end

        str << "          </div>"
      end

      render_section_wrapper(slide, deck, palette, slide_num, total_slides, body)
    end

    def render_markdown(slide : Slide, deck : Deck, palette : Palette, slide_num : Int32, total_slides : Int32) : String
      String.build do |str|
        str << "### Slide " << slide_num << ": " << slide.title << " [Timeline]\n"
        if cards = slide.raw["cards"]?.try(&.as_a)
          cards.each do |c|
            year = c["year"]?.try(&.as_s) || c["phase"]?.try(&.as_s) || "Step"
            str << "- **" << year << " — " << (c["title"]?.try(&.as_s) || "") << "**:\n"
            if items = c["items"]?.try(&.as_a)
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
