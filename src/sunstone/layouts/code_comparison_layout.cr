require "./layout_renderer"

module Sunstone
  class CodeComparisonLayout < LayoutRenderer
    def slide_count(slide : Slide) : Int32
      if slide.raw["two_step"]?.try(&.as_bool) == false
        return 1
      end

      has_points = slide.raw["before"]?.try(&.["points"]?) ||
                   slide.raw["after"]?.try(&.["points"]?) ||
                   slide.raw["left"]?.try(&.["points"]?) ||
                   slide.raw["right"]?.try(&.["points"]?) ||
                   slide.raw["gdscript"]?.try(&.["points"]?) ||
                   slide.raw["crystal"]?.try(&.["points"]?) ||
                   slide.raw["points"]? ||
                   slide.raw["takeaway"]?

      has_points ? 2 : 1
    end

    def render_html_all(slide : Slide, deck : Deck, palette : Palette, slide_num : Int32, total_slides : Int32) : String
      if slide_count(slide) == 2
        step1 = render_step1_code_only(slide, deck, palette, slide_num, total_slides)
        step2 = render_step2_critique(slide, deck, palette, slide_num + 1, total_slides)
        "#{step1}\n\n#{step2}"
      else
        render_html(slide, deck, palette, slide_num, total_slides)
      end
    end

    def render_markdown_all(slide : Slide, deck : Deck, palette : Palette, slide_num : Int32, total_slides : Int32) : String
      if slide_count(slide) == 2
        md1 = render_step1_markdown(slide, deck, palette, slide_num, total_slides)
        md2 = render_step2_markdown(slide, deck, palette, slide_num + 1, total_slides)
        "#{md1}#{md2}"
      else
        render_markdown(slide, deck, palette, slide_num, total_slides)
      end
    end

    private def resolve_blocks(slide : Slide)
      left = slide.raw["before"]? || slide.raw["left"]? || slide.raw["gdscript"]?
      right = slide.raw["after"]? || slide.raw["right"]? || slide.raw["crystal"]?
      {left, right}
    end

    # Step 1: Code side-by-side with zero overlay
    def render_step1_code_only(slide : Slide, deck : Deck, palette : Palette, slide_num : Int32, total_slides : Int32) : String
      left, right = resolve_blocks(slide)

      body = String.build do |str|
        badge_header = "<span class=\"badge\">CODE VIEW</span>"
        str << render_slide_header(slide, badge_header) << "\n"
        str << "          <div class=\"slide-body\" data-layout=\"code-comparison\" data-step=\"code-only\">\n"

        if left
          title = left["title"]?.try(&.as_s) || "Existing Pattern"
          lang = left["lang"]?.try(&.as_s) || "python"
          code = left["code"]?.try(&.as_s) || ""
          tag = left["tag"]?.try(&.as_s)
          density = left["density"]?.try(&.as_s)
          str << "            <div class=\"comparison-pane\" data-slot=\"before\">\n"
          str << render_code_container(title, lang, code, tag, density) << "\n"
          str << "            </div>\n"
        end

        if right
          title = right["title"]?.try(&.as_s) || "Improved Solution"
          lang = right["lang"]?.try(&.as_s) || "crystal"
          code = right["code"]?.try(&.as_s) || ""
          tag = right["tag"]?.try(&.as_s)
          density = right["density"]?.try(&.as_s)
          str << "            <div class=\"comparison-pane\" data-slot=\"after\">\n"
          str << render_code_container(title, lang, code, tag, density) << "\n"
          str << "            </div>\n"
        end

        str << "          </div>"
      end

      render_section_wrapper(slide, deck, palette, slide_num, total_slides, body)
    end

    # Step 2: Critique analysis cards and takeaway banner (clean zero-duplicate view)
    def render_step2_critique(slide : Slide, deck : Deck, palette : Palette, slide_num : Int32, total_slides : Int32) : String
      left, right = resolve_blocks(slide)

      body = String.build do |str|
        badge_header = "<span class=\"badge\" data-color=\"accent\">ANALYSIS</span>"
        str << render_slide_header(slide, badge_header) << "\n"
        str << "          <div class=\"slide-body\" data-layout=\"code-comparison\" data-step=\"critique\">\n"

        if left
          points = left["points"]?.try(&.as_a) || slide.raw["points"]?.try(&.as_a)
          card_title = left["card_title"]?.try(&.as_s) || left["critique_title"]?.try(&.as_s) || left["title"]?.try(&.as_s) || "Pitfalls & Anti-Patterns"
          badge_text = left["badge"]?.try(&.as_s) || "ANTI-PATTERN"

          str << "            <div class=\"comparison-pane\" data-slot=\"before\">\n"
          if points && !points.empty?
            items = points.map { |p| LayoutRenderer.extract_item_text(p) }
            str << render_card(card_title, "coral antipattern", items, badge: badge_text) << "\n"
          end
          str << "            </div>\n"
        end

        if right
          points = right["points"]?.try(&.as_a)
          card_title = right["card_title"]?.try(&.as_s) || right["solution_title"]?.try(&.as_s) || right["title"]?.try(&.as_s) || "Advantages & Clean Solution"
          badge_text = right["badge"]?.try(&.as_s) || "CLEAN SOLUTION"

          str << "            <div class=\"comparison-pane\" data-slot=\"after\">\n"
          if points && !points.empty?
            items = points.map { |p| LayoutRenderer.extract_item_text(p) }
            str << render_card(card_title, "emerald solution", items, badge: badge_text) << "\n"
          end
          str << "            </div>\n"
        end

        if takeaway = slide.raw["takeaway"]?
          t_badge = takeaway["badge"]?.try(&.as_s) || "KEY TAKEAWAY"
          t_text = takeaway["text"]?.try(&.as_s) || takeaway.as_s? || ""
          str << "            <div class=\"takeaway-banner\">\n"
          str << "              <span class=\"badge\" data-color=\"accent\">" << LayoutRenderer.escape(t_badge) << "</span>\n"
          str << "              <span class=\"takeaway-text\">" << LayoutRenderer.tint_emojis(t_text) << "</span>\n"
          str << "            </div>\n"
        end

        str << "          </div>"
      end

      render_section_wrapper(slide, deck, palette, slide_num, total_slides, body, custom_id: "#{slide.id}-critique")
    end

    def render_html(slide : Slide, deck : Deck, palette : Palette, slide_num : Int32, total_slides : Int32) : String
      left, right = resolve_blocks(slide)
      has_points = (left && left["points"]?) || (right && right["points"]?) || slide.raw["points"]? || slide.raw["takeaway"]?
      if has_points && slide.raw["two_step"]?.try(&.as_bool) == false
        render_step2_critique(slide, deck, palette, slide_num, total_slides)
      else
        render_step1_code_only(slide, deck, palette, slide_num, total_slides)
      end
    end

    def render_step1_markdown(slide : Slide, deck : Deck, palette : Palette, slide_num : Int32, total_slides : Int32) : String
      left, right = resolve_blocks(slide)
      String.build do |str|
        str << "### Slide " << slide_num << ": " << slide.title << " [Step 1: Code]\n"
        str << "- **Palette**: `" << palette.id << "` | **Badge**: `" << slide.badge << "`\n"
        if left
          str << "- **" << (left["title"]?.try(&.as_s) || "Before") << "**:\n"
          str << "  ```" << (left["lang"]?.try(&.as_s) || "text") << "\n  " << (left["code"]?.try(&.as_s) || "").strip.gsub("\n", "\n  ") << "\n  ```\n"
        end
        if right
          str << "- **" << (right["title"]?.try(&.as_s) || "After") << "**:\n"
          str << "  ```" << (right["lang"]?.try(&.as_s) || "text") << "\n  " << (right["code"]?.try(&.as_s) || "").strip.gsub("\n", "\n  ") << "\n  ```\n"
        end
        str << "\n---\n\n"
      end
    end

    def render_step2_markdown(slide : Slide, deck : Deck, palette : Palette, slide_num : Int32, total_slides : Int32) : String
      left, right = resolve_blocks(slide)
      String.build do |str|
        str << "### Slide " << slide_num << ": " << slide.title << " [Step 2: Analysis & Critique]\n"
        if left && (pts = left["points"]?.try(&.as_a))
          str << "- **Critique Points**:\n"
          pts.each { |p| str << "  - " << LayoutRenderer.clean_text(LayoutRenderer.extract_item_text(p)) << "\n" }
        end
        if right && (pts = right["points"]?.try(&.as_a))
          str << "- **Solution Advantages**:\n"
          pts.each { |p| str << "  - " << LayoutRenderer.clean_text(LayoutRenderer.extract_item_text(p)) << "\n" }
        end
        if takeaway = slide.raw["takeaway"]?
          t_text = takeaway["text"]?.try(&.as_s) || takeaway.as_s? || ""
          str << "- **Key Takeaway**: " << LayoutRenderer.clean_text(t_text) << "\n"
        end
        if !slide.notes.strip.empty?
          str << "\n**Presenter Notes**:\n> " << slide.notes.strip.gsub("\n", "\n> ") << "\n"
        end
        str << "\n---\n\n"
      end
    end

    def render_markdown(slide : Slide, deck : Deck, palette : Palette, slide_num : Int32, total_slides : Int32) : String
      left, right = resolve_blocks(slide)
      has_points = (left && left["points"]?) || (right && right["points"]?) || slide.raw["points"]? || slide.raw["takeaway"]?
      if has_points && slide.raw["two_step"]?.try(&.as_bool) == false
        render_step2_markdown(slide, deck, palette, slide_num, total_slides)
      else
        render_step1_markdown(slide, deck, palette, slide_num, total_slides)
      end
    end
  end
end
