require "./layout_renderer"

module Sunstone
  class OneTopTwoBottomLayout < LayoutRenderer
    def render_html(slide : Slide, deck : Deck, palette : Palette, slide_num : Int32, total_slides : Int32) : String
      ratio = slide.raw["ratio"]?.try(&.as_s) || "1:1"
      top_data = slide.raw["top"]? || slide.raw["hero"]?
      bottom_data = slide.raw["bottom"]?
      bottom_left = slide.raw["bottom_left"]?
      bottom_right = slide.raw["bottom_right"]?

      # Fallback: synthesize top from code or alert
      if top_data.nil? && (slide.raw["code"]? || slide.raw["code_title"]?)
        top_h = Hash(YAML::Any, YAML::Any).new
        top_h[YAML::Any.new("type")] = YAML::Any.new("code")
        top_h[YAML::Any.new("title")] = slide.raw["code_title"]? || YAML::Any.new("Code")
        top_h[YAML::Any.new("lang")] = slide.raw["code_lang"]? || YAML::Any.new("crystal")
        top_h[YAML::Any.new("code")] = slide.raw["code"]? || YAML::Any.new("")
        top_data = YAML::Any.new(top_h)
      end

      # Fallback: synthesize bottom from cards
      if bottom_data.nil? && bottom_left.nil? && bottom_right.nil? && slide.raw["cards"]?
        bottom_data = slide.raw["cards"]?
      end

      body = String.build do |str|
        str << render_slide_header(slide) << "\n"
        str << "          <div class=\"slide-body layout-one-top-two-bottom\" data-layout=\"one-top-two-bottom\" data-ratio=\"" << ratio << "\">\n"

        # Top Row (Full-width hero slot)
        str << "            <div class=\"row-hero slot-top\" data-slot=\"top\">\n"
        if top_data
          render_column_content(str, top_data, slide)
        end
        str << "            </div>\n"

        # Bottom Row (2 side-by-side columns)
        str << "            <div class=\"row-split slot-bottom\" data-slot=\"bottom\">\n"
        if bottom_left
          str << "              <div class=\"column col slot-bottom-left\" data-slot=\"bottom-left\">\n"
          render_column_content(str, bottom_left, slide)
          str << "              </div>\n"
        end
        if bottom_right
          str << "              <div class=\"column col slot-bottom-right\" data-slot=\"bottom-right\">\n"
          render_column_content(str, bottom_right, slide)
          str << "              </div>\n"
        end
        if bottom_left.nil? && bottom_right.nil? && bottom_data
          if items = bottom_data.as_a?
            items.each_with_index do |item, idx|
              slot_name = idx == 0 ? "bottom-left" : "bottom-right"
              str << "              <div class=\"column col slot-" << slot_name << "\" data-slot=\"" << slot_name << "\">\n"
              render_slot_item(str, item, slide)
              str << "              </div>\n"
            end
          else
            str << "              <div class=\"column col slot-bottom-left\" data-slot=\"bottom-left\">\n"
            render_slot_item(str, bottom_data, slide)
            str << "              </div>\n"
          end
        end
        str << "            </div>\n"

        str << "          </div>"
      end

      render_section_wrapper(slide, deck, palette, slide_num, total_slides, body)
    end

    def render_markdown(slide : Slide, deck : Deck, palette : Palette, slide_num : Int32, total_slides : Int32) : String
      String.build do |str|
        str << "### Slide " << slide_num << ": " << slide.title << " [One-Top-Two-Bottom]\n"
        str << "- **Theme Palette**: `" << palette.id << "` (" << palette.name << ")\n"
        str << "- **Title**: " << slide.title << "\n"

        if top = (slide.raw["top"]? || slide.raw["hero"]?)
          str << "\n#### Top Hero Slot:\n"
          items = top.as_a? || [top]
          items.each do |it|
            t = it["title"]?.try(&.as_s) || "Hero"
            str << "- **" << t << "**\n"
            if c_items = it["items"]?.try(&.as_a)
              c_items.each { |c_it| str << "  - " << LayoutRenderer.clean_text(LayoutRenderer.extract_item_text(c_it)) << "\n" }
            end
          end
        end

        str << "\n#### Bottom Split Columns:\n"
        [slide.raw["bottom_left"]?, slide.raw["bottom_right"]?, slide.raw["bottom"]?].compact.each do |b|
          items = b.as_a? || [b]
          items.each do |it|
            t = it["title"]?.try(&.as_s) || "Item"
            str << "- **" << t << "**\n"
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
