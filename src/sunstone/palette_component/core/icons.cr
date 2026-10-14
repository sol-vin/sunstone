require "json"

module Sunstone
  module PaletteComponent
    module Icons
      # Canonical FontAwesome & UI SVG icons loaded at compile-time from `src/web/svgs/*.svg`.
      PALETTE_SVG            = {{ read_file("src/web/svgs/palette.svg") }}
      DICE_SVG               = {{ read_file("src/web/svgs/dice.svg") }}
      XMARK_SVG              = {{ read_file("src/web/svgs/xmark.svg") }}
      BRACKET_LEFT_SVG       = {{ read_file("src/web/svgs/bracket-square.svg") }}
      BRACKET_RIGHT_SVG      = {{ read_file("src/web/svgs/bracket-square-right.svg") }}
      HOLD_SPINNER_SVG       = {{ read_file("src/web/svgs/hold-spinner.svg") }}
      WHOAMI_CUBE_STATIC_SVG = {{ read_file("src/web/svgs/whoami-cube-static.svg") }}
      PDF_CUBE_ICON_SVG      = {{ read_file("src/web/svgs/pdf-cube-icon.svg") }}

      # Compile-time UI icon map loaded directly from `src/web/svgs/*.svg` for `ICONS.to_json` client injection.
      ICONS = {
        "brain"            => {{ read_file("src/web/svgs/brain.svg") }},
        "boxArchive"       => {{ read_file("src/web/svgs/box-archive.svg") }},
        "bolt"             => {{ read_file("src/web/svgs/bolt.svg") }},
        "commentDots"      => {{ read_file("src/web/svgs/comment-dots.svg") }},
        "github"           => {{ read_file("src/web/svgs/github.svg") }},
        "chartSimple"      => {{ read_file("src/web/svgs/chart-simple.svg") }},
        "terminal"         => {{ read_file("src/web/svgs/terminal.svg") }},
        "lightbulb"        => {{ read_file("src/web/svgs/lightbulb.svg") }},
        "rotate"           => {{ read_file("src/web/svgs/rotate-right.svg") }},
        "palette"          => PALETTE_SVG,
        "dice"             => DICE_SVG,
        "shield"           => {{ read_file("src/web/svgs/shield-check.svg") }},
        "check"            => {{ read_file("src/web/svgs/circle-check.svg") }},
        "xmark"            => {{ read_file("src/web/svgs/circle-xmark.svg") }},
        "triangle"         => {{ read_file("src/web/svgs/triangle-exclamation.svg") }},
        "pause"            => {{ read_file("src/web/svgs/pause.svg") }},
        "play"             => {{ read_file("src/web/svgs/play.svg") }},
        "ban"              => {{ read_file("src/web/svgs/ban.svg") }},
        "box"              => {{ read_file("src/web/svgs/box.svg") }},
        "cube"             => {{ read_file("src/web/svgs/cube.svg") }},
        "gear"             => {{ read_file("src/web/svgs/gear.svg") }},
        "file"             => {{ read_file("src/web/svgs/file.svg") }},
        "robot"            => {{ read_file("src/web/svgs/robot.svg") }},
        "stop"             => {{ read_file("src/web/svgs/stop.svg") }},
        "times"            => XMARK_SVG,
        "bracketLeft"      => BRACKET_LEFT_SVG,
        "bracketRight"     => BRACKET_RIGHT_SVG,
        "list"             => {{ read_file("src/web/svgs/list.svg") }},
        "clock"            => {{ read_file("src/web/svgs/clock.svg") }},
        "plus"             => {{ read_file("src/web/svgs/plus.svg") }},
        "minus"            => {{ read_file("src/web/svgs/minus.svg") }},
        "info"             => {{ read_file("src/web/svgs/circle-info.svg") }},
        "code"             => {{ read_file("src/web/svgs/code.svg") }},
        "arrowRight"       => {{ read_file("src/web/svgs/arrow-right.svg") }},
        "expand"           => {{ read_file("src/web/svgs/expand.svg") }},
        "image"            => {{ read_file("src/web/svgs/image.svg") }},
        "images"           => {{ read_file("src/web/svgs/images.svg") }},
        "microchip"        => {{ read_file("src/web/svgs/microchip.svg") }},
        "sparkles"         => {{ read_file("src/web/svgs/sparkles.svg") }},
        "star"             => {{ read_file("src/web/svgs/star.svg") }},
        "trophy"           => {{ read_file("src/web/svgs/trophy.svg") }},
        "gamepad"          => {{ read_file("src/web/svgs/gamepad.svg") }},
        "holdSpinner"      => HOLD_SPINNER_SVG,
        "whoamiCubeStatic" => WHOAMI_CUBE_STATIC_SVG,
        "pdfCubeIcon"      => PDF_CUBE_ICON_SVG,
      }

      # Compile-time Division icon map loaded directly from `src/web/svgs/*.svg`.
      DIVISION_ICONS = {
        "executive"                => {{ read_file("src/web/svgs/trophy.svg") }},
        "div:1-exec"               => {{ read_file("src/web/svgs/trophy.svg") }},
        "management"               => {{ read_file("src/web/svgs/screwdriver-wrench.svg") }},
        "div:2-mgmt"               => {{ read_file("src/web/svgs/screwdriver-wrench.svg") }},
        "creative_media"           => PALETTE_SVG,
        "div:3-design"             => PALETTE_SVG,
        "game_design_engine"       => {{ read_file("src/web/svgs/gamepad.svg") }},
        "div:4-godot"              => {{ read_file("src/web/svgs/gamepad.svg") }},
        "systems_forensics"        => {{ read_file("src/web/svgs/microscope.svg") }},
        "div:5-lowlevel"           => {{ read_file("src/web/svgs/microscope.svg") }},
        "crystal_applications"     => {{ read_file("src/web/svgs/gem.svg") }},
        "div:6-crystal"            => {{ read_file("src/web/svgs/gem.svg") }},
        "media_assets"             => {{ read_file("src/web/svgs/cube.svg") }},
        "div:7-assets"             => {{ read_file("src/web/svgs/cube.svg") }},
        "devops_security"          => {{ read_file("src/web/svgs/shield-halved.svg") }},
        "div:8-devops"             => {{ read_file("src/web/svgs/shield-halved.svg") }},
        "knowledge_publishing"     => {{ read_file("src/web/svgs/scroll.svg") }},
        "div:9-docs"               => {{ read_file("src/web/svgs/scroll.svg") }},
        "performance_intelligence" => {{ read_file("src/web/svgs/bolt.svg") }},
        "div:10-perf"              => {{ read_file("src/web/svgs/bolt.svg") }},
      }

      REGISTRY = {
        "palette.svg"              => PALETTE_SVG,
        "dice.svg"                 => DICE_SVG,
        "xmark.svg"                => XMARK_SVG,
        "bracket-square.svg"       => BRACKET_LEFT_SVG,
        "bracket-square-right.svg" => BRACKET_RIGHT_SVG,
        "hold-spinner.svg"         => HOLD_SPINNER_SVG,
        "whoami-cube-static.svg"   => WHOAMI_CUBE_STATIC_SVG,
        "pdf-cube-icon.svg"        => PDF_CUBE_ICON_SVG,
        "arrow-right.svg"          => ICONS["arrowRight"],
        "github.svg"               => ICONS["github"],
        "sparkles.svg"             => ICONS["sparkles"],
        "plus.svg"                 => ICONS["plus"],
        "minus.svg"                => ICONS["minus"],
        "expand.svg"               => ICONS["expand"],
        "image.svg"                => ICONS["image"],
        "images.svg"               => ICONS["images"],
        "microchip.svg"            => ICONS["microchip"],
        "star.svg"                 => ICONS["star"],
        "trophy.svg"               => ICONS["trophy"],
        "gamepad.svg"              => ICONS["gamepad"],
        "rotate-right.svg"         => ICONS["rotate"],
        "code.svg"                 => ICONS["code"],
      }

      def self.[](key : String) : String
        ICONS[key]? || REGISTRY[key]? || ""
      end

      def self.division_icon(key : String) : String
        DIVISION_ICONS[key]? || ""
      end

      # Returns the pre-rendered FontAwesome SVG map for `PaletteEngine` and `HoldClick` JS injection.
      def self.palette_js_icons : Hash(String, String)
        {
          "palette"      => render("palette.svg"),
          "dice"         => render("dice.svg"),
          "xmark"        => render("xmark.svg"),
          "bracketLeft"  => render("bracket-square.svg"),
          "bracketRight" => render("bracket-square-right.svg"),
          "holdSpinner"  => HOLD_SPINNER_SVG.strip,
        }
      end

      def self.js_icons_json : String
        palette_js_icons.to_json
      end

      def self.icons_json : String
        ICONS.to_json
      end

      def self.division_icons_json : String
        DIVISION_ICONS.to_json
      end

      # Renders a FontAwesome SVG icon with the specified CSS class.
      # Checks `src/web/svgs/<name>` and `assets/vendor/fontawesome/svgs/<name>` on disk first, falling back to compile-time `REGISTRY`.
      def self.render(filename : String, extra_class : String = "") : String
        clean_name = filename.ends_with?(".svg") ? filename : "#{filename}.svg"
        clean_name = clean_name.sub(%r{^/?icons/}, "").sub(%r{^/?svgs/}, "")

        web_svg_path = File.join("src", "web", "svgs", clean_name)
        vendor_svg_path = File.join("assets", "vendor", "fontawesome", "svgs", clean_name)
        raw_svg = if File.exists?(web_svg_path)
                    File.read(web_svg_path).strip
                  elsif File.exists?(vendor_svg_path)
                    File.read(vendor_svg_path).strip
                  else
                    (REGISTRY[clean_name]? || PALETTE_SVG).strip
                  end

        cls = ("project-icon-svg " + extra_class).strip
        if raw_svg.includes?("class=")
          raw_svg.sub(/class=["'][^"']*["']/, %(class="#{cls}"))
        else
          raw_svg.sub("<svg", %(<svg class="#{cls}"))
        end
      end

      # Returns the raw SVG content from `src/web/svgs/<name>` or `assets/vendor/fontawesome/svgs/<name>` without overriding its class attribute.
      def self.raw(filename : String) : String
        clean_name = filename.ends_with?(".svg") ? filename : "#{filename}.svg"
        clean_name = clean_name.sub(%r{^/?icons/}, "").sub(%r{^/?svgs/}, "")

        web_svg_path = File.join("src", "web", "svgs", clean_name)
        vendor_svg_path = File.join("assets", "vendor", "fontawesome", "svgs", clean_name)
        if File.exists?(web_svg_path)
          File.read(web_svg_path).strip
        elsif File.exists?(vendor_svg_path)
          File.read(vendor_svg_path).strip
        else
          (REGISTRY[clean_name]? || "").strip
        end
      end
    end
  end
end
