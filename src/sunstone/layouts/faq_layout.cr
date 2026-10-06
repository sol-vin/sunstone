require "./layout_renderer"

module Sunstone
  class FaqLayout < LayoutRenderer
    def render_html(slide : Slide, deck : Deck, palette : Palette, slide_num : Int32, total_slides : Int32) : String
      questions = slide.raw["questions"]?.try(&.as_a) || slide.raw["items"]?.try(&.as_a) || slide.raw["cards"]?.try(&.as_a)

      body = String.build do |str|
        str << render_slide_header(slide) << "\n"
        str << "          <div class=\"slide-body\" data-layout=\"faq\">\n"

        if questions && !questions.empty?
          str << "            <div class=\"faq-grid\">\n"
          questions.each_with_index do |q_item, idx|
            q_text = q_item["q"]?.try(&.as_s) || q_item["question"]?.try(&.as_s) || q_item["title"]?.try(&.as_s) || ""
            a_text = q_item["a"]?.try(&.as_s) || q_item["answer"]?.try(&.as_s) || q_item["desc"]?.try(&.as_s) || ""
            color = q_item["color"]?.try(&.as_s) || "accent"
            badge = q_item["badge"]?.try(&.as_s) || "Q#{idx + 1}"

            str << "              <div class=\"card faq-card col " << color << "\" data-color=\"" << color << "\">\n"
            str << "                <div class=\"faq-question\">\n"
            str << "                  <span class=\"faq-q-badge badge " << color << "\" data-color=\"" << color << "\">" << HTML.escape(badge) << "</span>\n"
            str << "                  <span>" << LayoutRenderer.tint_emojis(HTML.escape(q_text)) << "</span>\n"
            str << "                </div>\n"
            str << "                <div class=\"faq-answer\">" << LayoutRenderer.tint_emojis(HTML.escape(a_text)) << "</div>\n"
            str << "              </div>\n"
          end
          str << "            </div>\n"
        end

        str << "          </div>"
      end

      render_section_wrapper(slide, deck, palette, slide_num, total_slides, body)
    end

    def render_markdown(slide : Slide, deck : Deck, palette : Palette, slide_num : Int32, total_slides : Int32) : String
      questions = slide.raw["questions"]?.try(&.as_a) || slide.raw["items"]?.try(&.as_a) || slide.raw["cards"]?.try(&.as_a)

      String.build do |str|
        str << "### Slide " << slide_num << ": " << slide.title << " [FAQ / Q&A]\n\n"
        if questions && !questions.empty?
          questions.each do |q_item|
            q_text = q_item["q"]?.try(&.as_s) || q_item["question"]?.try(&.as_s) || q_item["title"]?.try(&.as_s) || ""
            a_text = q_item["a"]?.try(&.as_s) || q_item["answer"]?.try(&.as_s) || q_item["desc"]?.try(&.as_s) || ""
            str << "**Q: " << q_text << "**\n"
            str << "> A: " << a_text << "\n\n"
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
