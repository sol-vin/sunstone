require "./layout_renderer"

module Sunstone
  class CalendarMonthLayout < LayoutRenderer
    def render_html(slide : Slide, deck : Deck, palette : Palette, slide_num : Int32, total_slides : Int32) : String
      month_name = slide.raw["month"]?.try(&.as_s) || "OCTOBER 2026"
      start_offset = slide.raw["start_day_offset"]?.try(&.as_i) || 3 # 0=Mon, 6=Sun
      total_days = slide.raw["total_days"]?.try(&.as_i) || 31
      active_day = slide.raw["active_day"]?.try(&.as_i) || slide.raw["today"]?.try(&.as_i)
      events_raw = slide.raw["events"]?.try(&.as_a) || [] of YAML::Any
      legend_raw = slide.raw["legend"]?.try(&.as_a)

      # Index events by day
      events_by_day = Hash(Int32, Array(YAML::Any)).new { |h, k| h[k] = [] of YAML::Any }
      events_raw.each do |ev|
        if d = ev["day"]?.try(&.as_i)
          events_by_day[d] << ev
        end
      end

      body = String.build do |str|
        str << render_slide_header(slide) << "\n"
        str << "          <div class=\"slide-body layout-calendar-month\" data-layout=\"calendar-month\">\n"
        str << "            <div class=\"calendar-month-wrapper\">\n"

        # Month Top Bar with Legend
        str << "              <div class=\"calendar-top-bar\">\n"
        str << "                <div class=\"calendar-month-title\">\n"
        str << "                  <svg class=\"fa-icon\" viewBox=\"0 0 448 512\" aria-hidden=\"true\"><path fill=\"currentColor\" d=\"M152 24c0-13.3-10.7-24-24-24s-24 10.7-24 24V64H64C28.7 64 0 92.7 0 128v16 48V448c0 35.3 28.7 64 64 64H384c35.3 0 64-28.7 64-64V192 144 128c0-35.3-28.7-64-64-64H344V24c0-13.3-10.7-24-24-24s-24 10.7-24 24V64H152V24zM48 192h352V448c0 8.8-7.2 16-16 16H64c-8.8 0-16-7.2-16-16V192z\"/></svg>\n"
        str << "                  <span>" << LayoutRenderer.tint_emojis(HTML.escape(month_name)) << "</span>\n"
        str << "                </div>\n"
        if legend_raw && !legend_raw.empty?
          str << "                <div class=\"calendar-legend-bar\">\n"
          legend_raw.each do |lg|
            l_name = lg["label"]?.try(&.as_s) || "Category"
            l_color = lg["color"]?.try(&.as_s) || "accent"
            str << "                  <span class=\"legend-pill " << l_color << "\" data-color=\"" << l_color << "\">"
            str << "<span class=\"legend-dot " << l_color << "\"></span>" << LayoutRenderer.tint_emojis(HTML.escape(l_name)) << "</span>\n"
          end
          str << "                </div>\n"
        end
        str << "              </div>\n"

        # 7-Column Calendar Grid
        str << "              <div class=\"calendar-grid-table\">\n"
        str << "                <div class=\"calendar-day-headers\">\n"
        ["MON", "TUE", "WED", "THU", "FRI", "SAT", "SUN"].each do |day_name|
          str << "                  <div class=\"day-header-cell\">" << day_name << "</div>\n"
        end
        str << "                </div>\n"

        str << "                <div class=\"calendar-cells-grid\">\n"
        # Preceding dimmed days
        start_offset.times do |i|
          prev_num = (30 - start_offset + i + 1)
          str << "                  <div class=\"day-cell cell-dimmed\"><span class=\"day-num\">" << prev_num << "</span></div>\n"
        end

        # Actual days of month
        (1..total_days).each do |day|
          is_active = (active_day && active_day == day)
          active_cls = is_active ? " cell-active" : ""
          has_events = events_by_day.has_key?(day)
          ev_cls = has_events ? " has-events" : ""

          str << "                  <div class=\"day-cell" << active_cls << ev_cls << "\" data-day=\"" << day << "\">\n"
          str << "                    <div class=\"cell-header\"><span class=\"day-num\">" << day << "</span></div>\n"

          if has_events
            str << "                    <div class=\"cell-events-list\">\n"
            events_by_day[day].each do |ev|
              ev_title = ev["title"]?.try(&.as_s) || "Event"
              ev_color = ev["color"]?.try(&.as_s) || "accent"
              ev_badge = ev["badge"]?.try(&.as_s)

              str << "                      <div class=\"calendar-event-chip " << ev_color << "\" data-color=\"" << ev_color << "\" title=\"" << HTML.escape(ev_title) << "\">\n"
              str << "                        <span class=\"chip-dot " << ev_color << "\"></span>\n"
              str << "                        <span class=\"chip-title\">" << LayoutRenderer.tint_emojis(HTML.escape(ev_title)) << "</span>\n"
              if ev_badge
                str << "                        <span class=\"chip-badge\">" << HTML.escape(ev_badge) << "</span>\n"
              end
              str << "                      </div>\n"
            end
            str << "                    </div>\n"
          end

          str << "                  </div>\n"
        end

        # Trailing dimmed cells to fill grid (total cells multiple of 7)
        total_cells = start_offset + total_days
        remaining = (7 - (total_cells % 7)) % 7
        remaining.times do |j|
          next_num = j + 1
          str << "                  <div class=\"day-cell cell-dimmed\"><span class=\"day-num\">" << next_num << "</span></div>\n"
        end

        str << "                </div>\n"
        str << "              </div>\n"

        str << "            </div>\n"
        str << "          </div>"
      end

      render_section_wrapper(slide, deck, palette, slide_num, total_slides, body)
    end

    def render_markdown(slide : Slide, deck : Deck, palette : Palette, slide_num : Int32, total_slides : Int32) : String
      month_name = slide.raw["month"]?.try(&.as_s) || "Calendar Month"
      events_raw = slide.raw["events"]?.try(&.as_a) || [] of YAML::Any

      String.build do |str|
        str << "### Slide " << slide_num << ": " << slide.title << " [Calendar: " << month_name << "]\n"
        str << "- **Theme Palette**: `" << palette.id << "` (" << palette.name << ")\n"
        str << "- **Month**: " << month_name << "\n\n"

        if !events_raw.empty?
          str << "#### Key Events & Release Deadlines:\n"
          events_raw.each do |ev|
            day = ev["day"]?.try(&.as_i) || 0
            title = ev["title"]?.try(&.as_s) || "Event"
            badge = ev["badge"]?.try(&.as_s) || ""
            str << "- **Day " << day << "**: " << title
            str << " [" << badge << "]" unless badge.empty?
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
