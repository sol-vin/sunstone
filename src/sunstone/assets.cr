require "json"
require "file_utils"

module Sunstone
  module Assets
    BASE_CSS                 = {{ read_file("#{__DIR__}/../../assets/themes/sunstone-base.css") }}
    GENERIC_CSS              = {{ read_file("#{__DIR__}/../../assets/themes/generic.css") }}
    SOLVIN_CSS               = {{ read_file("#{__DIR__}/../../assets/themes/sol.vin.css") }}
    NORDIC_CSS               = {{ read_file("#{__DIR__}/../../assets/themes/nordic.css") }}
    BRUTALIST_CSS            = {{ read_file("#{__DIR__}/../../assets/themes/brutalist.css") }}
    ACADEMIC_CSS             = {{ read_file("#{__DIR__}/../../assets/themes/academic.css") }}
    TOKYO_NIGHT_CSS          = {{ read_file("#{__DIR__}/../../assets/themes/tokyo-night.css") }}

    GENERIC_PALETTES_JSON     = {{ read_file("#{__DIR__}/../../assets/themes/generic_palettes.json") }}
    SOLVIN_PALETTES_JSON      = {{ read_file("#{__DIR__}/../../assets/themes/solvin_palettes.json") }}
    NORDIC_PALETTES_JSON      = {{ read_file("#{__DIR__}/../../assets/themes/nordic_palettes.json") }}
    BRUTALIST_PALETTES_JSON   = {{ read_file("#{__DIR__}/../../assets/themes/brutalist_palettes.json") }}
    ACADEMIC_PALETTES_JSON    = {{ read_file("#{__DIR__}/../../assets/themes/academic_palettes.json") }}
    TOKYO_NIGHT_PALETTES_JSON = {{ read_file("#{__DIR__}/../../assets/themes/tokyo_night_palettes.json") }}

    SOLVIN_CUBE_JS           = {{ read_file("#{__DIR__}/../../assets/themes/sol.vin/cube.js") }}
    USER_CI_YML              = {{ read_file("#{__DIR__}/../../assets/user_ci.yml") }}

    # Reveal.js assets
    REVEAL_CSS       = {{ read_file("#{__DIR__}/../../assets/vendor/reveal/reveal.min.css") }}
    REVEAL_JS        = {{ read_file("#{__DIR__}/../../assets/vendor/reveal/reveal.min.js") }}
    REVEAL_HIGHLIGHT = {{ read_file("#{__DIR__}/../../assets/vendor/reveal/plugin/highlight/highlight.min.js") }}
    REVEAL_NOTES     = {{ read_file("#{__DIR__}/../../assets/vendor/reveal/plugin/notes/notes.min.js") }}

    # Highlight.js assets
    HLJS_JS         = {{ read_file("#{__DIR__}/../../assets/vendor/highlight/highlight.min.js") }}
    HLJS_ATOM_CSS   = {{ read_file("#{__DIR__}/../../assets/vendor/highlight/styles/atom-one-dark.min.css") }}
    HLJS_CRYSTAL_JS = {{ read_file("#{__DIR__}/../../assets/vendor/highlight/languages/crystal.min.js") }}
    HLJS_RUST_JS    = {{ read_file("#{__DIR__}/../../assets/vendor/highlight/languages/rust.min.js") }}
    HLJS_CPP_JS     = {{ read_file("#{__DIR__}/../../assets/vendor/highlight/languages/cpp.min.js") }}
    HLJS_PYTHON_JS   = {{ read_file("#{__DIR__}/../../assets/vendor/highlight/languages/python.min.js") }}
    HLJS_GDSCRIPT_JS = {{ read_file("#{__DIR__}/../../assets/vendor/highlight/languages/gdscript.min.js") }}

    # Asciinema player assets
    ASCIINEMA_CSS = {{ read_file("#{__DIR__}/../../assets/vendor/asciinema/asciinema-player.css") }}
    ASCIINEMA_JS  = {{ read_file("#{__DIR__}/../../assets/vendor/asciinema/asciinema-player.min.js") }}

    BUILTIN_THEMES = [
      "generic",
      "sol.vin",
      "nordic",
      "brutalist",
      "academic",
      "tokyo-night",
    ]

    def self.available_themes : Array(String)
      BUILTIN_THEMES
    end

    def self.scaffold_vendor(target_dir : String)
      vendor_dir = File.join(target_dir, "vendor")

      # Reveal.js
      reveal_dir = File.join(vendor_dir, "reveal")
      Dir.mkdir_p(File.join(reveal_dir, "plugin/highlight"))
      Dir.mkdir_p(File.join(reveal_dir, "plugin/notes"))
      File.write(File.join(reveal_dir, "reveal.min.css"), REVEAL_CSS)
      File.write(File.join(reveal_dir, "reveal.min.js"), REVEAL_JS)
      File.write(File.join(reveal_dir, "plugin/highlight/highlight.min.js"), REVEAL_HIGHLIGHT)
      File.write(File.join(reveal_dir, "plugin/notes/notes.min.js"), REVEAL_NOTES)

      # Highlight.js
      hljs_dir = File.join(vendor_dir, "highlight")
      Dir.mkdir_p(File.join(hljs_dir, "styles"))
      Dir.mkdir_p(File.join(hljs_dir, "languages"))
      File.write(File.join(hljs_dir, "highlight.min.js"), HLJS_JS)
      File.write(File.join(hljs_dir, "styles/atom-one-dark.min.css"), HLJS_ATOM_CSS)
      File.write(File.join(hljs_dir, "languages/crystal.min.js"), HLJS_CRYSTAL_JS)
      File.write(File.join(hljs_dir, "languages/rust.min.js"), HLJS_RUST_JS)
      File.write(File.join(hljs_dir, "languages/cpp.min.js"), HLJS_CPP_JS)
      File.write(File.join(hljs_dir, "languages/python.min.js"), HLJS_PYTHON_JS)
      File.write(File.join(hljs_dir, "languages/gdscript.min.js"), HLJS_GDSCRIPT_JS)

      # Asciinema
      asciinema_dir = File.join(vendor_dir, "asciinema")
      Dir.mkdir_p(asciinema_dir)
      File.write(File.join(asciinema_dir, "asciinema-player.css"), ASCIINEMA_CSS)
      File.write(File.join(asciinema_dir, "asciinema-player.min.js"), ASCIINEMA_JS)
    end

    def self.theme_css_for(theme_name : String) : String
      # Support direct local CSS file path (e.g. "./custom_theme.css")
      if (theme_name.ends_with?(".css") || File.exists?(theme_name)) && File.file?(theme_name)
        return File.read(theme_name)
      end

      case theme_name.downcase.gsub("_", "-")
      when "sol.vin", "solvin", "retro"
        SOLVIN_CSS
      when "nordic", "scandinavian", "ice"
        NORDIC_CSS
      when "brutalist", "neo-brutalist", "swiss"
        BRUTALIST_CSS
      when "academic", "latex", "beamer", "scholarly"
        ACADEMIC_CSS
      when "tokyo-night", "tokyonight", "cyberpunk", "ide"
        TOKYO_NIGHT_CSS
      else
        GENERIC_CSS
      end
    end

    def self.palettes_json_for(theme_name : String) : String
      # If theme is a direct CSS file, check if a companion .json exists (e.g. theme.json)
      if (theme_name.ends_with?(".css") || File.exists?(theme_name)) && File.file?(theme_name)
        companion_json = theme_name.sub(/\.css\z/, ".json")
        if File.exists?(companion_json)
          return File.read(companion_json)
        end
      end

      case theme_name.downcase.gsub("_", "-")
      when "sol.vin", "solvin", "retro"
        SOLVIN_PALETTES_JSON
      when "nordic", "scandinavian", "ice"
        NORDIC_PALETTES_JSON
      when "brutalist", "neo-brutalist", "swiss"
        BRUTALIST_PALETTES_JSON
      when "academic", "latex", "beamer", "scholarly"
        ACADEMIC_PALETTES_JSON
      when "tokyo-night", "tokyonight", "cyberpunk", "ide"
        TOKYO_NIGHT_PALETTES_JSON
      else
        GENERIC_PALETTES_JSON
      end
    end
  end
end
