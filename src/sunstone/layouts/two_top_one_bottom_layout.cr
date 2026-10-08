require "./layout_renderer"

module Sunstone
  class TwoTopOneBottomLayout < LayoutRenderer
    def render_html(slide : Slide, deck : Deck, palette : Palette, slide_num : Int32, total_slides : Int32) : String
      ratio = slide.raw["ratio"]?.try(&.as_s) || "1:1"
      top_data = slide.raw["top"]?
      top_left = slide.raw["top_left"]?
      top_right = slide.raw["top_right"]?
      bottom_data = slide.raw["bottom"]? || slide.raw["takeaway"]? || slide.raw["footer_box"]?

      # Fallback: synthesize top from cards if bottom is also present
      if top_data.nil? && top_left.nil? && top_right.nil? && slide.raw["cards"]?
        top_data = slide.raw["cards"]?
      end

      body = String.build do |str|
        str << render_slide_header(slide) << "\n"
        str << "          <div class=\"slide-body layout-two-top-one-bottom\" data-layout=\"two-top-one-bottom\" data-ratio=\"" << ratio << "\">\n"

        # Top Row (2 side-by-side columns)
        str << "            <div class=\"row-split slot-top\" data-slot=\"top\">\n"
        if top_left
          str << "              <div class=\"column col slot-top-left\" data-slot=\"top-left\">\n"
          render_column_content(str, top_left, slide)
          str << "              </div>\n"
        end
        if top_right
          str << "              <div class=\"column col slot-top-right\" data-slot=\"top-right\">\n"
          render_column_content(str, top_right, slide)
          str << "              </div>\n"
        end
        if top_left.nil? && top_right.nil? && top_data
          if items = top_data.as_a?
            items.each_with_index do |item, idx|
              slot_name = idx == 0 ? "top-left" : "top-right"
              str << "              <div class=\"column col slot-" << slot_name << "\" data-slot=\"" << slot_name << "\">\n"
              render_slot_item(str, item, slide)
              str << "              </div>\n"
            end
          else
            str << "              <div class=\"column col slot-top-left\" data-slot=\"top-left\">\n"
            render_slot_item(str, top_data, slide)
            str << "              </div>\n"
          end
        end
        str << "            </div>\n"

        # Bottom Row (Full-width container)
        str << "            <div class=\"row-hero slot-bottom\" data-slot=\"bottom\">\n"
        if bottom_data
          render_column_content(str, bottom_data, slide)
        end
        str << "            </div>\n"

        str << "          </div>"
      end

      render_section_wrapper(slide, deck, palette, slide_num, total_slides, body)
    end

    def render_markdown(slide : Slide, deck : Deck, palette : Palette, slide_num : Int32, total_slides : Int32) : String
      String.build do |str|
        str << "### Slide " << slide_num << ": " << slide.title << " [Two-Top-One-Bottom]\n"
        str << "- **Theme Palette**: `" << palette.id << "` (" << palette.name << ")\n"
        str << "- **Title**: " << slide.title << "\n"

        str << "\n#### Top Split Columns:\n"
        [slide.raw["top_left"]?, slide.raw["top_right"]?, slide.raw["top"]?].compact.each do |t|
          items = t.as_a? || [t]
          items.each do |it|
            t_name = it["title"]?.try(&.as_s) || "Item"
            str << "- **" << t_name << "**\n"
            if c_items = it["items"]?.try(&.as_a)
              c_items.each { |c_it| str << "  - " << LayoutRenderer.clean_text(LayoutRenderer.extract_item_text(c_it)) << "\n" }
            end
          end
        end

        if bottom = (slide.raw["bottom"]? || slide.raw["takeaway"]?)
          str << "\n#### Bottom Full-Width Slot:\n"
          items = bottom.as_a? || [bottom]
          items.each do |it|
            t_name = it["title"]?.try(&.as_s) || "Takeaway"
            str << "- **" << t_name << "**\n"
            if c_items = it["items"]?.try(&.as_a)
              c_items.each { |c_it| str << "  - " << LayoutRenderer.clean_text(LayoutRenderer.extract_item_text(c_it)) << "\n" }
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
