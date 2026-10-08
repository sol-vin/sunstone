require "./layout_renderer"

module Sunstone
  class OneLeftThreeRightLayout < LayoutRenderer
    def render_html(slide : Slide, deck : Deck, palette : Palette, slide_num : Int32, total_slides : Int32) : String
      ratio = slide.raw["ratio"]?.try(&.as_s) || "3:2"
      left_data = slide.raw["left"]?
      right_data = slide.raw["right"]? || slide.raw["cards"]?

      # Fallback: synthesize left from code
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

      body = String.build do |str|
        str << render_slide_header(slide) << "\n"
        str << "          <div class=\"slide-body layout-one-left-three-right\" data-layout=\"one-left-three-right\" data-ratio=\"" << ratio << "\">\n"

        # Left Column (Showcase slot)
        str << "            <div class=\"column col slot-left\" data-slot=\"left\">\n"
        if left_data
          render_column_content(str, left_data, slide)
        end
        str << "            </div>\n"

        # Right Column (3 stacked compact cards)
        str << "            <div class=\"column-stack-three col slot-right\" data-slot=\"right\">\n"
        if right_data
          if items = right_data.as_a?
            items.each_with_index do |item, idx|
              str << "              <div class=\"stack-slot slot-" << (idx + 1) << "\" data-slot=\"slot-" << (idx + 1) << "\">\n"
              render_slot_item(str, item, slide)
              str << "              </div>\n"
            end
          else
            str << "              <div class=\"stack-slot slot-1\" data-slot=\"slot-1\">\n"
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
        str << "### Slide " << slide_num << ": " << slide.title << " [One-Left-Three-Right]\n"
        str << "- **Theme Palette**: `" << palette.id << "` (" << palette.name << ")\n"
        str << "- **Title**: " << slide.title << "\n"

        if left = slide.raw["left"]?
          str << "\n#### Left Showcase Column:\n"
          items = left.as_a? || [left]
          items.each do |it|
            t = it["title"]?.try(&.as_s) || "Item"
            str << "- **" << t << "**\n"
            if c_items = it["items"]?.try(&.as_a)
              c_items.each { |c_it| str << "  - " << LayoutRenderer.clean_text(LayoutRenderer.extract_item_text(c_it)) << "\n" }
            end
          end
        end

        if right = (slide.raw["right"]? || slide.raw["cards"]?)
          str << "\n#### Right Stacked Checkpoints:\n"
          items = right.as_a? || [right]
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
