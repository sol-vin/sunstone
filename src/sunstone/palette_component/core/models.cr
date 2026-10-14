require "yaml"
require "json"
require "../../models/palette"

module Sunstone
  module PaletteComponent
    # Normalized RGB color representation in [0.0, 1.0] for duotone feColorMatrix computation.
    struct RGB
      getter r : Float64
      getter g : Float64
      getter b : Float64

      def initialize(@r : Float64 = 0.0, @g : Float64 = 0.0, @b : Float64 = 0.0)
      end

      # Parses `#RGB`, `#RRGGBB`, or `rgb(r, g, b)` / `rgba(r, g, b, a)` strings into normalized RGB.
      def self.parse(color_str : String?) : RGB
        return RGB.new if color_str.nil?
        str = color_str.strip
        return RGB.new if str.empty?

        clean_hex = str.starts_with?('#') ? str[1..] : str
        if clean_hex.matches?(/^[0-9a-fA-F]{3}$/) || clean_hex.matches?(/^[0-9a-fA-F]{6}$/)
          if clean_hex.size == 3
            clean_hex = "#{clean_hex[0]}#{clean_hex[0]}#{clean_hex[1]}#{clean_hex[1]}#{clean_hex[2]}#{clean_hex[2]}"
          end
          if num = clean_hex.to_i?(16)
            return RGB.new(
              ((num >> 16) & 255) / 255.0,
              ((num >> 8) & 255) / 255.0,
              (num & 255) / 255.0
            )
          end
        end

        if m = str.match(/rgba?\(\s*(\d+)\s*,\s*(\d+)\s*,\s*(\d+)/i)
          return RGB.new(
            m[1].to_i / 255.0,
            m[2].to_i / 255.0,
            m[3].to_i / 255.0
          )
        end

        RGB.new
      end
    end

    # Pure, strongly-typed theme palette schema and color token resolver.
    struct PaletteDefinition
      getter id : String
      getter name : String
      getter colors : Hash(String, String)
      getter palette_colors : Hash(String, String)
      getter variables : Hash(String, String)

      def initialize(
        @id : String,
        @name : String,
        @colors : Hash(String, String) = {} of String => String,
        @palette_colors : Hash(String, String) = {} of String => String,
        @variables : Hash(String, String) = {} of String => String,
      )
      end

      # Resolves a specific color token key, checking resolved `colors` and `variables` -> `palette_colors`.
      def resolved_color(key : String, fallback : String = "") : String
        if val = @colors[key]?
          return @palette_colors[val]? || val
        end
        if ref = @variables[key]?
          return @palette_colors[ref]? || ref
        end
        @palette_colors[key]? || fallback
      end

      # Returns the color used for the `[ PALETTE: ● Name ]` indicator dot.
      def preview_dot_color : String
        c = resolved_color("accent_secondary")
        c = resolved_color("accent_color") if c.empty?
        c = resolved_color("text_color", "#1c1c1e") if c.empty?
        c
      end

      # Returns CSS custom properties map (e.g. `"--bg-color" => "#faf6ee"`).
      def css_variables : Hash(String, String)
        res = {} of String => String
        @colors.each do |k, v|
          resolved = @palette_colors[v]? || v
          res["--#{k.gsub('_', '-')}"] = resolved
        end
        text_val = resolved_color("cube_stroke_color")
        text_val = resolved_color("text_color", "#1c1c1e") if text_val.empty?
        res["--cube"] ||= text_val

        hover_val = resolved_color("border_active")
        hover_val = resolved_color("accent_color") if hover_val.empty?
        hover_val = text_val if hover_val.empty?
        res["--cube-hover"] ||= hover_val

        res["--cube-stroke-color"] = res["--cube"]? || text_val
        res
      end

      # Calculates the 5x4 SVG feColorMatrix string interpolating between duotone (t=0.0) and full color (t=1.0).
      def duotone_matrix_values(progress : Float64 = 0.0) : String
        t = progress.clamp(0.0, 1.0)
        start_val = resolved_color("filter_start_color")
        start_val = resolved_color("text_color", "#1c1c1e") if start_val.empty?

        end_val = resolved_color("filter_end_color")
        end_val = resolved_color("bg_color", "#faf6ee") if end_val.empty?

        bg = RGB.parse(end_val)
        txt = RGB.parse(start_val)

        dr = bg.r - txt.r
        dg = bg.g - txt.g
        db = bg.b - txt.b

        inv_t = 1.0 - t

        r_r = inv_t * dr * 0.2126 + t
        r_g = inv_t * dr * 0.7152
        r_b = inv_t * dr * 0.0722
        r_c = inv_t * txt.r

        g_r = inv_t * dg * 0.2126
        g_g = inv_t * dg * 0.7152 + t
        g_b = inv_t * dg * 0.0722
        g_c = inv_t * txt.g

        b_r = inv_t * db * 0.2126
        b_g = inv_t * db * 0.7152
        b_b = inv_t * db * 0.0722 + t
        b_c = inv_t * txt.b

        [
          sprintf("%.4f", r_r), sprintf("%.4f", r_g), sprintf("%.4f", r_b), "0", sprintf("%.4f", r_c),
          sprintf("%.4f", g_r), sprintf("%.4f", g_g), sprintf("%.4f", g_b), "0", sprintf("%.4f", g_c),
          sprintf("%.4f", b_r), sprintf("%.4f", b_g), sprintf("%.4f", b_b), "0", sprintf("%.4f", b_c),
          "0", "0", "0", "1", "0",
        ].join(" ")
      end

      def to_sunstone_palette : Sunstone::Palette
        Sunstone::Palette.new(@id, @name, @colors)
      end

      def self.from_sunstone_palette(palette : Sunstone::Palette) : PaletteDefinition
        PaletteDefinition.new(
          id: palette.id,
          name: palette.name,
          colors: palette.colors.dup
        )
      end

      def self.from_json_any(item : JSON::Any) : PaletteDefinition?
        return nil unless h = item.as_h?
        id = h["id"]?.try(&.as_s) || ""
        return nil if id.empty?
        name = h["name"]?.try(&.as_s) || id

        colors_map = {} of String => String
        if colors = h["colors"]?.try(&.as_h?)
          colors.each do |k, v|
            colors_map[k] = v.as_s? || v.to_s
          end
        else
          h.each do |k, v|
            colors_map[k] = v.as_s if v.as_s? && k != "id" && k != "name"
          end
        end

        palette_colors_map = {} of String => String
        if pc = h["palette_colors"]?.try(&.as_h?)
          pc.each do |k, v|
            palette_colors_map[k] = v.as_s? || v.to_s
          end
        end

        variables_map = {} of String => String
        if vars = h["variables"]?.try(&.as_h?)
          vars.each do |k, v|
            variables_map[k] = v.as_s? || v.to_s
          end
        end

        PaletteDefinition.new(
          id: id,
          name: name,
          colors: colors_map,
          palette_colors: palette_colors_map,
          variables: variables_map
        )
      rescue
        nil
      end

      def to_h
        {
          "id"             => @id,
          "name"           => @name,
          "colors"         => @colors,
          "palette_colors" => @palette_colors,
          "variables"      => @variables,
        }
      end

      def to_json(json : JSON::Builder) : Nil
        to_h.to_json(json)
      end

      # Canonical Warm Paper default palette.
      def self.warm_paper : PaletteDefinition
        PaletteDefinition.new(
          id: "warm_paper",
          name: "Warm Paper (Default)",
          palette_colors: {
            "bg"        => "#faf6ee",
            "text"      => "#1c1c1e",
            "link"      => "#303030",
            "secondary" => "#3a3a3c",
            "tertiary"  => "#545458",
          },
          variables: {
            "bg_color"           => "bg",
            "bg_window"          => "bg",
            "text_color"         => "text",
            "link_color"         => "link",
            "text_dim"           => "text",
            "border_color"       => "text",
            "border_active"      => "text",
            "accent_color"       => "text",
            "shadow_color"       => "text",
            "accent_secondary"   => "secondary",
            "accent_tertiary"    => "tertiary",
            "accent_quaternary"  => "link",
            "cube"               => "text",
            "cube_hover"         => "border_active",
            "cube_stroke_color"  => "text",
            "filter_start_color" => "text",
            "filter_end_color"   => "bg",
          },
          colors: {
            "bg_color"           => "#faf6ee",
            "bg_window"          => "#faf6ee",
            "text_color"         => "#1c1c1e",
            "link_color"         => "#303030",
            "text_dim"           => "#1c1c1e",
            "border_color"       => "#1c1c1e",
            "border_active"      => "#1c1c1e",
            "accent_color"       => "#1c1c1e",
            "accent_secondary"   => "#3a3a3c",
            "accent_tertiary"    => "#545458",
            "accent_quaternary"  => "#303030",
            "shadow_color"       => "#1c1c1e",
            "cube"               => "#1c1c1e",
            "cube_hover"         => "#1c1c1e",
            "cube_stroke_color"  => "#1c1c1e",
            "filter_start_color" => "#1c1c1e",
            "filter_end_color"   => "#faf6ee",
          }
        )
      end
    end

    # Pure specification for the HoldClick interaction controller and SVG progress ring.
    struct HoldClickSpec
      getter hold_duration : Int32
      getter spinner_delay : Int32
      getter spinner_id : String
      getter spinner_class : String
      getter spinner_radius : Float64
      getter delegate_selector : String?

      def initialize(
        @hold_duration : Int32 = 2000,
        @spinner_delay : Int32 = 500,
        @spinner_id : String = "palette-hold-spinner",
        @spinner_class : String = "palette-hold-spinner hold-click-spinner",
        @spinner_radius : Float64 = 11.0,
        @delegate_selector : String? = nil,
      )
      end

      def circumference : Float64
        2.0 * Math::PI * @spinner_radius
      end
    end

    # Pure specification for the canonical `#palette-swap-btn` component.
    struct SwapButtonSpec
      getter id : String
      getter css_class : String
      getter preview_id : String
      getter preview_class : String
      getter label_id : String
      getter default_label : String
      getter prefix_text : String
      getter dot_symbol : String
      getter aria_label : String
      getter tooltip : String

      def initialize(
        @id : String = "palette-swap-btn",
        @css_class : String = "palette-swap-btn",
        @preview_id : String = "palette-color-preview",
        @preview_class : String = "palette-color-preview",
        @label_id : String = "palette-name-label",
        @default_label : String = "Warm Paper (Default)",
        @prefix_text : String = "PALETTE:",
        @dot_symbol : String = "●",
        @aria_label : String = "Swap Color Palette",
        @tooltip : String = "Left-click: Next | Right-click: Prev | Left Hold: Palette Selection Menu | Right Hold: Reset Default",
      )
      end
    end

    # Pure specification for the canonical `#palette-picker-modal-overlay` catalog modal.
    struct PickerModalSpec
      getter overlay_id : String
      getter overlay_class : String
      getter window_class : String
      getter title_id : String
      getter title_text : String
      getter header_icon : String
      getter close_btn_id : String
      getter close_btn_title : String
      getter description_text : String
      getter random_btn_id : String
      getter random_btn_label : String
      getter random_btn_title : String
      getter random_icon : String
      getter grid_id : String
      getter storage_key : String
      getter channel_name : String

      def initialize(
        @overlay_id : String = "palette-picker-modal-overlay",
        @overlay_class : String = "skill-modal-overlay",
        @window_class : String = "terminal-window skill-modal-window palette-picker-window",
        @title_id : String = "palette-picker-modal-title",
        @title_text : String = "THEME // Palette Selector // Color Catalog",
        @header_icon : String = "palette.svg",
        @close_btn_id : String = "palette-picker-modal-close",
        @close_btn_title : String = "Close Catalog",
        @description_text : String = "Select a theme palette from the catalog below to instantly customize slide deck appearance:",
        @random_btn_id : String = "palette-picker-random-btn",
        @random_btn_label : String = "[ RANDOM // Palette ]",
        @random_btn_title : String = "Pick Random Palette",
        @random_icon : String = "dice.svg",
        @grid_id : String = "palette-picker-grid",
        @storage_key : String = "solvin_palette_id",
        @channel_name : String = "solvin_palette_channel",
      )
      end
    end

    # Immutable bundle of all rendered artifacts from a configured PaletteComponent.
    struct ComponentBundle
      getter palettes : Array(PaletteDefinition)
      getter palettes_json : String
      getter button_html : String
      getter toolbar_html : String
      getter modal_html : String
      getter spinner_html : String
      getter duotone_svg_html : String
      getter css : String
      getter hold_click_js : String
      getter palette_engine_js : String
      getter bundle_js : String

      def initialize(
        @palettes : Array(PaletteDefinition),
        @palettes_json : String,
        @button_html : String,
        @toolbar_html : String,
        @modal_html : String,
        @spinner_html : String,
        @duotone_svg_html : String,
        @css : String,
        @hold_click_js : String,
        @palette_engine_js : String,
        @bundle_js : String,
      )
      end

      def stylesheet : String
        @css
      end
    end
  end
end
