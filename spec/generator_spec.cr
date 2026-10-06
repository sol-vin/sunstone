require "./spec_helper"
require "file_utils"

describe Sunstone::Generator do
  tmp_dir = File.join(Dir.tempdir, "sunstone_spec_#{Time.utc.to_unix_ms}")

  it "builds the presentation into output directory" do
    deck = Sunstone::Deck.load("examples/showcase/deck.yml")
    generator = Sunstone::Generator.new(deck)

    html_path, md_path = generator.build(tmp_dir, copy_vendor: true)

    File.exists?(html_path).should be_true
    File.exists?(md_path).should be_true
    File.exists?(File.join(tmp_dir, "theme.css")).should be_true
    File.exists?(File.join(tmp_dir, "vendor/reveal/reveal.min.js")).should be_true

    html = File.read(html_path)
    html.should contain("<!DOCTYPE html>")
    html.should contain("<title>Sunstone Showcase — Interactive Tour of Modern Semantic Slides</title>")

    # Clean HTML without code contents should have zero inline style attributes
    clean_html = html.gsub(/<code[^>]*>.*?<\/code>/m, "")
    clean_html.should_not contain(" style=")
    clean_html.should_not contain(" style =")
  end
end
