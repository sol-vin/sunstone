require "./layout_renderer"

module Sunstone
  class DemoRoadmapLayout < LayoutRenderer
    def render_html(slide : Slide, deck : Deck, palette : Palette, slide_num : Int32, total_slides : Int32) : String
      steps = slide.raw["steps"]?.try(&.as_a)
      summary = slide.raw["summary"]?.try(&.as_s)

      body = String.build do |str|
        str << render_slide_header(slide) << "\n"
        str << "          <div class=\"slide-body\" data-layout=\"demo-roadmap\">\n"

        if steps
          str << "            <div class=\"demo-steps-grid\" data-cols=\"" << steps.size << "\">\n"
          steps.each do |s|
            phase = s["phase"]?.try(&.as_s) || ""
            title = s["title"]?.try(&.as_s) || ""
            color = s["color"]?.try(&.as_s) || "accent"
            cmd = s["cmd"]?.try(&.as_s)
            code = s["code"]?.try(&.as_s)
            lang = s["lang"]?.try(&.as_s) || (code ? "crystal" : "bash")
            items = s["items"]?.try(&.as_a)
            highlight = s["highlight"]?.try(&.as_s)

            str << "              <div class=\"card demo-step-card\" data-color=\"" << color << "\">\n"
            str << "                <div class=\"card-header\">\n"
            str << "                  <span class=\"card-title\">" << LayoutRenderer.tint_emojis(HTML.escape(title)) << "</span>\n"
            if !phase.empty?
              str << "                  <span class=\"badge\" data-color=\"" << color << "\">" << HTML.escape(phase) << "</span>\n"
            end
            str << "                </div>\n"

            if cmd
              str << "                <div class=\"terminal-window\" data-density=\"compact\">\n"
              str << "                  <div class=\"window-body\"><pre><code class=\"language-bash\">" << HTML.escape(cmd.strip) << "</code></pre></div>\n"
              str << "                </div>\n"
            elsif code
              str << "                <div class=\"code-window\" data-density=\"compact\">\n"
              str << "                  <div class=\"window-body\"><pre><code class=\"language-" << lang << "\">" << HTML.escape(code.strip) << "</code></pre></div>\n"
              str << "                </div>\n"
            end

            if items
              str << "                <ul class=\"card-list\">\n"
              items.each do |it|
                str << "                  <li>" << LayoutRenderer.tint_emojis(it.as_s) << "</li>\n"
              end
              str << "                </ul>\n"
            end

            if highlight
              str << "                <div class=\"demo-step-highlight\">" << LayoutRenderer.tint_emojis(highlight) << "</div>\n"
            end

            str << "              </div>\n"
          end
          str << "            </div>\n"
        end

        if summary
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
      steps = slide.raw["steps"]?.try(&.as_a)
      String.build do |str|
        str << "### Slide " << slide_num << ": " << slide.title << " [Demo Roadmap]\n"
        if steps
          steps.each do |s|
            str << "- **" << (s["phase"]?.try(&.as_s) || "Step") << " — " << (s["title"]?.try(&.as_s) || "") << "**:\n"
            if cmd = s["cmd"]?.try(&.as_s)
              str << "  ```bash\n  " << cmd.strip.gsub("\n", "\n  ") << "\n  ```\n"
            end
            if items = s["items"]?.try(&.as_a)
              items.each { |it| str << "  - " << LayoutRenderer.clean_text(it.as_s) << "\n" }
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
