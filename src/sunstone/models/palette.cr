require "json"

module Sunstone
  class Palette
    getter id : String
    getter name : String
    getter colors : Hash(String, String)

    def initialize(@id : String, @name : String, @colors : Hash(String, String))
    end

    def self.load_all(json_content : String) : Hash(String, Palette)
      parsed = JSON.parse(json_content)
      result = Hash(String, Palette).new

      if items = parsed.as_a?
        items.each do |item|
          id = item["id"].as_s
          name = item["name"]?.try(&.as_s) || id
          colors_map = Hash(String, String).new
          if colors = item["colors"]?.try(&.as_h)
            colors.each do |k, v|
              colors_map[k] = v.as_s
            end
          else
            item.as_h.each do |k, v|
              colors_map[k] = v.as_s if v.as_s? && k != "id" && k != "name"
            end
          end
          result[id] = Palette.new(id, name, colors_map)
        end
      elsif hash = parsed.as_h?
        hash.each do |key, val|
          id = val["id"]?.try(&.as_s) || key
          name = val["name"]?.try(&.as_s) || id
          colors_map = Hash(String, String).new
          if colors = val["colors"]?.try(&.as_h)
            colors.each do |k, v|
              colors_map[k] = v.as_s
            end
          else
            val.as_h.each do |k, v|
              colors_map[k] = v.as_s if v.as_s? && k != "id" && k != "name"
            end
          end
          result[id] = Palette.new(id, name, colors_map)
        end
      end

      result
    end

    def self.load_for_theme(theme_name : String, custom_palettes : Hash(String, Palette)? = nil) : Hash(String, Palette)
      json_str = Assets.palettes_json_for(theme_name)
      palettes = load_all(json_str)

      if custom_palettes
        custom_palettes.each do |k, v|
          palettes[k] = v
        end
      end

      palettes
    end

    # Maps generic/semantic palette names to the native equivalent in the target theme
    def self.map_theme_palette_alias(requested_id : String, theme_name : String) : String?
      norm_theme = theme_name.downcase.gsub("_", "-")
      norm_id = requested_id.downcase.gsub("-", "_")

      case norm_theme
      when "academic", "latex", "beamer", "scholarly"
        case norm_id
        when "slate_dark", "monolith", "storm", "inversion", "dark", "black"
          "gothic_dark"
        when "nordic_ice", "nord_frost", "ocean_blue", "accent", "cambridge"
          "cambridge_blue"
        when "emerald_matrix", "aurora", "green", "emerald_manuscript"
          "emerald_manuscript"
        when "candy", "amber", "sunset_amber", "crimson", "crimson_obsidian", "oxford"
          "oxford_crimson"
        when "chalkboard", "blackboard", "blackboard_latex"
          "blackboard_latex"
        when "paper_light", "snow_storm", "warm_paper", "light", "default"
          "computer_modern"
        else
          "computer_modern"
        end

      when "sol.vin", "solvin", "retro"
        case norm_id
        when "slate_dark", "monolith", "storm", "dark"
          "inversion"
        when "nordic_ice"
          "nord_frost"
        when "emerald_matrix", "aurora"
          "fos"
        when "ocean_blue"
          "amigo"
        when "amber", "sunset_amber"
          "a64_pal"
        when "neon", "cyber_neon"
          "pico_8"
        when "midnight_indigo", "black"
          "black_cube"
        when "paper_light", "computer_modern", "light", "default"
          "warm_paper"
        else
          nil
        end

      when "nordic", "scandinavian", "ice"
        case norm_id
        when "slate_dark", "monolith", "storm", "inversion", "dark", "polar"
          "fjord_deep"
        when "nordic_ice", "nord_frost", "ocean_blue", "default", "accent"
          "fjord_deep"
        when "emerald_matrix", "neon", "cyber_neon", "aurora", "green"
          "aurora_night"
        when "paper_light", "computer_modern", "warm_paper", "light", "snow", "white"
          "glacier_frost"
        when "candy", "amber", "sunset_amber", "yellow"
          "midnight_sun"
        when "crimson_obsidian", "twilight", "purple"
          "arctic_twilight"
        else
          "fjord_deep"
        end

      when "brutalist", "neo-brutalist", "swiss"
        case norm_id
        when "slate_dark", "inversion", "storm", "dark", "black", "default", "yellow"
          "yellow_hazard"
        when "paper_light", "light", "warm_paper", "white", "clean_light"
          "paper_ink"
        when "emerald_matrix", "neon", "green"
          "electric_lime"
        when "amber", "sunset_amber", "orange"
          "orange_warning"
        when "nordic_ice", "ocean_blue", "blue"
          "cobalt_blueprint"
        when "crimson_obsidian", "magenta", "cyber_neon", "pink", "accent"
          "hot_magenta"
        else
          "yellow_hazard"
        end

      when "tokyo-night", "tokyonight", "cyberpunk", "ide"
        case norm_id
        when "slate_dark", "inversion", "default"
          "tokyo_night"
        when "nordic_ice", "ocean_blue", "storm"
          "tokyo_storm"
        when "cyber_neon", "accent", "neon"
          "cyber_pulse"
        when "midnight_indigo", "dark", "black"
          "catppuccin_mocha"
        when "crimson_obsidian", "dracula"
          "dracula_vampire"
        when "paper_light", "warm_paper", "light", "sunset_amber", "sakura"
          "sakura_bloom"
        else
          "tokyo_night"
        end

      else # Generic
        case norm_id
        when "default", "dark"
          "slate_dark"
        when "light", "paper_light", "computer_modern", "warm_paper"
          "paper_light"
        when "accent", "amigo", "blue", "cyan"
          "ocean_blue"
        else
          nil
        end
      end
    end

    def self.resolve_for_theme(requested_id : String, theme_name : String, theme_palettes : Hash(String, Palette), default_palette_id : String? = nil) : Palette
      norm_id = requested_id.strip
      
      # 1. Exact match in the theme's own catalog
      if p = theme_palettes[norm_id]?
        return p
      end

      # 2. Case-insensitive or underscore/hyphen match in theme catalog
      clean_id = norm_id.downcase.gsub("-", "_")
      if p = theme_palettes[clean_id]?
        return p
      end

      # 3. Theme-specific semantic alias mapping
      if mapped = map_theme_palette_alias(norm_id, theme_name)
        if p = theme_palettes[mapped]?
          return p
        end
      end

      # 4. Fall back to theme's designated default palette
      if default_palette_id && (p = theme_palettes[default_palette_id]?)
        return p
      end

      # 5. Fall back to first palette in the theme's catalog
      theme_palettes.values.first? || Palette.new("fallback", "Default", Hash(String, String).new)
    end

    @@all_palettes_cache : Hash(String, Palette)? = nil

    # Finds a palette by ID across all built-in theme catalogs
    def self.find_palette(id : String) : Palette?
      cache = @@all_palettes_cache ||= begin
        map = Hash(String, Palette).new
        Assets.available_themes.each do |theme_name|
          begin
            json = Assets.palettes_json_for(theme_name)
            load_all(json).each do |k, v|
              map[k] = v unless map.has_key?(k)
            end
          rescue
          end
        end
        map
      end
      cache[id]?
    end

    # Modern Generic Theme Color Accessors
    def bg_color : String
      @colors["bg_color"]? || "#0f172a"
    end

    def surface_color : String
      @colors["surface_color"]? || @colors["bg_window"]? || "#1e293b"
    end

    def surface_hover : String
      @colors["surface_hover"]? || "#273549"
    end

    def text_primary : String
      @colors["text_primary"]? || @colors["text_color"]? || "#f8fafc"
    end

    def text_secondary : String
      @colors["text_secondary"]? || "#cbd5e1"
    end

    def text_muted : String
      @colors["text_muted"]? || @colors["text_dim"]? || "#94a3b8"
    end

    def accent_color : String
      @colors["accent_color"]? || "#38bdf8"
    end

    def accent_secondary : String
      @colors["accent_secondary"]? || "#818cf8"
    end

    def accent_tertiary : String
      @colors["accent_tertiary"]? || "#34d399"
    end

    def border_color : String
      @colors["border_color"]? || "#334155"
    end

    def border_active : String
      @colors["border_active"]? || accent_color
    end

    def code_bg : String
      @colors["code_bg"]? || "#090d16"
    end

    # Sol.vin Retro Theme Specific Color Accessors
    def bg_window : String
      @colors["bg_window"]? || surface_color
    end

    def link_color : String
      @colors["link_color"]? || accent_color
    end

    def cube_color : String
      @colors["cube"]? || text_primary
    end

    def cube : String
      cube_color
    end

    def cube_hover : String
      @colors["cube_hover"]? || border_active
    end

    def bg : String
      bg_color
    end

    def window : String
      bg_window
    end

    def hex_to_rgb(hex : String) : Tuple(Float64, Float64, Float64)
      clean = hex.lchop('#')
      if clean.size == 3
        clean = clean.chars.map { |c| "#{c}#{c}" }.join
      end
      if clean.size == 6
        r = clean[0..1].to_i(16).to_f64 / 255.0
        g = clean[2..3].to_i(16).to_f64 / 255.0
        b = clean[4..5].to_i(16).to_f64 / 255.0
        {r, g, b}
      else
        {0.8, 0.8, 0.8}
      end
    end

    # Computes SVG feColorMatrix matrix for Sol.vin emoji chromatic tinting
    def emoji_color_matrix : String
      tr, tg, tb = hex_to_rgb(accent_color)
      scale = 1.25
      mr = "#{(0.2126 * tr * scale).round(4)} #{(0.7152 * tr * scale).round(4)} #{(0.0722 * tr * scale).round(4)} 0 0"
      mg = "#{(0.2126 * tg * scale).round(4)} #{(0.7152 * tg * scale).round(4)} #{(0.0722 * tg * scale).round(4)} 0 0"
      mb = "#{(0.2126 * tb * scale).round(4)} #{(0.7152 * tb * scale).round(4)} #{(0.0722 * tb * scale).round(4)} 0 0"
      ma = "0 0 0 1 0"
      "#{mr}  #{mg}  #{mb}  #{ma}"
    end

    # Emits CSS declaration block for custom palettes
    def css_rule(theme_name : String) : String
      <<-CSS
      .slide[data-palette="#{@id}"], .solvin-slide.#{@id}, [data-palette="#{@id}"] {
        /* Sol.vin Theme Variables */
        --bg-color: #{bg_color};
        --bg-window: #{bg_window};
        --text-color: #{text_primary};
        --text-dim: #{text_muted};
        --link-color: #{link_color};
        --border-color: #{border_color};
        --border-active: #{border_active};
        --accent-color: #{accent_color};
        --accent-secondary: #{accent_secondary};
        --accent-tertiary: #{accent_tertiary};
        --accent-quaternary: #{@colors["accent_quaternary"]? || text_muted};
        --shadow-color: #{@colors["shadow_color"]? || "#000000"};
        --cube: #{cube_color};
        --cube-hover: #{cube_hover};
        --emoji-filter: url(#emoji-filter-#{@id});

        /* Sunstone Modern Variables */
        --sunstone-bg: #{bg_color};
        --sunstone-surface: #{surface_color};
        --sunstone-surface-hover: #{surface_hover};
        --sunstone-text-primary: #{text_primary};
        --sunstone-text-secondary: #{text_secondary};
        --sunstone-text-muted: #{text_muted};
        --sunstone-accent: #{accent_color};
        --sunstone-accent-secondary: #{accent_secondary};
        --sunstone-accent-tertiary: #{accent_tertiary};
        --sunstone-border: #{border_color};
        --sunstone-border-active: #{border_active};
        --sunstone-code-bg: #{code_bg};
      }
      CSS
    end
  end
end
