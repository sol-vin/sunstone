require "file_utils"
require "./palette_component/core/icons"
require "./palette_component/core/models"
require "./palette_component/core/catalog_loader"
require "./palette_component/core/renderer"
require "./palette_component/dsl/button_builder"
require "./palette_component/dsl/modal_builder"
require "./palette_component/dsl/hold_click_builder"
require "./palette_component/dsl/component_builder"

module Sunstone
  # Modular `sol.vin` Palette Select Button & Catalog Menu component for Sunstone slide decks.
  #
  # Provides Two-Tier Core Engine & Declarative DSL builders for:
  # - `#palette-swap-btn` (`SwapButtonSpec`, `DSL::ButtonBuilder`)
  # - `HoldClick` interaction controller (`HoldClickSpec`, `DSL::HoldClickBuilder`, `hold_click_js`)
  # - `#palette-picker-modal-overlay` catalog grid (`PickerModalSpec`, `DSL::ModalBuilder`)
  # - `PaletteEngine` JS/CSS module (`PaletteDefinition`, `CatalogLoader`, `palette_engine_js`, `stylesheet`)
  module PaletteComponent
    # Loads the palette definitions for `theme_name` (including all 102 `sol.vin` palettes).
    def self.palettes(
      theme_name : String = "sol.vin",
      custom_palettes : Hash(String, Sunstone::Palette)? = nil,
      include_solvin_catalog : Bool = true,
    ) : Array(PaletteDefinition)
      CatalogLoader.load_palettes(theme_name, custom_palettes, include_solvin_catalog)
    end

    # Loads the canonical 102 `sol.vin` palettes.
    def self.solvin_palettes : Array(PaletteDefinition)
      CatalogLoader.load_solvin_palettes
    end

    # Loads the sorted palette catalog as a JSON array string (`window.SITE_PALETTES`).
    def self.palettes_json(
      theme_name : String = "sol.vin",
      custom_palettes : Hash(String, Sunstone::Palette)? = nil,
      include_solvin_catalog : Bool = true,
    ) : String
      CatalogLoader.load_palettes_json(theme_name, custom_palettes, include_solvin_catalog)
    end

    # Finds a palette definition by ID.
    def self.find_palette(id : String, theme_name : String = "sol.vin") : PaletteDefinition?
      CatalogLoader.find_by_id(palettes(theme_name), id)
    end

    # Renders the canonical `#palette-swap-btn` HTML from a `SwapButtonSpec`.
    def self.swap_button(spec : SwapButtonSpec = SwapButtonSpec.new) : String
      Renderer.render_swap_button(spec)
    end

    # Renders the canonical `#palette-swap-btn` HTML using the declarative `DSL::ButtonBuilder`.
    def self.swap_button(&block : DSL::ButtonBuilder -> Nil) : String
      builder = DSL::ButtonBuilder.new
      yield builder
      builder.render
    end

    # Renders the deck-level `.sunstone-palette-toolbar` wrapping `#palette-swap-btn`.
    def self.toolbar(
      spec : SwapButtonSpec = SwapButtonSpec.new,
      toolbar_class : String = "sunstone-palette-toolbar",
    ) : String
      Renderer.render_toolbar(spec, toolbar_class)
    end

    # Renders the deck-level `.sunstone-palette-toolbar` using the declarative `DSL::ButtonBuilder`.
    def self.toolbar(
      toolbar_class : String = "sunstone-palette-toolbar",
      &block : DSL::ButtonBuilder -> Nil
    ) : String
      builder = DSL::ButtonBuilder.new
      yield builder
      builder.render_toolbar(toolbar_class)
    end

    # Renders the canonical `#palette-picker-modal-overlay` HTML from a `PickerModalSpec`.
    def self.picker_modal(
      spec : PickerModalSpec = PickerModalSpec.new,
      icon_renderer : (String -> String)? = nil,
    ) : String
      Renderer.render_picker_modal(spec, icon_renderer)
    end

    # Renders the canonical `#palette-picker-modal-overlay` HTML using the declarative `DSL::ModalBuilder`.
    def self.picker_modal(
      icon_renderer : (String -> String)? = nil,
      &block : DSL::ModalBuilder -> Nil
    ) : String
      builder = DSL::ModalBuilder.new
      yield builder
      builder.render(icon_renderer)
    end

    # Renders the floating `HoldClick` progress spinner SVG container.
    def self.hold_spinner(spec : HoldClickSpec = HoldClickSpec.new) : String
      Renderer.render_hold_spinner(spec)
    end

    # Renders the floating `HoldClick` progress spinner SVG container using the declarative `DSL::HoldClickBuilder`.
    def self.hold_spinner(&block : DSL::HoldClickBuilder -> Nil) : String
      builder = DSL::HoldClickBuilder.new
      yield builder
      builder.render
    end

    # Renders the `#duotone-svg-container` SVG filter block.
    def self.duotone_svg(palette : PaletteDefinition? = nil) : String
      Renderer.render_duotone_svg(palette)
    end

    # Renders static catalog grid items for a palette array.
    def self.catalog_grid(
      palettes_list : Array(PaletteDefinition) = palettes,
      active_index : Int32 = 0,
      grid_id : String = "palette-picker-grid",
    ) : String
      Renderer.render_catalog_grid(palettes_list, active_index, grid_id)
    end

    # Returns the modular standalone CSS stylesheet for the palette button, hold spinner, and catalog modal.
    def self.stylesheet(include_window_chrome : Bool = true) : String
      Renderer.render_css(include_window_chrome)
    end

    # Returns the zero-dependency `HoldClick` interaction controller JS source.
    def self.hold_click_js : String
      Renderer.hold_click_js
    end

    # Returns the zero-dependency `PaletteEngine` JS module source.
    def self.palette_engine_js : String
      Renderer.palette_engine_js
    end

    # Returns a combined JS bundle containing `HoldClick` + `PaletteEngine` (and optional `SITE_PALETTES` + auto-init).
    def self.bundle_js(palettes_json_str : String? = nil, auto_init : Bool = false) : String
      Renderer.bundle_js(palettes_json_str, auto_init)
    end

    # Declarative block builder returning a complete `ComponentBundle`.
    def self.build(
      icon_renderer : (String -> String)? = nil,
      &block : DSL::ComponentBuilder -> Nil
    ) : ComponentBundle
      builder = DSL::ComponentBuilder.new
      yield builder
      builder.build(icon_renderer)
    end

    # Returns the default `ComponentBundle` for a given theme or deck without block configuration.
    def self.default_bundle(
      theme_name : String = "sol.vin",
      default_label : String? = nil,
      custom_palettes : Hash(String, Sunstone::Palette)? = nil,
      icon_renderer : (String -> String)? = nil,
    ) : ComponentBundle
      build(icon_renderer) do |ctx|
        ctx.theme(theme_name)
        ctx.custom_palettes(custom_palettes)
        if default_label
          ctx.button do |btn|
            btn.default_label(default_label)
          end
        end
      end
    end
  end

  # Canonical alias exposing `Sunstone::PalettePicker` alongside `Sunstone::PaletteComponent`.
  alias PalettePicker = PaletteComponent
end
