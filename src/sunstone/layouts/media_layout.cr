require "./layout_renderer"

module Sunstone
  class MediaLayout < LayoutRenderer
    def render_html(slide : Slide, deck : Deck, palette : Palette, slide_num : Int32, total_slides : Int32) : String
      media = slide.raw["media"]?
      card = slide.raw["card"]?

      body = String.build do |str|
        str << render_slide_header(slide) << "\n"
        str << "          <div class=\"slide-body\" data-layout=\"two-column\" data-ratio=\"2:1\">\n"

        if media
          m_src = media["src"]?.try(&.as_s) || ""
          m_title = media["title"]?.try(&.as_s) || "Media"
          m_tag = media["tag"]?.try(&.as_s) || "Video"
          m_type = media["type"]?.try(&.as_s) || "video"

          str << "            <div class=\"column\" data-slot=\"left\">\n"
          str << "              <div class=\"code-window media-window\">\n"
          str << "                <div class=\"window-header\">\n"
          str << "                  <span class=\"window-title\">" << LayoutRenderer.tint_emojis(HTML.escape(m_title)) << "</span>\n"
          str << "                  <span class=\"lang-tag\">" << HTML.escape(m_tag) << "</span>\n"
          str << "                </div>\n"
          str << "                <div class=\"window-body media-body\">\n"
          if m_type == "video"
            str << "                  <video controls preload=\"auto\" playsinline class=\"slide-media\">\n"
            str << "                    <source src=\"" << HTML.escape(m_src) << "\" type=\"video/mp4\">\n"
            str << "                  </video>\n"
          else
            str << "                  <img src=\"" << HTML.escape(m_src) << "\" alt=\"" << HTML.escape(m_title) << "\" class=\"slide-media\">\n"
          end
          str << "                </div>\n"

          if caption = media["caption"]?
            speaker = caption["speaker"]?.try(&.as_s) || ""
            quote = caption["quote"]?.try(&.as_s) || ""
            str << "                <div class=\"media-caption\">\n"
            if !speaker.empty?
              str << "                  <span class=\"caption-speaker\">" << HTML.escape(speaker) << ":</span>\n"
            end
            str << "                  <span class=\"caption-quote\">" << LayoutRenderer.tint_emojis(HTML.escape(quote)) << "</span>\n"
            str << "                </div>\n"
          end

          str << "              </div>\n"
          str << "            </div>\n"
        end

        if card
          c_title = card["title"]?.try(&.as_s) || ""
          c_color = card["color"]?.try(&.as_s) || "accent"
          c_badge = card["badge"]?.try(&.as_s)
          items = Array(String).new
          if raw_items = card["items"]?.try(&.as_a)
            raw_items.each { |it| items << LayoutRenderer.extract_item_text(it) }
          end

          str << "            <div class=\"column\" data-slot=\"right\">\n"
          str << render_card(c_title, c_color, items, c_badge) << "\n"
          str << "            </div>\n"
        end

        str << "          </div>"
      end

      render_section_wrapper(slide, deck, palette, slide_num, total_slides, body)
    end

    def render_markdown(slide : Slide, deck : Deck, palette : Palette, slide_num : Int32, total_slides : Int32) : String
      media = slide.raw["media"]?
      card = slide.raw["card"]?

      String.build do |str|
        str << "### Slide " << slide_num << ": " << slide.title << " [Media]\n"
        if media
          str << "- **Media**: " << (media["title"]?.try(&.as_s) || "Video") << " (`" << (media["src"]?.try(&.as_s) || "") << "`)\n"
          if cap = media["caption"]?
            str << "- **Quote**: \"" << (cap["quote"]?.try(&.as_s) || "") << "\" — " << (cap["speaker"]?.try(&.as_s) || "") << "\n"
          end
        end
        if card
          str << "- **" << (card["title"]?.try(&.as_s) || "Key Points") << "**:\n"
          if items = card["items"]?.try(&.as_a)
            items.each { |it| str << "  - " << LayoutRenderer.clean_text(LayoutRenderer.extract_item_text(it)) << "\n" }
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
