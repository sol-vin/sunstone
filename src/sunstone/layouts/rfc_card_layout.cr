require "./layout_renderer"
require "../rfc_card"

module Sunstone
  # Dedicated semantic slide layout for rendering `[AS-X]` Architectural Decision Matrices (`rfc-card` / `rfc_card`).
  class RfcCardLayout < LayoutRenderer
    def render_html(slide : Slide, deck : Deck, palette : Palette, slide_num : Int32, total_slides : Int32) : String
      card_node = slide.raw["rfc_card"]? || slide.raw["rfc-card"]? || slide.raw
      spec = RfcCard::RfcCardSpec.from_yaml(card_node)

      # If top-level slide properties are set and card_node was a nested sub-map, inherit slide title/badge if default
      if spec.title == "Architectural Decision Matrix" && !slide.title.empty?
        spec = RfcCard::RfcCardSpec.new(
          rfc_id: spec.rfc_id,
          discussion_number: spec.discussion_number,
          title: slide.title,
          subtitle: spec.subtitle.empty? ? slide.subtitle : spec.subtitle,
          badge: spec.badge,
          color: spec.color,
          status: spec.status,
          author: spec.author.empty? ? slide.author : spec.author,
          target_repo: spec.target_repo,
          discussion_url: spec.discussion_url,
          summary: spec.summary,
          compact: spec.compact,
          window_chrome: spec.window_chrome,
          show_matrix_table: spec.show_matrix_table,
          suggestions: spec.suggestions,
          council_comments: spec.council_comments
        )
      end

      body = String.build do |str|
        str << render_slide_header(slide) << "\n"
        str << "          <div class=\"slide-body\" data-layout=\"rfc-card\">\n"
        str << render_rfc_card(spec) << "\n"
        str << "          </div>"
      end

      render_section_wrapper(slide, deck, palette, slide_num, total_slides, body)
    end

    def render_markdown(slide : Slide, deck : Deck, palette : Palette, slide_num : Int32, total_slides : Int32) : String
      card_node = slide.raw["rfc_card"]? || slide.raw["rfc-card"]? || slide.raw
      spec = RfcCard::RfcCardSpec.from_yaml(card_node)

      String.build do |str|
        str << "### Slide " << slide_num << ": " << slide.title << "\n"
        str << "- **Theme Palette**: `" << palette.id << "` (" << palette.name << ")\n"
        str << "- **Badge**: `" << slide.badge << "`\n"
        str << "- **Title**: " << slide.title << "\n"
        unless slide.subtitle.strip.empty?
          str << "- **Subtitle**: " << slide.subtitle << "\n"
        end
        str << RfcCard.render_markdown(spec)
        if !slide.notes.strip.empty?
          str << "\n**Presenter Notes**:\n> " << slide.notes.strip.gsub("\n", "\n> ") << "\n"
        end
        str << "\n---\n\n"
      end
    end
  end
end
