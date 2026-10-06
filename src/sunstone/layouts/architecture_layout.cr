require "./layout_renderer"

module Sunstone
  class ArchitectureLayout < LayoutRenderer
    def render_html(slide : Slide, deck : Deck, palette : Palette, slide_num : Int32, total_slides : Int32) : String
      tiers = slide.raw["tiers"]?.try(&.as_a)

      body = String.build do |str|
        str << render_slide_header(slide) << "\n"
        str << "          <div class=\"slide-body arch-stack\" data-layout=\"architecture\">\n"

        if tiers
          tiers.each do |t|
            tier_title = t["title"]?.try(&.as_s) || ""
            tier_label = t["label"]?.try(&.as_s) || ""
            tier_badge = t["badge"]?.try(&.as_s)
            color = t["color"]?.try(&.as_s) || "accent"
            blocks = t["blocks"]?.try(&.as_a) || Array(YAML::Any).new

            cols_count = t["columns"]?.try(&.as_i) || t["cols"]?.try(&.as_i) || blocks.size
            cols_count = 1 if cols_count < 1

            str << "            <div class=\"arch-tier\" data-color=\"" << color << "\">\n"
            str << "              <div class=\"arch-tier-header\">\n"
            str << "                <span class=\"arch-tier-name\">" << LayoutRenderer.tint_emojis(HTML.escape(tier_title)) << "</span>\n"
            str << "                <span class=\"arch-tier-label\">" << LayoutRenderer.tint_emojis(HTML.escape(tier_label)) << "</span>\n"
            if tier_badge
              str << "                <span class=\"badge\" data-color=\"" << color << "\">" << HTML.escape(tier_badge) << "</span>\n"
            end
            str << "              </div>\n"

            str << "              <div class=\"arch-grid\" data-cols=\"" << cols_count << "\">\n"
            blocks.each do |b|
              b_title = b["title"]?.try(&.as_s) || ""
              b_desc = b["desc"]?.try(&.as_s) || ""
              str << "                <div class=\"arch-block\" data-color=\"" << color << "\">\n"
              str << "                  <div class=\"arch-block-title\">" << LayoutRenderer.tint_emojis(HTML.escape(b_title)) << "</div>\n"
              unless b_desc.empty?
                str << "                  <div class=\"arch-block-desc\">" << LayoutRenderer.tint_emojis(b_desc) << "</div>\n"
              end
              str << "                </div>\n"
            end
            str << "              </div>\n"
            str << "            </div>\n"
          end
        end

        str << "          </div>"
      end

      render_section_wrapper(slide, deck, palette, slide_num, total_slides, body)
    end

    def render_markdown(slide : Slide, deck : Deck, palette : Palette, slide_num : Int32, total_slides : Int32) : String
      String.build do |str|
        str << "### Slide " << slide_num << ": " << slide.title << " [Architecture]\n"
        if tiers = slide.raw["tiers"]?.try(&.as_a)
          tiers.each do |t|
            t_name = t["title"]?.try(&.as_s) || "Tier"
            str << "- **" << t_name << "**:\n"
            if blocks = t["blocks"]?.try(&.as_a)
              blocks.each do |b|
                str << "  - **" << (b["title"]?.try(&.as_s) || "") << "**: " << (b["desc"]?.try(&.as_s) || "") << "\n"
              end
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
