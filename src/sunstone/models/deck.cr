require "yaml"
require "./slide"
require "./palette"

module Sunstone
  class Deck
    getter raw : YAML::Any
    getter title : String
    getter subtitle : String
    getter author : String
    getter author_url : String
    property theme : String
    getter deck_dir : String
    getter width : Int32
    getter height : Int32
    getter header_enabled : Bool
    getter header_label : String
    getter header_logo : String?
    getter footer_left : String
    getter footer_center : String
    getter footer_right : String
    getter custom_css : Array(String)
    getter custom_palettes : Hash(String, Palette)
    getter slides : Array(Slide)

    def initialize(@raw : YAML::Any, @slides : Array(Slide), @deck_dir : String = ".")
      @title = @raw["title"]?.try(&.as_s) || "Sunstone Presentation"
      @subtitle = @raw["subtitle"]?.try(&.as_s) || ""
      @author = @raw["author"]?.try(&.as_s) || ""
      @author_url = @raw["author_url"]?.try(&.as_s) || ""

      theme_candidate = @raw["theme"]?.try(&.as_s) || "generic"
      local_theme_path = File.join(@deck_dir, theme_candidate)
      if (theme_candidate.ends_with?(".css") || File.exists?(local_theme_path)) && File.file?(local_theme_path)
        @theme = File.expand_path(local_theme_path)
      else
        @theme = theme_candidate
      end

      res = @raw["resolution"]?
      @width = res.try(&.["width"]?.try(&.as_i)) || @raw["width"]?.try(&.as_i) || 1280
      @height = res.try(&.["height"]?.try(&.as_i)) || @raw["height"]?.try(&.as_i) || 720

      header = @raw["header"]?
      @header_enabled = header.try(&.["enabled"]?.try(&.as_bool)) != false
      @header_label = header.try(&.["label"]?.try(&.as_s)) || "SUNSTONE PRESENTATION"
      @header_logo = header.try(&.["logo"]?.try(&.as_s))

      footer = @raw["footer"]?
      @footer_left = footer.try(&.["left"]?.try(&.as_s)) || @raw["footer_left"]?.try(&.as_s) || "{title} • {subtitle}"
      @footer_center = footer.try(&.["center"]?.try(&.as_s)) || @raw["footer_center"]?.try(&.as_s) || "{author} ({palette})"
      @footer_right = footer.try(&.["right"]?.try(&.as_s)) || @raw["footer_right"]?.try(&.as_s) || "Slide {slide_num} / {total_slides}"
      @custom_css = Array(String).new
      if css_nodes = @raw["custom_css"]?.try(&.as_a)
        css_nodes.each { |node| @custom_css << node.as_s }
      elsif single_css = @raw["theme_css"]?.try(&.as_s) || @raw["custom_css"]?.try(&.as_s)
        @custom_css << single_css
      end

      @custom_palettes = Hash(String, Palette).new
      if pal_nodes = @raw["palettes"]?.try(&.as_h)
        pal_nodes.each do |k, v|
          id = k.as_s
          name = v["name"]?.try(&.as_s) || id
          colors = Hash(String, String).new
          if v_hash = v.as_h?
            v_hash.each do |col_k, col_v|
              colors[col_k.as_s] = col_v.as_s
            end
          end
          @custom_palettes[id] = Palette.new(id, name, colors)
        end
      end
    end

    def default_palette : String
      if explicit = @raw["default_palette"]?.try(&.as_s)
        return explicit
      end

      case @theme.downcase.gsub("_", "-")
      when "sol.vin", "solvin", "retro"
        "warm_paper"
      when "academic", "latex", "beamer", "scholarly"
        "computer_modern"
      when "nordic", "scandinavian", "ice"
        "fjord_deep"
      when "brutalist", "neo-brutalist", "swiss"
        "yellow_hazard"
      when "tokyo-night", "tokyonight", "cyberpunk", "ide"
        "tokyo_night"
      else
        "slate_dark"
      end
    end

    def palettes : Hash(String, Palette)
      @custom_palettes
    end

    def theme_css : String
      @custom_css.first? || ""
    end

    def header_cube : Bool
      if explicit = @raw["header"]?.try(&.["cube"]?.try(&.as_bool))
        return explicit
      end
      @theme.downcase.includes?("sol.vin")
    end

    def self.load(deck_file : String, slides_dir : String? = nil) : Deck
      deck_dir = File.dirname(File.expand_path(deck_file))

      raw = if File.exists?(deck_file)
              YAML.parse(File.read(deck_file))
            else
              YAML.parse("title: Presentation Deck")
            end

      slides = Array(Slide).new
      effective_slides_dir = slides_dir || File.join(deck_dir, "slides")

      if order = raw["slides"]?.try(&.as_a)
        order.each_with_index do |item, idx|
          if item.raw.is_a?(Hash)
            slides << Slide.new(item, "inline_slide_#{idx + 1}")
          elsif str = item.as_s?
            name = str
            candidates = [
              File.join(deck_dir, name),
              File.join(deck_dir, name.ends_with?(".yml") ? name : "#{name}.yml"),
              File.join(effective_slides_dir, name),
              File.join(effective_slides_dir, name.ends_with?(".yml") ? name : "#{name}.yml"),
            ]

            found = candidates.find { |c| File.exists?(c) }
            if found
              slides << Slide.from_file(found)
            else
              STDERR.puts "[WARN] Slide file not found: #{name} (searched #{candidates.join(", ")})"
            end
          end
        end
      elsif Dir.exists?(effective_slides_dir)
        Dir.glob(File.join(effective_slides_dir, "*.yml")).sort.each do |file|
          slides << Slide.from_file(file)
        end
      end

      Deck.new(raw, slides, deck_dir)
    end
  end
end
