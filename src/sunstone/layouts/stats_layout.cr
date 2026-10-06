require "./layout_renderer"

module Sunstone
  class StatsLayout < LayoutRenderer
    def render_html(slide : Slide, deck : Deck, palette : Palette, slide_num : Int32, total_slides : Int32) : String
      metrics = slide.raw["metrics"]?.try(&.as_a) || slide.raw["stats"]?.try(&.as_a) || slide.raw["cards"]?.try(&.as_a)

      body = String.build do |str|
        str << render_slide_header(slide) << "\n"
        str << "          <div class=\"slide-body\" data-layout=\"stats\">\n"

        if metrics && !metrics.empty?
          cols = metrics.size >= 4 ? "4" : metrics.size.to_s
          str << "            <div class=\"stats-grid\" data-cols=\"" << cols << "\">\n"
          metrics.each do |m|
            val = m["value"]?.try(&.as_s) || ""
            lbl = m["label"]?.try(&.as_s) || m["title"]?.try(&.as_s) || ""
            delta = m["delta"]?.try(&.as_s) || m["badge"]?.try(&.as_s)
            color = m["color"]?.try(&.as_s) || "accent"
            desc = m["desc"]?.try(&.as_s) || m["description"]?.try(&.as_s)
            icon = m["icon"]?.try(&.as_s)

            str << "              <div class=\"card stat-kpi-card col " << color << "\" data-color=\"" << color << "\">\n"
            str << "                <div class=\"stat-kpi-header\">\n"
            if icon
              str << "                  <span class=\"stat-icon\">" << LayoutRenderer.render_icon(icon) << "</span>\n"
            else
              str << "                  <span></span>\n"
            end
            if delta
              str << "                  <span class=\"stat-kpi-badge badge " << color << "\" data-color=\"" << color << "\">" << HTML.escape(delta) << "</span>\n"
            end
            str << "                </div>\n"
            str << "                <div class=\"stat-kpi-value " << color << "\">" << LayoutRenderer.tint_emojis(HTML.escape(val)) << "</div>\n"
            str << "                <div class=\"stat-kpi-label\">" << LayoutRenderer.tint_emojis(HTML.escape(lbl)) << "</div>\n"
            if desc
              str << "                <div class=\"stat-kpi-desc\">" << LayoutRenderer.tint_emojis(HTML.escape(desc)) << "</div>\n"
            end
            str << "              </div>\n"
          end
          str << "            </div>\n"
        end

        str << "          </div>"
      end

      render_section_wrapper(slide, deck, palette, slide_num, total_slides, body)
    end

    def render_markdown(slide : Slide, deck : Deck, palette : Palette, slide_num : Int32, total_slides : Int32) : String
      metrics = slide.raw["metrics"]?.try(&.as_a) || slide.raw["stats"]?.try(&.as_a) || slide.raw["cards"]?.try(&.as_a)

      String.build do |str|
        str << "### Slide " << slide_num << ": " << slide.title << " [Stats / KPI]\n"
        if metrics && !metrics.empty?
          metrics.each do |m|
            val = m["value"]?.try(&.as_s) || ""
            lbl = m["label"]?.try(&.as_s) || m["title"]?.try(&.as_s) || ""
            delta = m["delta"]?.try(&.as_s) || m["badge"]?.try(&.as_s)
            desc = m["desc"]?.try(&.as_s)
            delta_str = delta ? " (#{delta})" : ""
            str << "- **" << val << "** — " << lbl << delta_str
            str << ": " << desc if desc
            str << "\n"
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
