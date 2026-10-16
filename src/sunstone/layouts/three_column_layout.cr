require "./layout_renderer"

module Sunstone
  class ThreeColumnLayout < LayoutRenderer
    def render_html(slide : Slide, deck : Deck, palette : Palette, slide_num : Int32, total_slides : Int32) : String
      has_matrix = !slide.raw["matrix"]?.nil?
      body = String.build do |str|
        str << render_slide_header(slide) << "\n"
        matrix_attr = has_matrix ? " data-has-matrix=\"true\"" : ""
        str << "          <div class=\"slide-body\" data-layout=\"three-column\"#{matrix_attr}>\n"

        if columns = slide.raw["columns"]?.try(&.as_a)
          columns.each do |col|
            item_type = col["type"]?.try(&.as_s) || "card"
            if item_type == "code"
              title = col["title"]?.try(&.as_s) || ""
              lang = col["lang"]?.try(&.as_s) || "crystal"
              code = col["code"]?.try(&.as_s) || ""
              tag = col["tag"]?.try(&.as_s)
              density = col["density"]?.try(&.as_s)
              str << render_code_container(title, lang, code, tag, density) << "\n"
            else
              title = col["title"]?.try(&.as_s) || ""
              color = col["color"]?.try(&.as_s) || "accent"
              badge = col["badge"]?.try(&.as_s)
              items = Array(String).new
              if raw_items = col["items"]?.try(&.as_a)
                raw_items.each { |it| items << LayoutRenderer.extract_item_text(it) }
              end
              compact = col["compact"]?.try(&.as_bool) || (items.size >= 5) || has_matrix
              str << render_card(title, color, items, badge, compact: compact) << "\n"
            end
          end
        end

        if matrix = slide.raw["matrix"]?.try(&.as_h)
          headers = Array(String).new
          if raw_headers = matrix["headers"]?.try(&.as_a)
            raw_headers.each { |h| headers << h.as_s }
          end
          rows = Array(Array(String)).new
          if raw_rows = matrix["rows"]?.try(&.as_a)
            raw_rows.each do |r|
              row_items = Array(String).new
              if r.as_a?
                r.as_a.each { |cell| row_items << cell.as_s }
              end
              rows << row_items
            end
          end
          highlight_idx = matrix["highlight_col"]?.try(&.as_i?) || 1

          str << "            <div class=\"matrix-container three-col-matrix\">\n"
          str << "              <table class=\"matrix-table\">\n"
          if !headers.empty?
            str << "                <thead>\n                  <tr>\n"
            headers.each_with_index do |h, idx|
              classes = String.build do |c|
                c << "dim-header" if idx == 0
                if idx == highlight_idx
                  c << " " unless c.empty?
                  c << "highlight highlight-col"
                end
              end
              cls_attr = classes.empty? ? "" : " class=\"#{classes}\""
              str << "                    <th#{cls_attr}>" << LayoutRenderer.tint_emojis(h) << "</th>\n"
            end
            str << "                  </tr>\n                </thead>\n"
          end
          str << "                <tbody>\n"
          rows.each do |row|
            str << "                  <tr>\n"
            row.each_with_index do |cell, c_idx|
              classes = String.build do |c|
                c << "dim-header" if c_idx == 0
                if c_idx == highlight_idx
                  c << " " unless c.empty?
                  c << "lapis-col highlight-col"
                end
              end
              cls_attr = classes.empty? ? "" : " class=\"#{classes}\""
              str << "                    <td#{cls_attr}>" << LayoutRenderer.tint_emojis(cell) << "</td>\n"
            end
            str << "                  </tr>\n"
          end
          str << "                </tbody>\n"
          str << "              </table>\n"
          str << "            </div>\n"
        end

        str << "          </div>"
      end

      render_section_wrapper(slide, deck, palette, slide_num, total_slides, body)
    end

    def render_markdown(slide : Slide, deck : Deck, palette : Palette, slide_num : Int32, total_slides : Int32) : String
      String.build do |str|
        str << "### Slide " << slide_num << ": " << slide.title << "\n"
        str << "- **Palette**: `" << palette.id << "` | **Badge**: `" << slide.badge << "`\n"
        if columns = slide.raw["columns"]?.try(&.as_a)
          columns.each do |c|
            str << "- **" << (c["title"]?.try(&.as_s) || "Column") << "**:\n"
            if raw_items = c["items"]?.try(&.as_a)
              raw_items.each { |it| str << "  - " << LayoutRenderer.clean_text(LayoutRenderer.extract_item_text(it)) << "\n" }
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
