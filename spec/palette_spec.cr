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

  it "loads palettes for the nordic theme" do
    palettes = Sunstone::Palette.load_for_theme("nordic")
    palettes.size.should eq(6)
    palettes.has_key?("fjord_deep").should be_true
    palettes.has_key?("aurora_night").should be_true
    palettes.has_key?("glacier_frost").should be_true
    palettes.has_key?("arctic_twilight").should be_true
    palettes.has_key?("lichen_moss").should be_true
    palettes.has_key?("polar_monochrome").should be_true

    p = palettes["fjord_deep"]
    p.name.should eq("Fjord Deep (Default)")
    p.bg_color.should eq("#090d16")
    p.accent_color.should eq("#38bdf8")
  end

  it "loads palettes for the brutalist theme" do
    palettes = Sunstone::Palette.load_for_theme("brutalist")
    palettes.size.should eq(6)
    palettes.has_key?("yellow_hazard").should be_true
    palettes.has_key?("paper_ink").should be_true
    palettes.has_key?("electric_lime").should be_true
    palettes.has_key?("orange_warning").should be_true
    palettes.has_key?("cobalt_blueprint").should be_true
    palettes.has_key?("hot_magenta").should be_true

    p = palettes["yellow_hazard"]
    p.name.should eq("Yellow Hazard (Default)")
    p.bg_color.should eq("#0a0a0a")
    p.accent_color.should eq("#ffde00")
  end

  it "loads palettes for the academic theme" do
    palettes = Sunstone::Palette.load_for_theme("academic")
    palettes.size.should eq(6)
    palettes.has_key?("computer_modern").should be_true
    palettes.has_key?("cambridge_blue").should be_true
    palettes.has_key?("oxford_crimson").should be_true
    palettes.has_key?("gothic_dark").should be_true
    palettes.has_key?("emerald_manuscript").should be_true
    palettes.has_key?("blackboard_latex").should be_true

    p = palettes["computer_modern"]
    p.name.should eq("Computer Modern (Default)")
    p.bg_color.should eq("#faf9f5")
    p.accent_color.should eq("#1e3a8a")
  end

  it "loads palettes for the tokyo-night theme" do
    palettes = Sunstone::Palette.load_for_theme("tokyo-night")
    palettes.size.should eq(6)
    palettes.has_key?("tokyo_night").should be_true
    palettes.has_key?("tokyo_storm").should be_true
    palettes.has_key?("cyber_pulse").should be_true
    palettes.has_key?("catppuccin_mocha").should be_true
    palettes.has_key?("dracula_vampire").should be_true
    palettes.has_key?("monokai_pro").should be_true

    p = palettes["tokyo_night"]
    p.name.should eq("Tokyo Night (Default)")
    p.bg_color.should eq("#1a1b26")
    p.accent_color.should eq("#7dcfff")
  end

  it "generates clean CSS variables for themes" do
    palettes = Sunstone::Palette.load_for_theme("generic")
    p = palettes["slate_dark"]
    css = p.css_rule("generic")

    css.should contain(%(.slide[data-palette="slate_dark"]))
    css.should contain("--sunstone-bg: #0f172a;")
    css.should contain("--sunstone-accent: #38bdf8;")
  end

  it "strictly scopes palettes to theme and resolves semantic aliases" do
    academic_palettes = Sunstone::Palette.load_for_theme("academic")

    # Generic palette 'slate_dark' resolves to academic 'gothic_dark'
    resolved = Sunstone::Palette.resolve_for_theme("slate_dark", "academic", academic_palettes, "computer_modern")
    resolved.id.should eq("gothic_dark")

    # Native academic palette resolves directly
    resolved = Sunstone::Palette.resolve_for_theme("cambridge_blue", "academic", academic_palettes, "computer_modern")
    resolved.id.should eq("cambridge_blue")

    # Unknown palette falls back to theme default
    resolved = Sunstone::Palette.resolve_for_theme("non_existent_palette", "academic", academic_palettes, "computer_modern")
    resolved.id.should eq("computer_modern")
  end

  it "loads all 102 sol.vin palettes without cross-leaking into other themes" do
    solvin_palettes = Sunstone::Palette.load_for_theme("sol.vin")
    solvin_palettes.size.should be >= 100
    solvin_palettes.has_key?("amigo").should be_true
    solvin_palettes.has_key?("inversion").should be_true
    solvin_palettes.has_key?("black_cube").should be_true

    academic_palettes = Sunstone::Palette.load_for_theme("academic")
    academic_palettes.has_key?("amigo").should be_false
    academic_palettes.has_key?("inversion").should be_false
  end
end

