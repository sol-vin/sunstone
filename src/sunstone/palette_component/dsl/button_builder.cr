require "../core/models"
require "../core/renderer"

module Sunstone
  module PaletteComponent
    module DSL
      # Declarative builder for the `#palette-swap-btn` component.
      class ButtonBuilder
        @id : String = "palette-swap-btn"
        @css_class : String = "palette-swap-btn"
        @preview_id : String = "palette-color-preview"
        @preview_class : String = "palette-color-preview"
        @label_id : String = "palette-name-label"
        @default_label : String = "Warm Paper (Default)"
        @prefix_text : String = "PALETTE:"
        @dot_symbol : String = "●"
        @aria_label : String = "Swap Color Palette"
        @tooltip : String = "Left-click: Next | Right-click: Prev | Left Hold: Palette Selection Menu | Right Hold: Reset Default"

        def id(@id : String) : self
          self
        end

        def css_class(@css_class : String) : self
          self
        end

        def preview_id(@preview_id : String) : self
          self
        end

        def preview_class(@preview_class : String) : self
          self
        end

        def label_id(@label_id : String) : self
          self
        end

        def default_label(@default_label : String) : self
          self
        end

        def prefix_text(@prefix_text : String) : self
          self
        end

        def dot_symbol(@dot_symbol : String) : self
          self
        end

        def aria_label(@aria_label : String) : self
          self
        end

        def tooltip(@tooltip : String) : self
          self
        end

        def to_spec : SwapButtonSpec
          SwapButtonSpec.new(
            id: @id,
            css_class: @css_class,
            preview_id: @preview_id,
            preview_class: @preview_class,
            label_id: @label_id,
            default_label: @default_label,
            prefix_text: @prefix_text,
            dot_symbol: @dot_symbol,
            aria_label: @aria_label,
            tooltip: @tooltip
          )
        end

        def render : String
          Renderer.render_swap_button(to_spec)
        end

        def render_toolbar(toolbar_class : String = "sunstone-palette-toolbar") : String
          Renderer.render_toolbar(to_spec, toolbar_class)
        end
      end
    end
  end
end
