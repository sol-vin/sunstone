require "./layout_renderer"

module Sunstone
  class FourColumnLayout < LayoutRenderer
    def render_html(slide : Slide, deck : Deck, palette : Palette, slide_num : Int32, total_slides : Int32) : String
      body = String.build do |str|
        str << render_slide_header(slide) << "\n"
        str << "          <div class=\"slide-body four-cols\" data-layout=\"four-column\">\n"

        if columns = slide.raw["columns"]?.try(&.as_a)
          columns.each do |col|
            item_type = col["type"]?.try(&.as_s) || "card"
            if item_type == "code"
              title = col["title"]?.try(&.as_s) || ""
              lang = col["lang"]?.try(&.as_s) || "crystal"
              code = col["code"]?.try(&.as_s) || ""
              tag = col["tag"]?.try(&.as_s)
              density = col["density"]?.try(&.as_s) || "compact"
              str << render_code_container(title, lang, code, tag, density) << "\n"
            else
              title = col["title"]?.try(&.as_s) || ""
              color = col["color"]?.try(&.as_s) || "accent"
              badge = col["badge"]?.try(&.as_s)
              items = Array(String).new
              if raw_items = col["items"]?.try(&.as_a)
                raw_items.each { |it| items << LayoutRenderer.extract_item_text(it) }
              end
              compact = col["compact"]?.try(&.as_bool) || (items.size >= 4)
              str << render_card(title, color, items, badge, compact: compact) << "\n"
            end
          end
        end

        str << "          </div>"
      end

      render_section_wrapper(slide, deck, palette, slide_num, total_slides, body)
    end

    def render_markdown(slide : Slide, deck : Deck, palette : Palette, slide_num : Int32, total_slides : Int32) : String
      String.build do |str|
        str << "### Slide " << slide_num << ": " << slide.title << "\n"
        str << "- **Palette**: `" << palette.id << "` | **Badge**: `" << slide.badge << "`\n"
        if columns = slide.raw["columns"]?.try(&.as_a)
          columns.each do |c|
            str << "- **" << (c["title"]?.try(&.as_s) || "Column") << "**:\n"
            if raw_items = c["items"]?.try(&.as_a)
              raw_items.each { |it| str << "  - " << LayoutRenderer.clean_text(LayoutRenderer.extract_item_text(it)) << "\n" }
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
