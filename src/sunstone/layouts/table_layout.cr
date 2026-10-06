require "./layout_renderer"

module Sunstone
  class TableLayout < LayoutRenderer
    def render_html(slide : Slide, deck : Deck, palette : Palette, slide_num : Int32, total_slides : Int32) : String
      headers = slide.raw["headers"]?.try(&.as_a) || slide.raw["columns"]?.try(&.as_a)
      rows = slide.raw["rows"]?.try(&.as_a) || slide.raw["data"]?.try(&.as_a)
      highlight_idx = slide.raw["highlight_row"]?.try(&.as_i) || slide.raw["highlight"]?.try(&.as_i)
      footnote = slide.raw["footnote"]?.try(&.as_s)

      body = String.build do |str|
        str << render_slide_header(slide) << "\n"
        str << "          <div class=\"slide-body\" data-layout=\"table\">\n"
        str << "            <div class=\"data-table-container\">\n"
        str << "              <table class=\"sunstone-table\">\n"

        if headers && !headers.empty?
          str << "                <thead>\n"
          str << "                  <tr>\n"
          headers.each do |h|
            str << "                    <th>" << LayoutRenderer.tint_emojis(HTML.escape(h.as_s)) << "</th>\n"
          end
          str << "                  </tr>\n"
          str << "                </thead>\n"
        end

        if rows && !rows.empty?
          str << "                <tbody>\n"
          rows.each_with_index do |r, r_idx|
            hl_class = (highlight_idx && highlight_idx == r_idx) ? " class=\"highlight-row\"" : ""
            str << "                  <tr" << hl_class << ">\n"
            if cells = r.as_a?
              cells.each do |c|
                cell_text = c.as_s? || c.to_s
                str << "                    <td>" << LayoutRenderer.tint_emojis(HTML.escape(cell_text)) << "</td>\n"
              end
            end
            str << "                  </tr>\n"
          end
          str << "                </tbody>\n"
        end

        str << "              </table>\n"
        str << "            </div>\n"

        if footnote
          str << "            <div class=\"table-footnote\">" << LayoutRenderer.tint_emojis(HTML.escape(footnote)) << "</div>\n"
        end

        str << "          </div>"
      end

      render_section_wrapper(slide, deck, palette, slide_num, total_slides, body)
    end

    def render_markdown(slide : Slide, deck : Deck, palette : Palette, slide_num : Int32, total_slides : Int32) : String
      headers = slide.raw["headers"]?.try(&.as_a) || slide.raw["columns"]?.try(&.as_a)
      rows = slide.raw["rows"]?.try(&.as_a) || slide.raw["data"]?.try(&.as_a)

      String.build do |str|
        str << "### Slide " << slide_num << ": " << slide.title << " [Table / Benchmark]\n\n"
        if headers && !headers.empty?
          str << "| " << headers.map { |h| LayoutRenderer.clean_text(h.as_s) }.join(" | ") << " |\n"
          str << "| " << headers.map { |_| "---" }.join(" | ") << " |\n"
        end
        if rows && !rows.empty?
          rows.each do |r|
            if cells = r.as_a?
              str << "| " << cells.map { |c| LayoutRenderer.clean_text(c.as_s? || c.to_s) }.join(" | ") << " |\n"
            end
          end
        end
        if footnote = slide.raw["footnote"]?.try(&.as_s)
          str << "\n*" << footnote << "*\n"
        end
        if !slide.notes.strip.empty?
          str << "\n**Presenter Notes**:\n> " << slide.notes.strip.gsub("\n", "\n> ") << "\n"
        end
        str << "\n---\n\n"
      end
    end
  end
end
