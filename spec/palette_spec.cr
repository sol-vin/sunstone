require "./spec_helper"

describe Sunstone::Palette do
  it "loads modern palettes for the generic theme" do
    palettes = Sunstone::Palette.load_for_theme("generic")
    palettes.should_not be_empty
    palettes.has_key?("slate_dark").should be_true
    palettes.has_key?("emerald_matrix").should be_true
    palettes.has_key?("clean_light").should be_true

    p = palettes["slate_dark"]
    p.name.should eq("Slate Dark (Default)")
    p.bg_color.should eq("#0f172a")
    p.accent_color.should eq("#38bdf8")
  end

  it "loads retro palettes for the sol.vin theme" do
    palettes = Sunstone::Palette.load_for_theme("sol.vin")
    palettes.size.should be >= 40
    palettes.has_key?("warm_paper").should be_true
    palettes.has_key?("spaces_98").should be_true
    palettes.has_key?("monokai").should be_true

    p = palettes["warm_paper"]
    p.name.should eq("Warm Paper (Default)")
    p.bg_color.should eq("#faf6ee")
    p.emoji_color_matrix.should_not be_empty
  end

  it "generates clean CSS variables for themes" do
    palettes = Sunstone::Palette.load_for_theme("generic")
    p = palettes["slate_dark"]
    css = p.css_rule("generic")

    css.should contain(%(.slide[data-palette="slate_dark"]))
    css.should contain("--sunstone-bg: #0f172a;")
    css.should contain("--sunstone-accent: #38bdf8;")
  end
end
