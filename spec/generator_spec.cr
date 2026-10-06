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

  it "supports building presentations with nordic, brutalist, academic, and tokyo-night themes" do
    ["nordic", "brutalist", "academic", "tokyo-night"].each do |theme_name|
      sub_dir = File.join(Dir.tempdir, "sunstone_spec_#{theme_name}_#{Time.utc.to_unix_ms}")
      deck = Sunstone::Deck.load("examples/showcase/deck.yml")
      deck.theme = theme_name
      generator = Sunstone::Generator.new(deck)

      html_path, _ = generator.build(sub_dir, copy_vendor: false)
      File.exists?(html_path).should be_true
      theme_css = File.read(File.join(sub_dir, "theme.css"))
      theme_css.should contain("sunstone-")
      FileUtils.rm_rf(sub_dir)
    end
  end

  it "loads custom theme from local CSS file path" do
    custom_dir = File.join(Dir.tempdir, "sunstone_custom_theme_#{Time.utc.to_unix_ms}")
    Dir.mkdir_p(custom_dir)
    custom_css_path = File.join(custom_dir, "brand.css")
    custom_json_path = File.join(custom_dir, "brand.json")

    File.write(custom_css_path, "/* Custom Brand Theme */\n:root { --sunstone-bg: #112233; }")
    File.write(custom_json_path, %({"brand_primary": {"name": "Brand", "bg_color": "#112233", "fg_color": "#ffffff", "accent_color": "#ff0077"}}))

    deck_yaml_path = File.join(custom_dir, "deck.yml")
    deck_content = <<-YAML
      title: Custom Deck
      theme: ./brand.css
      slides:
        - title: Hello Custom
          layout: intro
          palette: brand_primary
      YAML
    File.write(deck_yaml_path, deck_content)

    deck = Sunstone::Deck.load(deck_yaml_path)
    File.basename(deck.theme).should eq("brand.css")

    out_dir = File.join(custom_dir, "dist")
    generator = Sunstone::Generator.new(deck)
    html_path, _ = generator.build(out_dir, copy_vendor: false)

    File.exists?(html_path).should be_true
    File.read(File.join(out_dir, "theme.css")).should contain("/* Custom Brand Theme */")
    File.read(File.join(out_dir, "theme.css")).should contain(%([data-palette="brand_primary"]))

    FileUtils.rm_rf(custom_dir)
  end

  it "renders in-deck navigation bar when gallery_nav is enabled" do
    deck = Sunstone::Deck.load("examples/showcase/deck.yml")
    deck.theme = "nordic"
    generator = Sunstone::Generator.new(deck, gallery_nav: true, landing_url: "../../index.html")

    sub_dir = File.join(Dir.tempdir, "sunstone_nav_spec_#{Time.utc.to_unix_ms}")
    html_path, _ = generator.build(sub_dir, copy_vendor: false)

    html = File.read(html_path)
    html.should contain("sunstone-nav-bar")
    html.should contain("../../index.html")
    html.should contain(%{<a href="../brutalist/index.html"})
    html.should contain(%{<a href="../nordic/index.html" class="nav-theme-btn active">})

    FileUtils.rm_rf(sub_dir)
  end

  it "generates an interactive multi-theme landing page gallery" do
    landing_dir = File.join(Dir.tempdir, "sunstone_landing_spec_#{Time.utc.to_unix_ms}")
    Dir.mkdir_p(landing_dir)
    landing_path = File.join(landing_dir, "index.html")

    Sunstone::LandingPage.generate(landing_path)

    File.exists?(landing_path).should be_true
    content = File.read(landing_path)
    content.should contain("<!DOCTYPE html>")
    content.should contain("Sunstone")
    content.should contain("Interactive Stage")
    content.should contain("Theme Catalog")
    content.should contain("15 Semantic Layouts")

    # Check that all 6 themes are listed in the landing page
    Sunstone::Assets.available_themes.each do |theme_name|
      content.should contain(%(data-theme="#{theme_name}"))
      content.should contain(%(themes/#{theme_name}/index.html))
    end

    FileUtils.rm_rf(landing_dir)
  end
end

