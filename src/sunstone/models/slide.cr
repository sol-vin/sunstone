require "yaml"

module Sunstone
  class Slide
    getter raw : YAML::Any
    getter id : String
    getter title : String
    getter subtitle : String
    getter badge : String
    getter badge_color : String
    getter palette : String
    getter layout : String
    getter notes : String
    getter file_path : String

    def initialize(@raw : YAML::Any, @file_path : String)
      @id = @raw["id"]?.try(&.as_s) || File.basename(@file_path, ".yml")
      @title = @raw["title"]?.try(&.as_s) || "Untitled Slide"
      @subtitle = @raw["subtitle"]?.try(&.as_s) || ""
      @badge = @raw["badge"]?.try(&.as_s) || "SUNSTONE"
      @badge_color = @raw["badge_color"]?.try(&.as_s) || "accent"
      @palette = @raw["palette"]?.try(&.as_s) || "slate_dark"
      @layout = @raw["layout"]?.try(&.as_s) || "two-column"
      @notes = @raw["notes"]?.try(&.as_s) || ""
    end

    def [](key : String) : YAML::Any
      @raw[key]
    end

    def []?(key : String) : YAML::Any?
      @raw[key]?
    end

    def author : String
      @raw["author"]?.try(&.as_s) || ""
    end

    def content : String
      @raw["content"]?.try(&.as_s) || @raw["text"]?.try(&.as_s) || ""
    end

    def quote : String
      @raw["quote"]?.try(&.as_s) || ""
    end

    def bullets : Array(String)
      if b = @raw["bullets"]?.try(&.as_a)
        b.map { |item| item.as_s? || item.to_s }
      elsif p = @raw["pillars"]?.try(&.as_a)
        p.map { |item| item.as_s? || item.to_s }
      else
        [] of String
      end
    end

    def self.from_file(file_path : String) : Slide
      content = File.read(file_path)
      raw = YAML.parse(content)
      Slide.new(raw, file_path)
    end
  end
end
