require "./layout_renderer"

module Sunstone
  class RoadmapTimelineLayout < LayoutRenderer
    def render_html(slide : Slide, deck : Deck, palette : Palette, slide_num : Int32, total_slides : Int32) : String
      periods = slide.raw["periods"]?.try(&.as_a) || slide.raw["quarters"]?.try(&.as_a) || slide.raw["columns"]?.try(&.as_a) || [
        YAML::Any.new("Q1 2026"), YAML::Any.new("Q2 2026"), YAML::Any.new("Q3 2026"), YAML::Any.new("Q4 2026")
      ]
      tracks = slide.raw["tracks"]?.try(&.as_a) || slide.raw["streams"]?.try(&.as_a) || slide.raw["rows"]?.try(&.as_a)
      num_periods = periods.size

      body = String.build do |str|
        str << render_slide_header(slide) << "\n"
        str << "          <div class=\"slide-body layout-roadmap-timeline\" data-layout=\"roadmap-timeline\" data-period-count=\"" << num_periods << "\">\n"
        str << "            <div class=\"roadmap-board\">\n"

        # Periods Header Row
        str << "              <div class=\"roadmap-header-row\">\n"
        str << "                <div class=\"roadmap-track-label-cell\"><span class=\"track-label-title\">TRACK / STREAM</span></div>\n"
        str << "                <div class=\"roadmap-periods-grid\" data-cols=\"" << num_periods << "\">\n"
        periods.each do |p|
          p_str = p.as_s? || p.to_s
          str << "                  <div class=\"roadmap-period-cell\"><span class=\"period-name\">" << LayoutRenderer.tint_emojis(HTML.escape(p_str)) << "</span></div>\n"
        end
        str << "                </div>\n"
        str << "              </div>\n"

        # Tracks / Rows
        if tracks && !tracks.empty?
          str << "              <div class=\"roadmap-tracks-container\">\n"
          tracks.each do |tr|
            t_name = tr["name"]?.try(&.as_s) || tr["title"]?.try(&.as_s) || "Workstream"
            t_badge = tr["badge"]?.try(&.as_s)
            t_color = tr["color"]?.try(&.as_s) || "accent"
            bars = tr["bars"]?.try(&.as_a) || tr["milestones"]?.try(&.as_a)

            str << "                <div class=\"roadmap-track-row\">\n"
            str << "                  <div class=\"roadmap-track-meta " << t_color << "\">\n"
            str << "                    <span class=\"track-name\">" << LayoutRenderer.tint_emojis(HTML.escape(t_name)) << "</span>\n"
            if t_badge
              str << "                    <span class=\"badge " << t_color << "\" data-color=\"" << t_color << "\">" << HTML.escape(t_badge) << "</span>\n"
            end
            str << "                  </div>\n"

            # Timeline Grid for this track
            str << "                  <div class=\"roadmap-track-grid\" data-cols=\"" << num_periods << "\">\n"
            if bars && !bars.empty?
              bars.each do |b|
                b_title = b["title"]?.try(&.as_s) || b["name"]?.try(&.as_s) || "Deliverable"
                b_start = b["start"]?.try(&.as_i) || 1
                b_span = b["span"]?.try(&.as_i) || 1
                b_color = b["color"]?.try(&.as_s) || "accent"
                b_badge = b["badge"]?.try(&.as_s)

                str << "                    <div class=\"roadmap-bar " << b_color << "\" data-color=\"" << b_color << "\" data-col-start=\"" << b_start << "\" data-col-span=\"" << b_span << "\">\n"
                str << "                      <span class=\"bar-label\">" << LayoutRenderer.tint_emojis(HTML.escape(b_title)) << "</span>\n"
                if b_badge
                  str << "                      <span class=\"bar-badge badge " << b_color << "\">" << HTML.escape(b_badge) << "</span>\n"
                end
                str << "                    </div>\n"
              end
            end
            str << "                  </div>\n"
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
      periods = slide.raw["periods"]?.try(&.as_a) || slide.raw["quarters"]?.try(&.as_a) || slide.raw["columns"]?.try(&.as_a)
      tracks = slide.raw["tracks"]?.try(&.as_a) || slide.raw["streams"]?.try(&.as_a)

      String.build do |str|
        str << "### Slide " << slide_num << ": " << slide.title << " [Roadmap Timeline / Gantt]\n"
        str << "- **Theme Palette**: `" << palette.id << "` (" << palette.name << ")\n"
        str << "- **Title**: " << slide.title << "\n\n"

        if periods && !periods.empty?
          str << "**Timeline Periods**: " << periods.map { |p| p.as_s? || p.to_s }.join(" • ") << "\n\n"
        end

        if tracks && !tracks.empty?
          tracks.each do |tr|
            t_name = tr["name"]?.try(&.as_s) || tr["title"]?.try(&.as_s) || "Stream"
            str << "#### " << t_name << "\n"
            if bars = (tr["bars"]?.try(&.as_a) || tr["milestones"]?.try(&.as_a))
              bars.each do |b|
                b_title = b["title"]?.try(&.as_s) || "Item"
                b_badge = b["badge"]?.try(&.as_s) || ""
                b_start = b["start"]?.try(&.as_i) || 1
                b_span = b["span"]?.try(&.as_i) || 1
                str << "- " << b_title << " (Cols " << b_start << "–" << (b_start + b_span - 1) << ")"
                str << " [" << b_badge << "]" unless b_badge.empty?
                str << "\n"
              end
            end
            str << "\n"
          end
        end

        if !slide.notes.strip.empty?
          str << "**Presenter Notes**:\n> " << slide.notes.strip.gsub("\n", "\n> ") << "\n"
        end
        str << "\n---\n\n"
      end
    end
  end
end
