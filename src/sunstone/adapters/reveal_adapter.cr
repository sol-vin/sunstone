require "html"
require "../models/deck"
require "../models/slide"

module Sunstone
  module Adapters
    # Two-Tier Reveal.js presentation adapter
    # Transforms Sunstone semantic slide decks into standard Reveal.js 5.x HTML
    class RevealAdapter
      getter deck : Deck
      property theme : String
      property transition : String
      property include_notes : Bool

      def initialize(@deck : Deck, @theme : String = "black", @transition : String = "slide", @include_notes : Bool = true)
      end

      # Tier 1: Core rendering engine
      def render : String
        String.build do |io|
          io.puts "<!doctype html>"
          io.puts "<html lang=\"en\">"
          io.puts "<head>"
          io.puts "  <meta charset=\"utf-8\">"
          io.puts "  <meta name=\"viewport\" content=\"width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no\">"
          io.puts "  <title>#{HTML.escape(@deck.title)}</title>"
          io.puts "  <link rel=\"stylesheet\" href=\"https://cdn.jsdelivr.net/npm/reveal.js@5.0.4/dist/reveal.css\">"
          io.puts "  <link rel=\"stylesheet\" href=\"https://cdn.jsdelivr.net/npm/reveal.js@5.0.4/dist/theme/#{@theme}.css\" id=\"theme\">"
          io.puts "  <link rel=\"stylesheet\" href=\"https://cdn.jsdelivr.net/npm/reveal.js@5.0.4/plugin/highlight/monokai.css\">"
          io.puts "  <style>"
          io.puts "    .reveal .slides section { text-align: left; }"
          io.puts "    .reveal h1, .reveal h2, .reveal h3 { text-transform: none; }"
          io.puts "    .sunstone-badge { display: inline-block; padding: 2px 8px; font-size: 0.5em; border-radius: 4px; background: rgba(56, 189, 248, 0.2); color: #38bdf8; }"
          io.puts "  </style>"
          io.puts "</head>"
          io.puts "<body>"
          io.puts "  <div class=\"reveal\">"
          io.puts "    <div class=\"slides\">"

          @deck.slides.each_with_index do |slide, idx|
            io.puts render_slide(slide, idx + 1)
          end

          io.puts "    </div>"
          io.puts "  </div>"
          io.puts "  <script src=\"https://cdn.jsdelivr.net/npm/reveal.js@5.0.4/dist/reveal.js\"></script>"
          io.puts "  <script src=\"https://cdn.jsdelivr.net/npm/reveal.js@5.0.4/plugin/highlight/highlight.js\"></script>"
          io.puts "  <script src=\"https://cdn.jsdelivr.net/npm/reveal.js@5.0.4/plugin/notes/notes.js\"></script>"
          io.puts "  <script>"
          io.puts "    Reveal.initialize({"
          io.puts "      hash: true,"
          io.puts "      slideNumber: 'c/t',"
          io.puts "      transition: '#{@transition}',"
          io.puts "      plugins: [ RevealHighlight, RevealNotes ]"
          io.puts "    });"
          io.puts "  </script>"
          io.puts "</body>"
          io.puts "</html>"
        end
      end

      # Renders an individual slide into a Reveal.js <section> element
      def render_slide(slide : Slide, slide_number : Int32) : String
        bg = slide["background"]?.try(&.as_s)
        bg_attr = bg ? " data-background=\"#{HTML.escape(bg)}\"" : ""
        trans = slide["transition"]?.try(&.as_s) || @transition
        trans_attr = " data-transition=\"#{HTML.escape(trans)}\""

        String.build do |io|
          io.puts "      <section#{bg_attr}#{trans_attr} id=\"slide-#{slide_number}\" data-layout=\"#{HTML.escape(slide.layout)}\">"

          # Slide header
          if !slide.title.empty?
            io.puts "        <h2>#{HTML.escape(slide.title)}</h2>"
          end

          if !slide.subtitle.empty?
            io.puts "        <h4 style=\"color: #94a3b8;\">#{HTML.escape(slide.subtitle)}</h4>"
          end

          # Body content
          body_text = slide.content
          if !body_text.empty?
            io.puts "        <div class=\"content\">"
            body_text.each_line do |line|
              io.puts "          <p>#{HTML.escape(line)}</p>"
            end
            io.puts "        </div>"
          end

          # Bullets list if present
          bullets = slide.bullets
          if !bullets.empty?
            io.puts "        <ul>"
            bullets.each do |bullet|
              io.puts "          <li>#{HTML.escape(bullet)}</li>"
            end
            io.puts "        </ul>"
          end

          # Code block if present
          if code_val = slide["code"]?.try(&.as_s)
            lang = slide["code_lang"]?.try(&.as_s) || slide["lang"]?.try(&.as_s) || "crystal"
            io.puts "        <pre><code class=\"language-#{HTML.escape(lang)}\">#{HTML.escape(code_val)}</code></pre>"
          end

          # Speaker notes
          if @include_notes && !slide.notes.empty?
            io.puts "        <aside class=\"notes\">"
            io.puts "          #{HTML.escape(slide.notes)}"
            io.puts "        </aside>"
          end

          io.puts "      </section>"
        end
      end
    end
  end

  # Tier 2: Declarative Builder DSL
  def self.to_reveal(deck : Deck, theme : String = "black", transition : String = "slide") : String
    Adapters::RevealAdapter.new(deck, theme: theme, transition: transition).render
  end
end

class Sunstone::Deck
  # Ergonomic extension on Deck
  def to_reveal(theme : String = "black", transition : String = "slide") : String
    Sunstone.to_reveal(self, theme: theme, transition: transition)
  end
end
