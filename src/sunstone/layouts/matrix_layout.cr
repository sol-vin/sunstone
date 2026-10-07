require "./layout_renderer"

module Sunstone
  class MatrixLayout < LayoutRenderer
    def render_html(slide : Slide, deck : Deck, palette : Palette, slide_num : Int32, total_slides : Int32) : String
      headers = Array(String).new
      if raw_headers = slide.raw["headers"]?.try(&.as_a)
        raw_headers.each { |h| headers << h.as_s }
      end

      rows = Array(Array(String)).new
      if raw_rows = slide.raw["rows"]?.try(&.as_a)
        raw_rows.each do |r|
          row_items = Array(String).new
          if r.as_a?
            r.as_a.each { |cell| row_items << cell.as_s }
          end
          rows << row_items
        end
      end

      highlight_idx = if hl = slide.raw["highlight_col"]?
        if hl_i = hl.as_i?
          hl_i
        elsif hl.as_s? == "none"
          nil
        else
          headers.size > 1 ? headers.size - 1 : nil
        end
      else
        headers.size > 1 ? headers.size - 1 : nil
      end

      body = String.build do |str|
        str << render_slide_header(slide) << "\n"
        str << "          <div class=\"slide-body\" data-layout=\"matrix\">\n"
        str << "            <div class=\"matrix-container\">\n"
        str << "              <table class=\"matrix-table\">\n"

        if !headers.empty?
          str << "                <thead>\n                  <tr>\n"
          headers.each_with_index do |h, idx|
            classes = String.build do |c|
              c << "dim-header" if idx == 0
              if highlight_idx && idx == highlight_idx
                c << " " unless c.empty?
                c << "highlight highlight-col"
              end
            end
            cls_attr = classes.empty? ? "" : " class=\"#{classes}\""
            str << "                    <th#{cls_attr}>" << LayoutRenderer.tint_emojis(HTML.escape(h)) << "</th>\n"
          end
          str << "                  </tr>\n                </thead>\n"
        end

        str << "                <tbody>\n"
        rows.each do |row|
          str << "                  <tr>\n"
          row.each_with_index do |cell, c_idx|
            classes = String.build do |c|
              c << "dim-header" if c_idx == 0
              if highlight_idx && c_idx == highlight_idx
                c << " " unless c.empty?
                c << "lapis-col highlight-col"
              end
            end
            cls_attr = classes.empty? ? "" : " class=\"#{classes}\""
            str << "                    <td#{cls_attr}>" << LayoutRenderer.tint_emojis(HTML.escape(cell)) << "</td>\n"
          end
          str << "                  </tr>\n"
        end
        str << "                </tbody>\n"
        str << "              </table>\n"
        str << "            </div>\n"

        if summary = slide.raw["summary"]?.try(&.as_s)
          str << "            <div class=\"takeaway-banner\">\n"
          str << "              <span class=\"badge\" data-color=\"accent\">SUMMARY</span>\n"
          str << "              <span class=\"takeaway-text\">" << LayoutRenderer.tint_emojis(summary) << "</span>\n"
          str << "            </div>\n"
        end

        str << "          </div>"
      end

      render_section_wrapper(slide, deck, palette, slide_num, total_slides, body)
    end

    def render_markdown(slide : Slide, deck : Deck, palette : Palette, slide_num : Int32, total_slides : Int32) : String
      headers = Array(String).new
      if raw_headers = slide.raw["headers"]?.try(&.as_a)
        raw_headers.each { |h| headers << h.as_s }
      end

      rows = Array(Array(String)).new
      if raw_rows = slide.raw["rows"]?.try(&.as_a)
        raw_rows.each do |r|
          row_items = Array(String).new
          if r.as_a?
            r.as_a.each { |cell| row_items << cell.as_s }
          end
          rows << row_items
        end
      end

      String.build do |str|
        str << "### Slide " << slide_num << ": " << slide.title << " [Matrix]\n"
        if !headers.empty?
          str << "| " << headers.join(" | ") << " |\n"
          str << "| " << headers.map { "---" }.join(" | ") << " |\n"
          rows.each do |r|
            str << "| " << r.join(" | ") << " |\n"
          end
          str << "\n"
        end
        if summary = slide.raw["summary"]?.try(&.as_s)
          str << "**Summary**: " << LayoutRenderer.clean_text(summary) << "\n"
        end
        if !slide.notes.strip.empty?
          str << "\n**Presenter Notes**:\n> " << slide.notes.strip.gsub("\n", "\n> ") << "\n"
        end
        str << "\n---\n\n"
      end
    end
  end
end
