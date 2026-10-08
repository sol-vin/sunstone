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

            chart_color = case color
                          when "emerald", "green" then palette.accent_color
                          when "amber", "yellow"  then palette.accent_tertiary
                          when "purple", "violet" then palette.accent_secondary
                          when "blue"             then palette.link_color
                          when "red", "rose"      then palette.accent_secondary
                          when "cyan", "accent"   then palette.border_active
                          else                         palette.accent_color
                          end

            chart_svg : String? = nil
            if chart_node = m["chart"]?
              chart_svg = Sunstone::Chart.from_yaml(chart_node, chart_color)
            elsif spark_node = m["sparkline"]?
              spark_data = Array(Float64).new
              if spark_arr = spark_node.as_a?
                spark_arr.each { |d| spark_data << (d.as_f? || d.as_i?.try(&.to_f64) || 0.0) }
              end
              chart_svg = Sunstone::Chart.sparkline(spark_data, stroke: chart_color) unless spark_data.empty?
            elsif prog_node = m["progress"]?
              prog_val = (prog_node.as_f? || prog_node.as_i?.try(&.to_f64) || 0.0)
              chart_svg = Sunstone::Chart.progress_ring(prog_val, color: chart_color, track_color: palette.border_color)
            end

            if chart_svg
              str << "                <div class=\"stat-kpi-chart\">\n"
              str << "                  " << chart_svg << "\n"
              str << "                </div>\n"
            end

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
