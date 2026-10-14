require "json"
require "./models"
require "../../assets"

module Sunstone
  module PaletteComponent
    module CatalogLoader
      # Parses a JSON catalog string into an ordered array of `PaletteDefinition` structs.
      def self.parse_json_catalog(json_content : String) : Array(PaletteDefinition)
        parsed = JSON.parse(json_content)
        result = [] of PaletteDefinition

        if items = parsed.as_a?
          items.each do |item|
            if defn = PaletteDefinition.from_json_any(item)
              result << defn
            end
          end
        elsif hash = parsed.as_h?
          hash.each do |key, val|
            if h = val.as_h?
              id = h["id"]?.try(&.as_s) || key
              name = h["name"]?.try(&.as_s) || id
              colors_map = {} of String => String
              if colors = h["colors"]?.try(&.as_h?)
                colors.each { |k, v| colors_map[k] = v.as_s? || v.to_s }
              else
                h.each { |k, v| colors_map[k] = v.as_s if v.as_s? && k != "id" && k != "name" }
              end
              result << PaletteDefinition.new(id: id, name: name, colors: colors_map)
            end
          end
        end

        result
      rescue
        [] of PaletteDefinition
      end

      # Loads the canonical 102 `sol.vin` palettes in deterministic catalog order.
      def self.load_solvin_palettes : Array(PaletteDefinition)
        palettes = parse_json_catalog(Assets::SOLVIN_PALETTES_JSON)
        palettes.empty? ? [PaletteDefinition.warm_paper] : palettes
      end

      # Loads the palette catalog for a given theme, guaranteeing all 102 `sol.vin` palettes
      # are available for live theme switching while preserving native theme defaults.
      def self.load_palettes(
        theme_name : String = "sol.vin",
        custom_palettes : Hash(String, Sunstone::Palette)? = nil,
        include_solvin_catalog : Bool = true,
      ) : Array(PaletteDefinition)
        seen = Set(String).new
        result = [] of PaletteDefinition

        norm_theme = theme_name.downcase.gsub("_", "-")
        is_solvin = norm_theme.includes?("sol.vin") || norm_theme.includes?("solvin") || norm_theme == "retro"

        unless is_solvin
          theme_json = Assets.palettes_json_for(theme_name)
          parse_json_catalog(theme_json).each do |defn|
            unless seen.includes?(defn.id)
              seen << defn.id
              result << defn
            end
          end
        end

        if include_solvin_catalog || is_solvin
          load_solvin_palettes.each do |defn|
            unless seen.includes?(defn.id)
              seen << defn.id
              result << defn
            end
          end
        end

        if custom_palettes
          custom_palettes.each_value do |pal|
            defn = PaletteDefinition.from_sunstone_palette(pal)
            if idx = result.index { |existing| existing.id == defn.id }
              result[idx] = defn
            else
              seen << defn.id
              result << defn
            end
          end
        end

        result.empty? ? [PaletteDefinition.warm_paper] : result
      end

      # Serializes the palette catalog for a theme as a JSON array string (`window.SITE_PALETTES`).
      def self.load_palettes_json(
        theme_name : String = "sol.vin",
        custom_palettes : Hash(String, Sunstone::Palette)? = nil,
        include_solvin_catalog : Bool = true,
      ) : String
        load_palettes(theme_name, custom_palettes, include_solvin_catalog).to_json
      end

      # Finds a palette definition by ID within a catalog, returning nil if not found.
      def self.find_by_id(palettes : Array(PaletteDefinition), id : String) : PaletteDefinition?
        palettes.find { |p| p.id == id }
      end

      # Finds the deterministic index of a palette by ID, or -1 if not found.
      def self.find_index_by_id(palettes : Array(PaletteDefinition), id : String) : Int32
        palettes.index { |p| p.id == id } || -1
      end
    end
  end
end
