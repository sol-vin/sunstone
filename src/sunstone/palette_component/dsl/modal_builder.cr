require "../core/models"
require "../core/renderer"

module Sunstone
  module PaletteComponent
    module DSL
      # Declarative builder for the `#palette-picker-modal-overlay` catalog modal component.
      class ModalBuilder
        @overlay_id : String = "palette-picker-modal-overlay"
        @overlay_class : String = "skill-modal-overlay"
        @window_class : String = "terminal-window skill-modal-window palette-picker-window"
        @title_id : String = "palette-picker-modal-title"
        @title_text : String = "THEME // Palette Selector // Color Catalog"
        @header_icon : String = "palette.svg"
        @close_btn_id : String = "palette-picker-modal-close"
        @close_btn_title : String = "Close Catalog"
        @description_text : String = "Select a theme palette from the catalog below to instantly customize slide deck appearance:"
        @random_btn_id : String = "palette-picker-random-btn"
        @random_btn_label : String = "[ RANDOM // Palette ]"
        @random_btn_title : String = "Pick Random Palette"
        @random_icon : String = "dice.svg"
        @grid_id : String = "palette-picker-grid"
        @storage_key : String = "solvin_palette_id"
        @channel_name : String = "solvin_palette_channel"

        def overlay_id(@overlay_id : String) : self
          self
        end

        def overlay_class(@overlay_class : String) : self
          self
        end

        def window_class(@window_class : String) : self
          self
        end

        def title_id(@title_id : String) : self
          self
        end

        def title_text(@title_text : String) : self
          self
        end

        def header_icon(@header_icon : String) : self
          self
        end

        def close_btn_id(@close_btn_id : String) : self
          self
        end

        def close_btn_title(@close_btn_title : String) : self
          self
        end

        def description_text(@description_text : String) : self
          self
        end

        def random_btn_id(@random_btn_id : String) : self
          self
        end

        def random_btn_label(@random_btn_label : String) : self
          self
        end

        def random_btn_title(@random_btn_title : String) : self
          self
        end

        def random_icon(@random_icon : String) : self
          self
        end

        def grid_id(@grid_id : String) : self
          self
        end

        def storage_key(@storage_key : String) : self
          self
        end

        def channel_name(@channel_name : String) : self
          self
        end

        def to_spec : PickerModalSpec
          PickerModalSpec.new(
            overlay_id: @overlay_id,
            overlay_class: @overlay_class,
            window_class: @window_class,
            title_id: @title_id,
            title_text: @title_text,
            header_icon: @header_icon,
            close_btn_id: @close_btn_id,
            close_btn_title: @close_btn_title,
            description_text: @description_text,
            random_btn_id: @random_btn_id,
            random_btn_label: @random_btn_label,
            random_btn_title: @random_btn_title,
            random_icon: @random_icon,
            grid_id: @grid_id,
            storage_key: @storage_key,
            channel_name: @channel_name
          )
        end

        def render(icon_renderer : (String -> String)? = nil) : String
          Renderer.render_picker_modal(to_spec, icon_renderer)
        end
      end
    end
  end
end
