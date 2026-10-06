require "./layout_renderer"

module Sunstone
  class ProfileLayout < LayoutRenderer
    def render_html(slide : Slide, deck : Deck, palette : Palette, slide_num : Int32, total_slides : Int32) : String
      stats = slide.raw["stats"]?.try(&.as_a)
      cards = slide.raw["cards"]?.try(&.as_a) || slide.raw["columns"]?.try(&.as_a)

      body = String.build do |str|
        str << render_slide_header(slide) << "\n"
        str << "          <div class=\"slide-body\" data-layout=\"profile\">\n"

        if stats && !stats.empty?
          str << "            <div class=\"profile-stats-ribbon\">\n"
          stats.each do |st|
            icon = st["icon"]?.try(&.as_s) || "star"
            val = st["value"]?.try(&.as_s) || ""
            lbl = st["label"]?.try(&.as_s) || ""
            str << "              <div class=\"profile-stat-chip\">\n"
            str << "                <span class=\"stat-icon\">" << LayoutRenderer.render_icon(icon) << "</span>\n"
            str << "                <div class=\"stat-meta\">\n"
            str << "                  <span class=\"stat-value\">" << LayoutRenderer.tint_emojis(HTML.escape(val)) << "</span>\n"
            str << "                  <span class=\"stat-label\">" << LayoutRenderer.tint_emojis(HTML.escape(lbl)) << "</span>\n"
            str << "                </div>\n"
            str << "              </div>\n"
          end
          str << "            </div>\n"
        end

        if cards && !cards.empty?
          str << "            <div class=\"profile-bento-grid\">\n"
          cards.each do |c|
            title = c["title"]?.try(&.as_s) || ""
            color = c["color"]?.try(&.as_s) || "accent"
            badge = c["badge"]?.try(&.as_s)
            items = Array(String).new
            if raw_items = c["items"]?.try(&.as_a)
              raw_items.each { |it| items << LayoutRenderer.extract_item_text(it) }
            end
            str << render_card(title, color, items, badge) << "\n"
          end
          str << "            </div>\n"
        end

        str << "          </div>"
      end

      render_section_wrapper(slide, deck, palette, slide_num, total_slides, body)
    end

    def render_markdown(slide : Slide, deck : Deck, palette : Palette, slide_num : Int32, total_slides : Int32) : String
      stats = slide.raw["stats"]?.try(&.as_a)
      cards = slide.raw["cards"]?.try(&.as_a) || slide.raw["columns"]?.try(&.as_a)

      String.build do |str|
        str << "### Slide " << slide_num << ": " << slide.title << " [Profile]\n"
        if stats && !stats.empty?
          str << "- **Stats**:\n"
          stats.each do |st|
            str << "  - " << (st["label"]?.try(&.as_s) || "") << ": **" << (st["value"]?.try(&.as_s) || "") << "**\n"
          end
        end
        if cards && !cards.empty?
          cards.each do |c|
            str << "- **" << (c["title"]?.try(&.as_s) || "") << "**:\n"
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
