require "./layout_renderer"

module Sunstone
  class QuoteLayout < LayoutRenderer
    def render_html(slide : Slide, deck : Deck, palette : Palette, slide_num : Int32, total_slides : Int32) : String
      quote_text = slide["quote"]?.try(&.as_s?) ||
                   slide["text"]?.try(&.as_s?) ||
                   (slide.bullets.empty? ? slide.content : slide.bullets.join(" "))

      author = slide.author.presence ||
               slide["author"]?.try(&.as_s?) || ""
      
      role = slide["role"]?.try(&.as_s?) ||
             slide["attribution"]?.try(&.as_s?) ||
             slide["title"]?.try(&.as_s?) || ""

      source = slide["source"]?.try(&.as_s?) ||
               slide["citation"]?.try(&.as_s?) || ""

      body = String.build do |str|
        unless slide.title.strip.empty? || slide.title == "Quote"
          str << render_slide_header(slide) << "\n"
        end
        str << "          <div class=\"slide-body\">\n"
        str << "            <div class=\"quote-content\">\n"
        str << "              <blockquote class=\"quote-text\">\n"
        str << "                <p>“" << LayoutRenderer.tint_emojis(HTML.escape(quote_text.strip)) << "”</p>\n"
        str << "              </blockquote>\n"
        if !author.strip.empty? || !role.strip.empty? || !source.strip.empty?
          str << "              <div class=\"quote-attribution\">\n"
          unless author.strip.empty?
            str << "                <div class=\"quote-author\">" << LayoutRenderer.tint_emojis(HTML.escape(author.strip)) << "</div>\n"
          end
          unless role.strip.empty?
            str << "                <div class=\"quote-role\">" << LayoutRenderer.tint_emojis(HTML.escape(role.strip)) << "</div>\n"
          end
          unless source.strip.empty?
            str << "                <div class=\"quote-source\"><cite>" << LayoutRenderer.tint_emojis(HTML.escape(source.strip)) << "</cite></div>\n"
          end
          str << "              </div>\n"
        end
        str << "            </div>\n"
        str << "          </div>"
      end

      render_section_wrapper(slide, deck, palette, slide_num, total_slides, body)
    end

    def render_markdown(slide : Slide, deck : Deck, palette : Palette, slide_num : Int32, total_slides : Int32) : String
      quote_text = slide["quote"]?.try(&.as_s?) ||
                   slide["text"]?.try(&.as_s?) ||
                   (slide.bullets.empty? ? slide.content : slide.bullets.join(" "))
      author = slide.author.presence ||
               slide["author"]?.try(&.as_s?) || ""
      role = slide["role"]?.try(&.as_s?) || ""

      String.build do |str|
        str << "## " << (slide.title.empty? ? "Quote" : slide.title) << "\n\n"
        str << "> " << quote_text.strip.gsub("\n", "\n> ") << "\n\n"
        if !author.empty?
          str << "**— " << author
          str << " (#{role})" unless role.empty?
          str << "**\n\n"
        end
      end
    end
  end
end
