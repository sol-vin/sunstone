module Sunstone
  module PaletteComponent
    module Icons
      # Canonical FontAwesome SVG icons (fill="currentColor") for zero-dependency rendering.
      PALETTE_SVG = %(<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 512 512"><path fill="currentColor" d="M512 256c0 .9 0 1.8 0 2.7-.4 36.5-33.6 61.3-70.1 61.3L344 320c-26.5 0-48 21.5-48 48 0 3.4 .4 6.7 1 9.9 2.1 10.2 6.5 20 10.8 29.9 6.1 13.8 12.1 27.5 12.1 42 0 31.8-21.6 60.7-53.4 62-3.5 .1-7 .2-10.6 .2-141.4 0-256-114.6-256-256S114.6 0 256 0 512 114.6 512 256zM128 288a32 32 0 1 0 -64 0 32 32 0 1 0 64 0zm0-96a32 32 0 1 0 0-64 32 32 0 1 0 0 64zM288 96a32 32 0 1 0 -64 0 32 32 0 1 0 64 0zm96 96a32 32 0 1 0 0-64 32 32 0 1 0 0 64z"/></svg>)

      DICE_SVG = %(<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 512 512"><path fill="currentColor" d="M141.4 2.3C103-8 63.5 14.8 53.3 53.2L2.5 242.7C-7.8 281.1 15 320.6 53.4 330.9l189.5 50.8c38.4 10.3 77.9-12.5 88.2-50.9l50.8-189.5c10.3-38.4-12.5-77.9-50.9-88.2L141.4 2.3zm23 205.7a32 32 0 1 1 55.4-32 32 32 0 1 1 -55.4 32zM79.2 220.3a32 32 0 1 1 32 55.4 32 32 0 1 1 -32-55.4zm185 96.4a32 32 0 1 1 -32-55.4 32 32 0 1 1 32 55.4zm9-208.4a32 32 0 1 1 32 55.4 32 32 0 1 1 -32-55.4zm-121 14.4a32 32 0 1 1 -32-55.4 32 32 0 1 1 32 55.4zM418 192L377.4 343.2c-17.2 64-83 102-147 84.9l-38.3-10.3 0 30.2c0 35.3 28.7 64 64 64l192 0c35.3 0 64-28.7 64-64l0-192c0-35.3-28.7-64-64-64L418 192z"/></svg>)

      XMARK_SVG = %(<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 384 512"><path fill="currentColor" d="M55.1 73.4c-12.5-12.5-32.8-12.5-45.3 0s-12.5 32.8 0 45.3L147.2 256 9.9 393.4c-12.5 12.5-12.5 32.8 0 45.3s32.8 12.5 45.3 0L192.5 301.3 329.9 438.6c12.5 12.5 32.8 12.5 45.3 0s12.5-32.8 0-45.3L237.8 256 375.1 118.6c12.5-12.5 12.5-32.8 0-45.3s-32.8-12.5-45.3 0L192.5 210.7 55.1 73.4z"/></svg>)

      BRACKET_LEFT_SVG = %(<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 192 512"><path fill="currentColor" d="M0 96C0 60.7 28.7 32 64 32l64 0c17.7 0 32 14.3 32 32s-14.3 32-32 32l-64 0 0 320 64 0c17.7 0 32 14.3 32 32s-14.3 32-32 32l-64 0c-35.3 0-64-28.7-64-64L0 96z"/></svg>)

      BRACKET_RIGHT_SVG = %(<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 192 512"><path fill="currentColor" d="M192 96c0-35.3-28.7-64-64-64L64 32C46.3 32 32 46.3 32 64S46.3 96 64 96l64 0 0 320-64 0c-17.7 0-32 14.3-32 32s14.3 32 32 32l64 0c35.3 0 64-28.7 64-64l0-320z"/></svg>)

      REGISTRY = {
        "palette.svg"              => PALETTE_SVG,
        "dice.svg"                 => DICE_SVG,
        "xmark.svg"                => XMARK_SVG,
        "bracket-square.svg"       => BRACKET_LEFT_SVG,
        "bracket-square-right.svg" => BRACKET_RIGHT_SVG,
      }

      # Renders a FontAwesome SVG icon with the specified CSS class.
      def self.render(filename : String, extra_class : String = "") : String
        clean_name = filename.ends_with?(".svg") ? filename : "#{filename}.svg"
        clean_name = clean_name.sub(%r{^/?icons/}, "")

        raw_svg = REGISTRY[clean_name]? || PALETTE_SVG
        cls = ("project-icon-svg " + extra_class).strip
        if raw_svg.includes?("class=")
          raw_svg.sub(/class=["'][^"']*["']/, %(class="#{cls}"))
        else
          raw_svg.sub("<svg", %(<svg class="#{cls}"))
        end
      end
    end
  end
end
