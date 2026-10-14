# Compile-Time & Disk-Backed FontAwesome SVG Icon Registry (`src/web/svgs/*.svg`)
# Inlines theme-aware FontAwesome SVGs into presentation slides with zero external dependencies and zero inline styles.

module Sunstone
  module IconRegistry
    class_property current_theme : String = "generic"

    def self.solvin_theme? : Bool
      norm = @@current_theme.downcase
      norm.includes?("sol.vin") || norm.includes?("solvin") || norm == "retro"
    end

    # Compile-time SVG registry loaded directly from `src/web/svgs/*.svg`.
    SVG_FILES = {
      "arrow-right"          => {{ read_file("src/web/svgs/arrow-right.svg") }},
      "ban"                  => {{ read_file("src/web/svgs/ban.svg") }},
      "bolt"                 => {{ read_file("src/web/svgs/bolt.svg") }},
      "box-archive"          => {{ read_file("src/web/svgs/box-archive.svg") }},
      "box"                  => {{ read_file("src/web/svgs/box.svg") }},
      "bracket-square"       => {{ read_file("src/web/svgs/bracket-square.svg") }},
      "bracket-square-right" => {{ read_file("src/web/svgs/bracket-square-right.svg") }},
      "brain"                => {{ read_file("src/web/svgs/brain.svg") }},
      "bullseye"             => {{ read_file("src/web/svgs/bullseye.svg") }},
      "burst"                => {{ read_file("src/web/svgs/burst.svg") }},
      "calendar"             => {{ read_file("src/web/svgs/calendar.svg") }},
      "chart-simple"         => {{ read_file("src/web/svgs/chart-simple.svg") }},
      "check"                => {{ read_file("src/web/svgs/check.svg") }},
      "circle-check"         => {{ read_file("src/web/svgs/circle-check.svg") }},
      "circle-info"          => {{ read_file("src/web/svgs/circle-info.svg") }},
      "circle-xmark"         => {{ read_file("src/web/svgs/circle-xmark.svg") }},
      "circle"               => {{ read_file("src/web/svgs/circle.svg") }},
      "clipboard"            => {{ read_file("src/web/svgs/clipboard.svg") }},
      "clock"                => {{ read_file("src/web/svgs/clock.svg") }},
      "code"                 => {{ read_file("src/web/svgs/code.svg") }},
      "comment-dots"         => {{ read_file("src/web/svgs/comment-dots.svg") }},
      "crosshairs"           => {{ read_file("src/web/svgs/crosshairs.svg") }},
      "crystal-ball"         => {{ read_file("src/web/svgs/crystal-ball.svg") }},
      "cube"                 => {{ read_file("src/web/svgs/cube.svg") }},
      "dice"                 => {{ read_file("src/web/svgs/dice.svg") }},
      "discord"              => {{ read_file("src/web/svgs/discord.svg") }},
      "download"             => {{ read_file("src/web/svgs/download.svg") }},
      "expand"               => {{ read_file("src/web/svgs/expand.svg") }},
      "explosion"            => {{ read_file("src/web/svgs/explosion.svg") }},
      "feather"              => {{ read_file("src/web/svgs/feather.svg") }},
      "file-pdf"             => {{ read_file("src/web/svgs/file-pdf.svg") }},
      "file"                 => {{ read_file("src/web/svgs/file.svg") }},
      "filter"               => {{ read_file("src/web/svgs/filter.svg") }},
      "flask"                => {{ read_file("src/web/svgs/flask.svg") }},
      "gamepad"              => {{ read_file("src/web/svgs/gamepad.svg") }},
      "gear"                 => {{ read_file("src/web/svgs/gear.svg") }},
      "gem"                  => {{ read_file("src/web/svgs/gem.svg") }},
      "github"               => {{ read_file("src/web/svgs/github.svg") }},
      "globe"                => {{ read_file("src/web/svgs/globe.svg") }},
      "hammer"               => {{ read_file("src/web/svgs/hammer.svg") }},
      "hold-spinner"         => {{ read_file("src/web/svgs/hold-spinner.svg") }},
      "html5"                => {{ read_file("src/web/svgs/html5.svg") }},
      "image"                => {{ read_file("src/web/svgs/image.svg") }},
      "images"               => {{ read_file("src/web/svgs/images.svg") }},
      "joystick"             => {{ read_file("src/web/svgs/joystick.svg") }},
      "lightbulb"            => {{ read_file("src/web/svgs/lightbulb.svg") }},
      "link"                 => {{ read_file("src/web/svgs/link.svg") }},
      "list"                 => {{ read_file("src/web/svgs/list.svg") }},
      "location-dot"         => {{ read_file("src/web/svgs/location-dot.svg") }},
      "magnifying-glass"     => {{ read_file("src/web/svgs/magnifying-glass.svg") }},
      "microchip"            => {{ read_file("src/web/svgs/microchip.svg") }},
      "microphone"           => {{ read_file("src/web/svgs/microphone.svg") }},
      "microscope"           => {{ read_file("src/web/svgs/microscope.svg") }},
      "minus"                => {{ read_file("src/web/svgs/minus.svg") }},
      "palette"              => {{ read_file("src/web/svgs/palette.svg") }},
      "pause"                => {{ read_file("src/web/svgs/pause.svg") }},
      "pdf-cube-icon"        => {{ read_file("src/web/svgs/pdf-cube-icon.svg") }},
      "play"                 => {{ read_file("src/web/svgs/play.svg") }},
      "plug"                 => {{ read_file("src/web/svgs/plug.svg") }},
      "plus"                 => {{ read_file("src/web/svgs/plus.svg") }},
      "robot"                => {{ read_file("src/web/svgs/robot.svg") }},
      "rocket"               => {{ read_file("src/web/svgs/rocket.svg") }},
      "rotate-right"         => {{ read_file("src/web/svgs/rotate-right.svg") }},
      "rss"                  => {{ read_file("src/web/svgs/rss.svg") }},
      "screwdriver-wrench"   => {{ read_file("src/web/svgs/screwdriver-wrench.svg") }},
      "scroll"               => {{ read_file("src/web/svgs/scroll.svg") }},
      "shield-check"         => {{ read_file("src/web/svgs/shield-check.svg") }},
      "shield-halved"        => {{ read_file("src/web/svgs/shield-halved.svg") }},
      "sparkles"             => {{ read_file("src/web/svgs/sparkles.svg") }},
      "star"                 => {{ read_file("src/web/svgs/star.svg") }},
      "steam-symbol"         => {{ read_file("src/web/svgs/steam-symbol.svg") }},
      "steam"                => {{ read_file("src/web/svgs/steam.svg") }},
      "stethoscope"          => {{ read_file("src/web/svgs/stethoscope.svg") }},
      "stop"                 => {{ read_file("src/web/svgs/stop.svg") }},
      "terminal"             => {{ read_file("src/web/svgs/terminal.svg") }},
      "triangle-exclamation" => {{ read_file("src/web/svgs/triangle-exclamation.svg") }},
      "trophy"               => {{ read_file("src/web/svgs/trophy.svg") }},
      "user"                 => {{ read_file("src/web/svgs/user.svg") }},
      "wand-magic-sparkles"  => {{ read_file("src/web/svgs/wand-magic-sparkles.svg") }},
      "whoami-cube-static"   => {{ read_file("src/web/svgs/whoami-cube-static.svg") }},
      "wrench"               => {{ read_file("src/web/svgs/wrench.svg") }},
      "xmark"                => {{ read_file("src/web/svgs/xmark.svg") }},
    }

    ICONS = SVG_FILES

    EMOJI_TO_ICON = {
      "⚡"  => "bolt",
      "💎"  => "gem",
      "🎮"  => "gamepad",
      "🛡️" => "shield-halved",
      "🛡"  => "shield-halved",
      "🏆"  => "trophy",
      "★"  => "star",
      "🎙️" => "microphone",
      "🎙"  => "microphone",
      "❌"  => "circle-xmark",
      "✅"  => "circle-check",
      "✨"  => "sparkles",
      "☀️" => "sparkles",
      "☀"  => "sparkles",
      "🛠️" => "screwdriver-wrench",
      "🛠"  => "screwdriver-wrench",
      "📦"  => "box-archive",
      "💥"  => "burst",
      "⚠️" => "triangle-exclamation",
      "⚠"  => "triangle-exclamation",
      "🚫"  => "ban",
      "🪄"  => "wand-magic-sparkles",
      "💡"  => "lightbulb",
      "🔬"  => "microscope",
      "🔮"  => "crystal-ball",
      "✔"  => "check",
      "✓"  => "check",
      "➔"  => "arrow-right",
      "🔌"  => "plug",
      "🎯"  => "bullseye",
      "🚀"  => "rocket",
      "🧠"  => "brain",
      "🪶"  => "feather",
      "🎨"  => "palette",
      "🎲"  => "dice",
      "🌐"  => "globe",
      "💬"  => "comment-dots",
      "✖"  => "xmark",
      "✕"  => "xmark",
    }

    ALIASES = {
      "shield"        => "shield-halved",
      "warning"       => "triangle-exclamation",
      "error"         => "circle-xmark",
      "success"       => "circle-check",
      "cross"         => "xmark",
      "close"         => "xmark",
      "package"       => "box-archive",
      "box"           => "box-archive",
      "tools"         => "screwdriver-wrench",
      "gear"          => "screwdriver-wrench",
      "wrench"        => "screwdriver-wrench",
      "target"        => "bullseye",
      "game"          => "gamepad",
      "zap"           => "bolt",
      "fire"          => "burst",
      "explosion"     => "burst",
      "check-circle"  => "circle-check",
      "xmark-circle"  => "circle-xmark",
      "sparkle"       => "sparkles",
      "sun"           => "sparkles",
      "magic"         => "wand-magic-sparkles",
      "idea"          => "lightbulb",
      "info"          => "circle-check",
      "arrow"         => "arrow-right",
      "next"          => "arrow-right",
      "book"          => "scroll",
      "docs"          => "scroll",
      "documentation" => "scroll",
      "comments"      => "comment-dots",
      "chat"          => "comment-dots",
      "desktop"       => "terminal",
      "display"       => "terminal",
      "monitor"       => "terminal",
      "paper-plane"   => "rocket",
      "send"          => "rocket",
      "deploy"        => "rocket",
    }

    def self.normalize_icon_name(name : String) : String?
      clean = name.strip
      if clean.starts_with?(':') && clean.ends_with?(':') && clean.size > 2
        clean = clean[1..-2]
      end
      clean = clean.sub(/\.svg\z/, "").sub(%r{^/?(src/web/svgs|assets/vendor/fontawesome/svgs|icons|svgs)/}, "")
      if mapped = EMOJI_TO_ICON[clean]?
        clean = mapped
      end
      if aliased = ALIASES[clean]?
        clean = aliased
      end
      return clean if SVG_FILES.has_key?(clean)
      return clean if File.exists?(File.join("src", "web", "svgs", "#{clean}.svg"))
      return clean if File.exists?(File.join("assets", "vendor", "fontawesome", "svgs", "#{clean}.svg"))
      nil
    end

    def self.has_icon?(name : String) : Bool
      !normalize_icon_name(name).nil?
    end

    # Reads the raw `.svg` content for `icon_name` from `src/web/svgs/` or `assets/vendor/fontawesome/svgs/` on disk first,
    # falling back to compile-time `SVG_FILES`.
    def self.raw_svg(icon_name : String) : String?
      clean = icon_name.sub(/\.svg\z/, "")
      web_path = File.join("src", "web", "svgs", "#{clean}.svg")
      vendor_path = File.join("assets", "vendor", "fontawesome", "svgs", "#{clean}.svg")
      if File.exists?(web_path)
        File.read(web_path).strip
      elsif File.exists?(vendor_path)
        File.read(vendor_path).strip
      else
        SVG_FILES[clean]?.try(&.strip)
      end
    end

    def self.render(name : String, extra_class : String = "") : String
      if icon_name = normalize_icon_name(name)
        if svg_content = raw_svg(icon_name)
          clean_svg = svg_content.gsub(/<!--[\s\S]*?-->/, "").strip
          cls = extra_class.empty? ? "fa-icon fa-#{icon_name}" : "fa-icon fa-#{icon_name} #{extra_class}"
          if clean_svg.includes?("class=")
            clean_svg = clean_svg.sub(/class=["'][^"']*["']/, %(class="#{cls}"))
          else
            clean_svg = clean_svg.sub("<svg", %(<svg class="#{cls}"))
          end
          unless clean_svg.includes?("aria-hidden=")
            clean_svg = clean_svg.sub("<svg", %(<svg aria-hidden="true"))
          end
          return clean_svg
        end
      end
      name
    end

    TAG_REGEX   = /:([a-z0-9_-]+):/
    EMOJI_REGEX = /((\p{Extended_Pictographic}|\p{Emoji_Presentation}|[\x{2600}-\x{27BF}\x{1F300}-\x{1FAFF}★■▲●✖✕])[\x{FE00}-\x{FE0F}\x{200D}]*)/

    def self.replace_icons(text : String, is_solvin : Bool? = nil) : String
      solvin = is_solvin.nil? ? solvin_theme? : is_solvin

      result = text.gsub(TAG_REGEX) do |m, match|
        tag_name = match[1]
        if norm = normalize_icon_name(tag_name)
          render(norm)
        else
          m
        end
      end

      # Strip existing emoji-tint wrapper if re-processing to avoid nesting
      clean = result.gsub(%r{<span class="emoji-tint">([\s\S]*?)</span>}) { |_, match| match[1] }

      clean.gsub(EMOJI_REGEX) do |m|
        if solvin
          %(<span class="emoji-tint">#{m}</span>)
        elsif norm = normalize_icon_name(m)
          render(norm)
        else
          %(<span class="emoji-tint">#{m}</span>)
        end
      end
    end
  end
end
