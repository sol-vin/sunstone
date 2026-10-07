require "./layout_renderer"

module Sunstone
  class FeatureGridLayout < LayoutRenderer
    def render_html(slide : Slide, deck : Deck, palette : Palette, slide_num : Int32, total_slides : Int32) : String
      hero = slide.raw["hero_feature"]? || slide.raw["hero"]?
      features = slide.raw["features"]?.try(&.as_a) || slide.raw["cards"]?.try(&.as_a)

      body = String.build do |str|
        str << render_slide_header(slide) << "\n"
        str << "          <div class=\"slide-body\" data-layout=\"feature-grid\">\n"

        if hero
          h_title = hero["title"]?.try(&.as_s) || ""
          h_badge = hero["badge"]?.try(&.as_s)
          h_color = hero["color"]?.try(&.as_s) || "accent"
          h_desc = hero["desc"]?.try(&.as_s) || hero["description"]?.try(&.as_s)
          h_code = hero["code"]?.try(&.as_s)
          h_lang = hero["lang"]?.try(&.as_s) || "crystal"
          h_cmd = hero["cmd"]?.try(&.as_s)
          h_items = hero["items"]?.try(&.as_a)

          str << "            <div class=\"bento-hero-column\">\n"
          str << "              <div class=\"card bento-hero-card " << h_color << "\" data-color=\"" << h_color << "\">\n"
          str << "                <div class=\"card-header\">\n"
          str << "                  <span class=\"card-title\">" << LayoutRenderer.tint_emojis(HTML.escape(h_title)) << "</span>\n"
          if h_badge
            str << "                  <span class=\"badge " << h_color << "\" data-color=\"" << h_color << "\">" << HTML.escape(h_badge) << "</span>\n"
          end
          str << "                </div>\n"

          if h_code
            str << "                <div class=\"code-window bento-code-window\" data-lang=\"" << h_lang.downcase << "\">\n"
            str << "                  <pre><code class=\"language-" << h_lang.downcase << " code-compact\">" << HTML.escape(h_code.strip) << "</code></pre>\n"
            str << "                </div>\n"
          elsif h_cmd
            str << "                <div class=\"terminal-window bento-code-window\" data-density=\"compact\">\n"
            str << "                  <div class=\"window-body\"><pre><code class=\"language-bash\">" << HTML.escape(h_cmd.strip) << "</code></pre></div>\n"
            str << "                </div>\n"
          end

          if h_items
            str << "                <ul class=\"card-list\">\n"
            h_items.each do |it|
              str << "                  <li>" << LayoutRenderer.tint_emojis(LayoutRenderer.extract_item_text(it)) << "</li>\n"
            end
            str << "                </ul>\n"
          end

          if h_desc
            str << "                <div class=\"bento-desc\">" << LayoutRenderer.tint_emojis(HTML.escape(h_desc)) << "</div>\n"
          end

          str << "              </div>\n"
          str << "            </div>\n"
        end

        if features && !features.empty?
          str << "            <div class=\"bento-side-column\">\n"
          features.each do |f|
            f_title = f["title"]?.try(&.as_s) || ""
            f_badge = f["badge"]?.try(&.as_s)
            f_color = f["color"]?.try(&.as_s) || "accent"
            f_desc = f["desc"]?.try(&.as_s) || f["description"]?.try(&.as_s)
            f_items = f["items"]?.try(&.as_a)

            str << "              <div class=\"card bento-subcard " << f_color << "\" data-color=\"" << f_color << "\">\n"
            str << "                <div class=\"card-header\">\n"
            str << "                  <span class=\"card-title\">" << LayoutRenderer.tint_emojis(HTML.escape(f_title)) << "</span>\n"
            if f_badge
              str << "                  <span class=\"badge " << f_color << "\" data-color=\"" << f_color << "\">" << HTML.escape(f_badge) << "</span>\n"
            end
            str << "                </div>\n"

            if f_items
              str << "                <ul class=\"card-list\">\n"
              f_items.each do |it|
                str << "                  <li>" << LayoutRenderer.tint_emojis(LayoutRenderer.extract_item_text(it)) << "</li>\n"
              end
              str << "                </ul>\n"
            end

            if f_desc
              str << "                <div class=\"bento-desc\">" << LayoutRenderer.tint_emojis(HTML.escape(f_desc)) << "</div>\n"
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
      hero = slide.raw["hero_feature"]? || slide.raw["hero"]?
      features = slide.raw["features"]?.try(&.as_a) || slide.raw["cards"]?.try(&.as_a)

      String.build do |str|
        str << "### Slide " << slide_num << ": " << slide.title << " [Feature Grid / Bento]\n"
        if hero
          str << "#### " << (hero["title"]?.try(&.as_s) || "Hero Feature") << "\n"
          if desc = hero["desc"]?.try(&.as_s)
            str << desc << "\n\n"
          end
        end
        if features && !features.empty?
          features.each do |f|
            str << "- **" << (f["title"]?.try(&.as_s) || "") << "**\n"
            if items = f["items"]?.try(&.as_a)
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
