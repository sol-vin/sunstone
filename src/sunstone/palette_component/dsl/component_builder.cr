require "../core/models"
require "../core/catalog_loader"
require "../core/renderer"
require "./button_builder"
require "./modal_builder"
require "./hold_click_builder"

module Sunstone
  module PaletteComponent
    module DSL
      # Top-level Two-Tier Declarative Builder combining `#palette-swap-btn`, `HoldClick`,
      # `#palette-picker-modal-overlay`, and `PaletteEngine` JS/CSS modules for Sunstone slide decks.
      class ComponentBuilder
        getter button_builder : ButtonBuilder
        getter modal_builder : ModalBuilder
        getter hold_click_builder : HoldClickBuilder
        getter theme_name : String = "sol.vin"
        getter custom_palettes : Hash(String, Sunstone::Palette)? = nil
        getter include_solvin_catalog : Bool = true
        getter include_window_chrome : Bool = true
        getter auto_init_bundle : Bool = false
        getter toolbar_class : String = "sunstone-palette-toolbar"

        def initialize
          @button_builder = ButtonBuilder.new
          @modal_builder = ModalBuilder.new
          @hold_click_builder = HoldClickBuilder.new
        end

        def theme(@theme_name : String) : self
          self
        end

        def custom_palettes(@custom_palettes : Hash(String, Sunstone::Palette)?) : self
          self
        end

        def include_solvin_catalog(@include_solvin_catalog : Bool) : self
          self
        end

        def include_window_chrome(@include_window_chrome : Bool) : self
          self
        end

        def auto_init_bundle(@auto_init_bundle : Bool) : self
          self
        end

        def toolbar_class(@toolbar_class : String) : self
          self
        end

        def button(&block : ButtonBuilder -> Nil) : self
          yield @button_builder
          self
        end

        def modal(&block : ModalBuilder -> Nil) : self
          yield @modal_builder
          self
        end

        def hold_click(&block : HoldClickBuilder -> Nil) : self
          yield @hold_click_builder
          self
        end

        def build(icon_renderer : (String -> String)? = nil) : ComponentBundle
          palettes = CatalogLoader.load_palettes(@theme_name, @custom_palettes, @include_solvin_catalog)
          palettes_json = palettes.to_json
          default_palette = palettes.first?

          ComponentBundle.new(
            palettes: palettes,
            palettes_json: palettes_json,
            button_html: @button_builder.render,
            toolbar_html: @button_builder.render_toolbar(@toolbar_class),
            modal_html: @modal_builder.render(icon_renderer),
            spinner_html: @hold_click_builder.render,
            duotone_svg_html: Renderer.render_duotone_svg(default_palette),
            css: Renderer.render_css(@include_window_chrome),
            hold_click_js: Renderer.hold_click_js,
            palette_engine_js: Renderer.palette_engine_js,
            bundle_js: Renderer.bundle_js(palettes_json, @auto_init_bundle)
          )
        end
      end
    end
  end
end
