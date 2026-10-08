require "./layout_renderer"

module Sunstone
  class CalendarScheduleLayout < LayoutRenderer
    def render_html(slide : Slide, deck : Deck, palette : Palette, slide_num : Int32, total_slides : Int32) : String
      cols_raw = slide.raw["columns"]?.try(&.as_a) || slide.raw["days"]?.try(&.as_a) || slide.raw["tracks"]?.try(&.as_a) || [
        YAML::Any.new("Day 1 • Architecture"), YAML::Any.new("Day 2 • Deep Dives"), YAML::Any.new("Day 3 • Workshops")
      ]
      num_cols = cols_raw.size

      body = String.build do |str|
        str << render_slide_header(slide) << "\n"
        str << "          <div class=\"slide-body layout-calendar-schedule\" data-layout=\"calendar-schedule\" data-cols=\"" << num_cols << "\">\n"
        str << "            <div class=\"schedule-grid\" data-cols=\"" << num_cols << "\">\n"

        cols_raw.each_with_index do |col_node, col_idx|
          col_title = col_node.as_s? || col_node["title"]?.try(&.as_s) || "Track #{col_idx + 1}"
          col_badge = col_node["badge"]?.try(&.as_s)
          col_color = col_node["color"]?.try(&.as_s) || (col_idx == 0 ? "accent" : (col_idx == 1 ? "emerald" : "amber"))
          sessions = col_node["sessions"]?.try(&.as_a) || col_node["items"]?.try(&.as_a)

          str << "              <div class=\"schedule-col\" data-col-idx=\"" << (col_idx + 1) << "\">\n"
          str << "                <div class=\"schedule-col-header " << col_color << "\">\n"
          str << "                  <span class=\"schedule-col-title\">" << LayoutRenderer.tint_emojis(HTML.escape(col_title)) << "</span>\n"
          if col_badge
            str << "                  <span class=\"badge " << col_color << "\" data-color=\"" << col_color << "\">" << HTML.escape(col_badge) << "</span>\n"
          end
          str << "                </div>\n"

          str << "                <div class=\"schedule-session-list\">\n"
          if sessions && !sessions.empty?
            sessions.each do |sess|
              s_time = sess["time"]?.try(&.as_s) || "09:00"
              s_title = sess["title"]?.try(&.as_s) || "Session"
              s_speaker = sess["speaker"]?.try(&.as_s)
              s_room = sess["room"]?.try(&.as_s) || sess["track"]?.try(&.as_s)
              s_color = sess["color"]?.try(&.as_s) || col_color
              s_badge = sess["badge"]?.try(&.as_s)
              s_desc = sess["desc"]?.try(&.as_s)

              str << "                  <div class=\"card schedule-session-card " << s_color << "\" data-color=\"" << s_color << "\">\n"
              str << "                    <div class=\"session-meta-row\">\n"
              str << "                      <span class=\"session-time-badge\">" << HTML.escape(s_time) << "</span>\n"
              if s_room
                str << "                      <span class=\"session-room-tag\">" << LayoutRenderer.tint_emojis(HTML.escape(s_room)) << "</span>\n"
              end
              if s_badge
                str << "                      <span class=\"badge " << s_color << "\" data-color=\"" << s_color << "\">" << HTML.escape(s_badge) << "</span>\n"
              end
              str << "                    </div>\n"
              str << "                    <div class=\"session-title\">" << LayoutRenderer.tint_emojis(HTML.escape(s_title)) << "</div>\n"
              if s_speaker
                str << "                    <div class=\"session-speaker\">" << LayoutRenderer.tint_emojis(HTML.escape(s_speaker)) << "</div>\n"
              end
              if s_desc
                str << "                    <div class=\"session-desc\">" << LayoutRenderer.tint_emojis(HTML.escape(s_desc)) << "</div>\n"
              end
              str << "                  </div>\n"
            end
          end
          str << "                </div>\n"
          str << "              </div>\n"
        end

        str << "            </div>\n"
        str << "          </div>"
      end

      render_section_wrapper(slide, deck, palette, slide_num, total_slides, body)
    end

    def render_markdown(slide : Slide, deck : Deck, palette : Palette, slide_num : Int32, total_slides : Int32) : String
      cols_raw = slide.raw["columns"]?.try(&.as_a) || slide.raw["days"]?.try(&.as_a) || slide.raw["tracks"]?.try(&.as_a)

      String.build do |str|
        str << "### Slide " << slide_num << ": " << slide.title << " [Calendar / Schedule Timetable]\n"
        str << "- **Theme Palette**: `" << palette.id << "` (" << palette.name << ")\n"
        str << "- **Title**: " << slide.title << "\n\n"

        if cols_raw && !cols_raw.empty?
          cols_raw.each do |col_node|
            col_title = col_node.as_s? || col_node["title"]?.try(&.as_s) || "Track"
            str << "#### " << col_title << "\n"
            if sessions = (col_node["sessions"]?.try(&.as_a) || col_node["items"]?.try(&.as_a))
              sessions.each do |sess|
                s_time = sess["time"]?.try(&.as_s) || ""
                s_title = sess["title"]?.try(&.as_s) || ""
                s_speaker = sess["speaker"]?.try(&.as_s) || ""
                str << "- **" << s_time << "**: " << s_title
                str << " (" << s_speaker << ")" unless s_speaker.empty?
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
