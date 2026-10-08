require "./layout_renderer"

module Sunstone
  class ConvergenceLayout < LayoutRenderer
    def render_html(slide : Slide, deck : Deck, palette : Palette, slide_num : Int32, total_slides : Int32) : String
      pillars = slide.raw["pillars"]?.try(&.as_a) || slide.raw["streams"]?.try(&.as_a) || slide.raw["cards"]?.try(&.as_a) || [] of YAML::Any
      core_node = slide.raw["core"]? || slide.raw["synthesis"]? || slide.raw["sweet_spot"]?

      body = String.build do |str|
        str << render_slide_header(slide) << "\n"
        str << "          <div class=\"slide-body layout-convergence\" data-layout=\"convergence\">\n"
        str << "            <div class=\"convergence-stage\">\n"

        # Inbound Converging Pillars
        str << "              <div class=\"convergence-inputs-row\" data-count=\"" << pillars.size << "\">\n"
        pillars.each_with_index do |p, idx|
          p_title = p["title"]?.try(&.as_s) || "Pillar #{idx + 1}"
          p_badge = p["badge"]?.try(&.as_s)
          p_color = p["color"]?.try(&.as_s) || (idx == 0 ? "accent" : (idx == 1 ? "emerald" : "purple"))
          p_desc = p["desc"]?.try(&.as_s) || p["description"]?.try(&.as_s)
          p_items = p["items"]?.try(&.as_a)

          str << "                <div class=\"card convergence-pillar-card " << p_color << "\" data-color=\"" << p_color << "\">\n"
          str << "                  <div class=\"card-header\">\n"
          str << "                    <span class=\"card-title\">" << LayoutRenderer.tint_emojis(HTML.escape(p_title)) << "</span>\n"
          if p_badge
            str << "                    <span class=\"badge " << p_color << "\" data-color=\"" << p_color << "\">" << HTML.escape(p_badge) << "</span>\n"
          end
          str << "                  </div>\n"
          if p_desc
            str << "                  <p class=\"pillar-desc\">" << LayoutRenderer.tint_emojis(HTML.escape(p_desc)) << "</p>\n"
          end
          if p_items
            str << "                  <ul class=\"card-list\">\n"
            p_items.each do |it|
              str << "                    <li>" << LayoutRenderer.tint_emojis(LayoutRenderer.extract_item_text(it)) << "</li>\n"
            end
            str << "                  </ul>\n"
          end
          str << "                </div>\n"
        end
        str << "              </div>\n"

        # CSS Flow Connectors
        str << "              <div class=\"convergence-connector-track\">\n"
        str << "                <span class=\"convergence-arrow-down\">▼</span>\n"
        str << "              </div>\n"

        # Central Convergence Core Card
        if core_node
          c_title = core_node["title"]?.try(&.as_s) || "The Synthesis"
          c_badge = core_node["badge"]?.try(&.as_s) || "SWEET SPOT"
          c_color = core_node["color"]?.try(&.as_s) || "accent"
          c_desc = core_node["desc"]?.try(&.as_s) || core_node["description"]?.try(&.as_s)
          c_items = core_node["items"]?.try(&.as_a)

          str << "              <div class=\"card convergence-core-card " << c_color << "\" data-color=\"" << c_color << "\">\n"
          str << "                <div class=\"core-glow-border\"></div>\n"
          str << "                <div class=\"card-header\">\n"
          str << "                  <span class=\"card-title core-title\">" << LayoutRenderer.tint_emojis(HTML.escape(c_title)) << "</span>\n"
          str << "                  <span class=\"badge core-badge " << c_color << "\" data-color=\"" << c_color << "\">" << HTML.escape(c_badge) << "</span>\n"
          str << "                </div>\n"
          if c_desc
            str << "                <p class=\"core-desc\">" << LayoutRenderer.tint_emojis(HTML.escape(c_desc)) << "</p>\n"
          end
          if c_items
            str << "                <div class=\"core-pills-row\">\n"
            c_items.each do |it|
              str << "                  <span class=\"core-pill\">" << LayoutRenderer.tint_emojis(LayoutRenderer.extract_item_text(it)) << "</span>\n"
            end
            str << "                </div>\n"
          end
          str << "              </div>\n"
        end

        str << "            </div>\n"
        str << "          </div>"
      end

      render_section_wrapper(slide, deck, palette, slide_num, total_slides, body)
    end

    def render_markdown(slide : Slide, deck : Deck, palette : Palette, slide_num : Int32, total_slides : Int32) : String
      pillars = slide.raw["pillars"]?.try(&.as_a) || slide.raw["streams"]?.try(&.as_a)
      core_node = slide.raw["core"]? || slide.raw["synthesis"]?

      String.build do |str|
        str << "### Slide " << slide_num << ": " << slide.title << " [Convergence / Synthesis]\n"
        str << "- **Theme Palette**: `" << palette.id << "` (" << palette.name << ")\n"
        str << "- **Title**: " << slide.title << "\n\n"

        if pillars && !pillars.empty?
          str << "#### Converging Pillars:\n"
          pillars.each do |p|
            p_title = p["title"]?.try(&.as_s) || ""
            str << "- **" << p_title << "**\n"
            if desc = p["desc"]?.try(&.as_s)
              str << "  " << desc << "\n"
            end
            if items = p["items"]?.try(&.as_a)
              items.each { |it| str << "  - " << LayoutRenderer.clean_text(LayoutRenderer.extract_item_text(it)) << "\n" }
            end
          end
        end

        if core_node
          str << "\n#### Convergence Core (Sweet Spot):\n"
          c_title = core_node["title"]?.try(&.as_s) || "Synthesis"
          str << "**" << c_title << "**\n"
          if desc = core_node["desc"]?.try(&.as_s)
            str << "> " << desc << "\n"
          end
          if items = core_node["items"]?.try(&.as_a)
            items.each { |it| str << "- " << LayoutRenderer.clean_text(LayoutRenderer.extract_item_text(it)) << "\n" }
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
