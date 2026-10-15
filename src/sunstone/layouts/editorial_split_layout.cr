require "./layout_renderer"

module Sunstone
  class EditorialSplitLayout < LayoutRenderer
    def render_html(slide : Slide, deck : Deck, palette : Palette, slide_num : Int32, total_slides : Int32) : String
      lead_num = slide.raw["numeral"]?.try(&.as_s) || slide.raw["lead_stat"]?.try(&.as_s) || "01"
      headline = slide.raw["headline"]?.try(&.as_s) || slide.title
      quote_text = slide.raw["quote"]?.try(&.as_s)
      attribution = slide.raw["attribution"]?.try(&.as_s) || slide.raw["author"]?.try(&.as_s)
      cards_raw = slide.raw["cards"]?.try(&.as_a) || slide.raw["pillars"]?.try(&.as_a) || slide.raw["takeaways"]?.try(&.as_a)

      code_node = slide.raw["code"]? || slide.raw["snippet"]?
      code_str : String? = nil
      code_title = slide.raw["code_title"]?.try(&.as_s) || "snippet.rb"
      code_lang = slide.raw["lang"]?.try(&.as_s) || "ruby"
      code_tag = slide.raw["tag"]?.try(&.as_s)
      code_density = slide.raw["density"]?.try(&.as_s) || "compact"

      if cn = code_node
        if ch = cn.as_h?
          code_str = ch["code"]?.try(&.as_s) || ch["content"]?.try(&.as_s)
          code_title = ch["title"]?.try(&.as_s) || code_title
          code_lang = ch["lang"]?.try(&.as_s) || code_lang
          code_tag = ch["tag"]?.try(&.as_s) || code_tag
          code_density = ch["density"]?.try(&.as_s) || code_density
        elsif cs = cn.as_s?
          code_str = cs
        end
      end

      body = String.build do |str|
        str << render_slide_header(slide) << "\n"
        str << "          <div class=\"slide-body layout-editorial-split\" data-layout=\"editorial-split\">\n"

        # Left Editorial Lead
        str << "            <div class=\"editorial-lead-col\">\n"
        str << "              <div class=\"editorial-numeral-wrap\">\n"
        str << "                <span class=\"editorial-huge-numeral\">" << HTML.escape(lead_num) << "</span>\n"
        str << "              </div>\n"
        str << "              <h3 class=\"editorial-lead-headline\">" << LayoutRenderer.tint_emojis(HTML.escape(headline)) << "</h3>\n"
        if cs = code_str
          str << "              <div class=\"editorial-lead-code\">\n"
          str << render_code_container(code_title, code_lang, cs, code_tag, code_density) << "\n"
          str << "              </div>\n"
        end
        if quote_text
          str << "              <div class=\"editorial-pull-quote\">\n"
          str << "                <p>“" << LayoutRenderer.tint_emojis(HTML.escape(quote_text)) << "”</p>\n"
          if attribution
            str << "                <span class=\"editorial-attribution\">— " << LayoutRenderer.tint_emojis(HTML.escape(attribution)) << "</span>\n"
          end
          str << "              </div>\n"
        end
        str << "            </div>\n"

        # Right Staggered Cards
        str << "            <div class=\"editorial-cards-col\">\n"
        if cards_raw && !cards_raw.empty?
          cards_raw.each_with_index do |cd, idx|
            c_title = cd["title"]?.try(&.as_s) || "Principle #{idx + 1}"
            c_badge = cd["badge"]?.try(&.as_s)
            c_color = cd["color"]?.try(&.as_s) || (idx == 0 ? "accent" : "emerald")
            c_desc = cd["desc"]?.try(&.as_s) || cd["description"]?.try(&.as_s)
            c_items = cd["items"]?.try(&.as_a)

            str << "              <div class=\"card editorial-card " << c_color << "\" data-color=\"" << c_color << "\">\n"
            str << "                <div class=\"card-header\">\n"
            str << "                  <span class=\"card-title\">" << LayoutRenderer.tint_emojis(HTML.escape(c_title)) << "</span>\n"
            if c_badge
              str << "                  <span class=\"badge " << c_color << "\" data-color=\"" << c_color << "\">" << HTML.escape(c_badge) << "</span>\n"
            end
            str << "                </div>\n"
            if c_desc
              str << "                <p class=\"editorial-card-desc\">" << LayoutRenderer.tint_emojis(HTML.escape(c_desc)) << "</p>\n"
            end
            if c_items
              str << "                <ul class=\"card-list\">\n"
              c_items.each do |it|
                str << "                  <li>" << LayoutRenderer.tint_emojis(LayoutRenderer.extract_item_text(it)) << "</li>\n"
              end
              str << "                </ul>\n"
            end
            str << "              </div>\n"
          end
        end
        str << "            </div>\n"

        str << "          </div>"
      end

      render_section_wrapper(slide, deck, palette, slide_num, total_slides, body)
    end

    def render_markdown(slide : Slide, deck : Deck, palette : Palette, slide_num : Int32, total_slides : Int32) : String
      headline = slide.raw["headline"]?.try(&.as_s) || slide.title
      quote_text = slide.raw["quote"]?.try(&.as_s)
      attribution = slide.raw["attribution"]?.try(&.as_s) || slide.raw["author"]?.try(&.as_s)
      cards_raw = slide.raw["cards"]?.try(&.as_a) || slide.raw["pillars"]?.try(&.as_a)
      code_node = slide.raw["code"]? || slide.raw["snippet"]?
      code_str : String? = nil
      code_lang = slide.raw["lang"]?.try(&.as_s) || "ruby"
      if cn = code_node
        if ch = cn.as_h?
          code_str = ch["code"]?.try(&.as_s) || ch["content"]?.try(&.as_s)
          code_lang = ch["lang"]?.try(&.as_s) || code_lang
        elsif cs = cn.as_s?
          code_str = cs
        end
      end

      String.build do |str|
        str << "### Slide " << slide_num << ": " << slide.title << " [Editorial Split]\n"
        str << "- **Theme Palette**: `" << palette.id << "` (" << palette.name << ")\n"
        str << "- **Headline**: " << headline << "\n\n"

        if cs = code_str
          str << "```" << code_lang << "\n" << cs.strip << "\n```\n\n"
        end

        if quote_text
          str << "> " << quote_text
          str << " — " << attribution if attribution
          str << "\n\n"
        end

        if cards_raw && !cards_raw.empty?
          cards_raw.each do |cd|
            c_title = cd["title"]?.try(&.as_s) || ""
            str << "- **" << c_title << "**\n"
            if desc = cd["desc"]?.try(&.as_s)
              str << "  " << desc << "\n"
            end
            if items = cd["items"]?.try(&.as_a)
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
