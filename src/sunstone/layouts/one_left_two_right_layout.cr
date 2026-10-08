require "./layout_renderer"

module Sunstone
  class OneLeftTwoRightLayout < LayoutRenderer
    def render_html(slide : Slide, deck : Deck, palette : Palette, slide_num : Int32, total_slides : Int32) : String
      ratio = slide.raw["ratio"]?.try(&.as_s) || "1:1"
      left_data = slide.raw["left"]?
      right_data = slide.raw["right"]?
      right_top = slide.raw["right_top"]?
      right_bottom = slide.raw["right_bottom"]?

      # Graceful fallback: synthesize left if top-level code is provided
      if left_data.nil? && (slide.raw["code"]? || slide.raw["code_title"]?)
        left_h = Hash(YAML::Any, YAML::Any).new
        left_h[YAML::Any.new("type")] = YAML::Any.new("code")
        left_h[YAML::Any.new("title")] = slide.raw["code_title"]? || YAML::Any.new("Code")
        left_h[YAML::Any.new("lang")] = slide.raw["code_lang"]? || YAML::Any.new("crystal")
        left_h[YAML::Any.new("code")] = slide.raw["code"]? || YAML::Any.new("")
        if tag = slide.raw["code_tag"]?
          left_h[YAML::Any.new("tag")] = tag
        end
        if density = slide.raw["code_density"]? || slide.raw["density"]?
          left_h[YAML::Any.new("density")] = density
        end
        left_data = YAML::Any.new(left_h)
      end

      # Graceful fallback: synthesize right if top-level cards are provided
      if right_data.nil? && right_top.nil? && right_bottom.nil? && slide.raw["cards"]?
        right_data = slide.raw["cards"]?
      end

      body = String.build do |str|
        str << render_slide_header(slide) << "\n"
        str << "          <div class=\"slide-body layout-one-left-two-right\" data-layout=\"one-left-two-right\" data-ratio=\"" << ratio << "\">\n"

        # Left Column (Full-height slot)
        str << "            <div class=\"column col slot-left\" data-slot=\"left\">\n"
        if left_data
          render_column_content(str, left_data, slide)
        end
        str << "            </div>\n"

        # Right Column (2 stacked containers)
        str << "            <div class=\"column-stack col slot-right\" data-slot=\"right\">\n"
        if right_top
          str << "              <div class=\"stack-slot slot-top\" data-slot=\"top\">\n"
          render_column_content(str, right_top, slide)
          str << "              </div>\n"
        end
        if right_bottom
          str << "              <div class=\"stack-slot slot-bottom\" data-slot=\"bottom\">\n"
          render_column_content(str, right_bottom, slide)
          str << "              </div>\n"
        end
        if right_top.nil? && right_bottom.nil? && right_data
          if items = right_data.as_a?
            items.each_with_index do |item, idx|
              slot_name = idx == 0 ? "top" : "bottom"
              str << "              <div class=\"stack-slot slot-" << slot_name << "\" data-slot=\"" << slot_name << "\">\n"
              render_slot_item(str, item, slide)
              str << "              </div>\n"
            end
          else
            str << "              <div class=\"stack-slot slot-top\" data-slot=\"top\">\n"
            render_slot_item(str, right_data, slide)
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
        str << "### Slide " << slide_num << ": " << slide.title << " [One-Left-Two-Right]\n"
        str << "- **Theme Palette**: `" << palette.id << "` (" << palette.name << ")\n"
        str << "- **Title**: " << slide.title << "\n"
        unless slide.subtitle.strip.empty?
          str << "- **Subtitle**: " << slide.subtitle << "\n"
        end

        if left = slide.raw["left"]?
          str << "\n#### Left Column:\n"
          items = left.as_a? || [left]
          items.each do |it|
            t = it["title"]?.try(&.as_s) || "Item"
            str << "- **" << t << "**\n"
            if c_items = it["items"]?.try(&.as_a)
              c_items.each { |c_it| str << "  - " << LayoutRenderer.clean_text(LayoutRenderer.extract_item_text(c_it)) << "\n" }
            end
          end
        end

        str << "\n#### Right Stacked Containers:\n"
        [slide.raw["right_top"]?, slide.raw["right_bottom"]?, slide.raw["right"]?].compact.each do |r|
          items = r.as_a? || [r]
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
