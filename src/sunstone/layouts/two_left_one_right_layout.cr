require "./layout_renderer"

module Sunstone
  class TwoLeftOneRightLayout < LayoutRenderer
    def render_html(slide : Slide, deck : Deck, palette : Palette, slide_num : Int32, total_slides : Int32) : String
      ratio = slide.raw["ratio"]?.try(&.as_s) || "1:1"
      left_data = slide.raw["left"]?
      left_top = slide.raw["left_top"]?
      left_bottom = slide.raw["left_bottom"]?
      right_data = slide.raw["right"]?

      # Graceful fallback: synthesize right if top-level code is provided
      if right_data.nil? && (slide.raw["code"]? || slide.raw["code_title"]?)
        right_h = Hash(YAML::Any, YAML::Any).new
        right_h[YAML::Any.new("type")] = YAML::Any.new("code")
        right_h[YAML::Any.new("title")] = slide.raw["code_title"]? || YAML::Any.new("Code")
        right_h[YAML::Any.new("lang")] = slide.raw["code_lang"]? || YAML::Any.new("crystal")
        right_h[YAML::Any.new("code")] = slide.raw["code"]? || YAML::Any.new("")
        if tag = slide.raw["code_tag"]?
          right_h[YAML::Any.new("tag")] = tag
        end
        if density = slide.raw["code_density"]? || slide.raw["density"]?
          right_h[YAML::Any.new("density")] = density
        end
        right_data = YAML::Any.new(right_h)
      end

      # Fallback: synthesize left if top-level cards provided
      if left_data.nil? && left_top.nil? && left_bottom.nil? && slide.raw["cards"]?
        left_data = slide.raw["cards"]?
      end

      body = String.build do |str|
        str << render_slide_header(slide) << "\n"
        str << "          <div class=\"slide-body layout-two-left-one-right\" data-layout=\"two-left-one-right\" data-ratio=\"" << ratio << "\">\n"

        # Left Column (2 stacked containers)
        str << "            <div class=\"column-stack col slot-left\" data-slot=\"left\">\n"
        if left_top
          str << "              <div class=\"stack-slot slot-top\" data-slot=\"top\">\n"
          render_column_content(str, left_top, slide)
          str << "              </div>\n"
        end
        if left_bottom
          str << "              <div class=\"stack-slot slot-bottom\" data-slot=\"bottom\">\n"
          render_column_content(str, left_bottom, slide)
          str << "              </div>\n"
        end
        if left_top.nil? && left_bottom.nil? && left_data
          if items = left_data.as_a?
            items.each_with_index do |item, idx|
              slot_name = idx == 0 ? "top" : "bottom"
              str << "              <div class=\"stack-slot slot-" << slot_name << "\" data-slot=\"" << slot_name << "\">\n"
              render_slot_item(str, item, slide)
              str << "              </div>\n"
            end
          else
            str << "              <div class=\"stack-slot slot-top\" data-slot=\"top\">\n"
            render_slot_item(str, left_data, slide)
            str << "              </div>\n"
          end
        end
        str << "            </div>\n"

        # Right Column (Full-height slot)
        str << "            <div class=\"column col slot-right\" data-slot=\"right\">\n"
        if right_data
          render_column_content(str, right_data, slide)
        end
        str << "            </div>\n"

        str << "          </div>"
      end

      render_section_wrapper(slide, deck, palette, slide_num, total_slides, body)
    end

    def render_markdown(slide : Slide, deck : Deck, palette : Palette, slide_num : Int32, total_slides : Int32) : String
      String.build do |str|
        str << "### Slide " << slide_num << ": " << slide.title << " [Two-Left-One-Right]\n"
        str << "- **Theme Palette**: `" << palette.id << "` (" << palette.name << ")\n"
        str << "- **Title**: " << slide.title << "\n"

        str << "\n#### Left Stacked Containers:\n"
        [slide.raw["left_top"]?, slide.raw["left_bottom"]?, slide.raw["left"]?].compact.each do |l|
          items = l.as_a? || [l]
          items.each do |it|
            t = it["title"]?.try(&.as_s) || "Item"
            str << "- **" << t << "**\n"
            if c_items = it["items"]?.try(&.as_a)
              c_items.each { |c_it| str << "  - " << LayoutRenderer.clean_text(LayoutRenderer.extract_item_text(c_it)) << "\n" }
            end
          end
        end

        if right = slide.raw["right"]?
          str << "\n#### Right Column:\n"
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
