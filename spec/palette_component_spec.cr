require "./spec_helper"
require "file_utils"

describe Sunstone::PaletteComponent do
  describe "Tier 1: Core Engine (Models, CatalogLoader, Icons, Renderer)" do
    it "parses hex and rgb colors into normalized RGB and computes duotone matrices" do
      rgb = Sunstone::PaletteComponent::RGB.parse("#faf6ee")
      rgb.r.should be_close(250.0 / 255.0, 0.001)
      rgb.g.should be_close(246.0 / 255.0, 0.001)
      rgb.b.should be_close(238.0 / 255.0, 0.001)

      rgb2 = Sunstone::PaletteComponent::RGB.parse("rgb(28, 28, 30)")
      rgb2.r.should be_close(28.0 / 255.0, 0.001)
      rgb2.g.should be_close(28.0 / 255.0, 0.001)
      rgb2.b.should be_close(30.0 / 255.0, 0.001)

      wp = Sunstone::PaletteComponent::PaletteDefinition.warm_paper
      wp.id.should eq("warm_paper")
      wp.preview_dot_color.should eq("#3a3a3c")
      wp.duotone_matrix_values(0.0).should contain("0.1851")
    end

    it "loads all 102 palettes from the canonical sol.vin catalog" do
      catalog = Sunstone::PaletteComponent::CatalogLoader.load_solvin_palettes
      catalog.size.should eq(102)

      ids = catalog.map(&.id)
      ids.should contain("warm_paper")
      ids.should contain("monokai")
      ids.should contain("spaces_98")
      ids.should contain("game_station_2")
      ids.should contain("dreamcast")

      warm_paper = Sunstone::PaletteComponent::CatalogLoader.find_by_id(catalog, "warm_paper")
      warm_paper.should_not be_nil
      warm_paper.not_nil!.name.should contain("Warm Paper")
      warm_paper.not_nil!.resolved_color("bg_color").should eq("#faf6ee")
    end

    it "loads standard FontAwesome SVG icons with fill=currentColor" do
      Sunstone::PaletteComponent::Icons.render("palette.svg").should contain("fill=\"currentColor\"")
      Sunstone::PaletteComponent::Icons.render("dice.svg").should contain("fill=\"currentColor\"")
      Sunstone::PaletteComponent::Icons.render("xmark.svg").should contain("fill=\"currentColor\"")
      Sunstone::PaletteComponent::Icons.render("bracket-square.svg").should contain("fill=\"currentColor\"")
      Sunstone::PaletteComponent::Icons.render("bracket-square-right.svg").should contain("fill=\"currentColor\"")
    end

    it "renders zero-inline-style semantic HTML for button, spinner, and catalog modal" do
      btn_html = Sunstone::PaletteComponent::Renderer.render_swap_button
      btn_html.should contain("id=\"palette-swap-btn\"")
      btn_html.should contain("id=\"palette-color-preview\"")
      btn_html.should contain("id=\"palette-name-label\"")
      btn_html.should contain("PALETTE:")
      btn_html.should_not contain(" style=")

      spinner_html = Sunstone::PaletteComponent::Renderer.render_hold_spinner
      spinner_html.should contain("id=\"palette-hold-spinner\"")
      spinner_html.should contain("class=\"spinner-progress\"")
      spinner_html.should_not contain(" style=")

      modal_html = Sunstone::PaletteComponent::Renderer.render_picker_modal
      modal_html.should contain("id=\"palette-picker-modal-overlay\"")
      modal_html.should contain("id=\"palette-picker-modal-title\"")
      modal_html.should contain("id=\"palette-picker-random-btn\"")
      modal_html.should contain("[ RANDOM // Palette ]")
      modal_html.should contain("id=\"palette-picker-grid\"")
      modal_html.should_not contain(" style=")
    end
  end

  describe "Tier 2: Declarative DSL (ComponentBuilder, ButtonBuilder, ModalBuilder, HoldClickBuilder)" do
    it "configures component bundle via declarative block DSL" do
      bundle = Sunstone::PaletteComponent.build do |c|
        c.theme "sol.vin"
        c.toolbar_class "custom-palette-toolbar"

        c.button do |b|
          b.id "custom-swap-btn"
          b.prefix_text "THEME:"
          b.default_label "Tokyo Night"
        end

        c.modal do |m|
          m.title_text "SELECT PALETTE"
          m.random_btn_label "[ SHUFFLE ]"
          m.channel_name "custom_palette_channel"
        end

        c.hold_click do |h|
          h.hold_duration 1500
          h.spinner_delay 300
        end
      end

      bundle.palettes.size.should eq(102)
      bundle.button_html.should contain("id=\"custom-swap-btn\"")
      bundle.button_html.should contain("THEME:")
      bundle.button_html.should contain("Tokyo Night")
      bundle.toolbar_html.should contain("class=\"custom-palette-toolbar\"")
      bundle.modal_html.should contain("SELECT PALETTE")
      bundle.modal_html.should contain("[ SHUFFLE ]")
      bundle.spinner_html.should contain("id=\"palette-hold-spinner\"")
    end
  end

  describe "Sunstone::Generator Slide Deck Integration" do
    it "bundles hold_click.js, palette_engine.js, 102 palettes, button, and catalog modal into generated decks" do
      tmp_dir = File.join(Dir.tempdir, "sunstone_palette_component_spec_#{Time.utc.to_unix_ms}")
      deck = Sunstone::Deck.load("examples/showcase/deck.yml")
      generator = Sunstone::Generator.new(deck)

      html_path, _ = generator.build(tmp_dir, copy_vendor: false)

      File.exists?(File.join(tmp_dir, "hold_click.js")).should be_true
      File.exists?(File.join(tmp_dir, "palette_engine.js")).should be_true

      hold_js = File.read(File.join(tmp_dir, "hold_click.js"))
      hold_js.should contain("HoldClick")
      hold_js.should contain("palette-hold-spinner")

      engine_js = File.read(File.join(tmp_dir, "palette_engine.js"))
      engine_js.should contain("BroadcastChannel")
      engine_js.should contain("solvin_palette_channel")
      engine_js.should contain("randomPalette")
      engine_js.should contain("syncSlideDeck")

      html = File.read(html_path)
      html.should contain("window.SITE_PALETTES =")
      html.should contain("<script src=\"hold_click.js\"></script>")
      html.should contain("<script src=\"palette_engine.js\"></script>")
      html.should contain("window.PaletteEngine.initHead(window.SITE_PALETTES)")
      html.should contain("id=\"palette-swap-btn\"")
      html.should contain("id=\"palette-hold-spinner\"")
      html.should contain("id=\"palette-picker-modal-overlay\"")
      html.should contain("id=\"palette-picker-random-btn\"")
      html.should contain("id=\"palette-picker-grid\"")
      html.should contain("window.PaletteEngine.initDom()")

      theme_css = File.read(File.join(tmp_dir, "theme.css"))
      theme_css.should contain(".palette-swap-btn")
      theme_css.should contain(".palette-picker-window")
      theme_css.should contain("#palette-picker-grid")
      theme_css.should contain(%([data-palette="spaces_98"]))
      theme_css.should contain(%([data-palette="game_station_2"]))

      FileUtils.rm_rf(tmp_dir)
    end
  end
end
