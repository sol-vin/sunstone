require "./layout_renderer"

module Sunstone
  class RadialCycleLayout < LayoutRenderer
    def render_html(slide : Slide, deck : Deck, palette : Palette, slide_num : Int32, total_slides : Int32) : String
      hub = slide.raw["hub"]? || slide.raw["center"]?
      steps = slide.raw["steps"]?.try(&.as_a) || slide.raw["nodes"]?.try(&.as_a) || slide.raw["cards"]?.try(&.as_a) || [] of YAML::Any
      step_count = steps.size

      body = String.build do |str|
        str << render_slide_header(slide) << "\n"
        str << "          <div class=\"slide-body layout-radial-cycle\" data-layout=\"radial-cycle\" data-nodes=\"" << step_count << "\">\n"
        str << "            <div class=\"radial-cycle-arena\">\n"

        # Central Hub
        hub_title = hub.try(&.[]?("title")).try(&.as_s) || slide.title
        hub_badge = hub.try(&.[]?("badge")).try(&.as_s) || "FLYWHEEL"
        hub_subtitle = hub.try(&.[]?("subtitle")).try(&.as_s) || "Continuous Loop"

        str << "              <div class=\"radial-center-hub\">\n"
        str << "                <div class=\"hub-pulse-ring\"></div>\n"
        str << "                <div class=\"hub-core\">\n"
        str << "                  <span class=\"badge hub-badge accent\">" << LayoutRenderer.tint_emojis(HTML.escape(hub_badge)) << "</span>\n"
        str << "                  <span class=\"hub-title\">" << LayoutRenderer.tint_emojis(HTML.escape(hub_title)) << "</span>\n"
        str << "                  <span class=\"hub-subtitle\">" << LayoutRenderer.tint_emojis(HTML.escape(hub_subtitle)) << "</span>\n"
        str << "                </div>\n"
        str << "              </div>\n"

        # Orbital Cycle Grid
        str << "              <div class=\"radial-orbit-grid\" data-nodes=\"" << step_count << "\">\n"
        steps.each_with_index do |st, idx|
          s_num = st["step"]?.try(&.as_s) || sprintf("%02d", idx + 1)
          s_title = st["title"]?.try(&.as_s) || "Phase #{idx + 1}"
          s_badge = st["badge"]?.try(&.as_s)
          s_color = st["color"]?.try(&.as_s) || (idx == 0 ? "accent" : (idx == 1 ? "emerald" : (idx == 2 ? "purple" : "amber")))
          s_desc = st["desc"]?.try(&.as_s) || st["description"]?.try(&.as_s)
          s_items = st["items"]?.try(&.as_a)

          str << "                <div class=\"card radial-orbit-card node-" << (idx + 1) << " " << s_color << "\" data-node-idx=\"" << (idx + 1) << "\" data-color=\"" << s_color << "\">\n"
          str << "                  <div class=\"radial-node-header\">\n"
          str << "                    <span class=\"node-step-badge " << s_color << "\">" << s_num << "</span>\n"
          str << "                    <span class=\"card-title\">" << LayoutRenderer.tint_emojis(HTML.escape(s_title)) << "</span>\n"
          if s_badge
            str << "                    <span class=\"badge " << s_color << "\" data-color=\"" << s_color << "\">" << HTML.escape(s_badge) << "</span>\n"
          end
          str << "                  </div>\n"
          if s_desc
            str << "                  <p class=\"node-desc\">" << LayoutRenderer.tint_emojis(HTML.escape(s_desc)) << "</p>\n"
          end
          if s_items
            str << "                  <ul class=\"card-list\">\n"
            s_items.each do |it|
              str << "                    <li>" << LayoutRenderer.tint_emojis(LayoutRenderer.extract_item_text(it)) << "</li>\n"
            end
            str << "                  </ul>\n"
          end
          str << "                </div>\n"
        end
        str << "              </div>\n"

        str << "            </div>\n"
        str << "          </div>"
      end

      render_section_wrapper(slide, deck, palette, slide_num, total_slides, body)
    end

    def render_markdown(slide : Slide, deck : Deck, palette : Palette, slide_num : Int32, total_slides : Int32) : String
      steps = slide.raw["steps"]?.try(&.as_a) || slide.raw["nodes"]?.try(&.as_a) || slide.raw["cards"]?.try(&.as_a)

      String.build do |str|
        str << "### Slide " << slide_num << ": " << slide.title << " [Radial Cycle / Flywheel]\n"
        str << "- **Theme Palette**: `" << palette.id << "` (" << palette.name << ")\n"
        str << "- **Title**: " << slide.title << "\n\n"

        if steps && !steps.empty?
          steps.each_with_index do |st, idx|
            s_num = st["step"]?.try(&.as_s) || (idx + 1).to_s
            s_title = st["title"]?.try(&.as_s) || ""
            str << "- **[" << s_num << "] " << s_title << "**\n"
            if desc = (st["desc"]?.try(&.as_s) || st["description"]?.try(&.as_s))
              str << "  " << desc << "\n"
            end
            if items = st["items"]?.try(&.as_a)
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
