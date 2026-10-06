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

    def cube_hover : String
      @colors["cube_hover"]? || border_active
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
      if theme_name.downcase.includes?("sol.vin")
        <<-CSS
        .slide[data-palette="#{@id}"], .solvin-slide.#{@id} {
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
          --cube: #{cube_color};
          --cube-hover: #{cube_hover};
          --emoji-filter: url(#emoji-filter-#{@id});
        }
        CSS
      else
        <<-CSS
        .slide[data-palette="#{@id}"] {
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
end
