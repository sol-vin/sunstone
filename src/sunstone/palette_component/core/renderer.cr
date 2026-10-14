require "html"
require "./models"
require "./icons"
require "../../assets"

module Sunstone
  module PaletteComponent
    module Renderer
      # Renders the canonical `#palette-swap-btn` button HTML with zero inline styles.
      def self.render_swap_button(spec : SwapButtonSpec = SwapButtonSpec.new) : String
        String.build do |io|
          io << %(<button id="#{HTML.escape(spec.id)}" class="#{HTML.escape(spec.css_class)}" type="button" aria-label="#{HTML.escape(spec.aria_label)}" data-tooltip="#{HTML.escape(spec.tooltip)}">\n)
          io << %(  [ #{HTML.escape(spec.prefix_text)} <span id="#{HTML.escape(spec.preview_id)}" class="#{HTML.escape(spec.preview_class)}">#{HTML.escape(spec.dot_symbol)}</span><span id="#{HTML.escape(spec.label_id)}">#{HTML.escape(spec.default_label)}</span> ]\n)
          io << %(</button>)
        end
      end

      # Renders the fixed deck toolbar wrapping `#palette-swap-btn` with zero inline styles.
      def self.render_toolbar(
        spec : SwapButtonSpec = SwapButtonSpec.new,
        toolbar_class : String = "sunstone-palette-toolbar",
      ) : String
        String.build do |io|
          io << %(<div class="#{HTML.escape(toolbar_class)}">\n)
          io << "  " << render_swap_button(spec).gsub("\n", "\n  ") << "\n"
          io << %(</div>)
        end
      end

      # Renders the canonical `#palette-picker-modal-overlay` catalog modal HTML using FontAwesome SVGs.
      def self.render_picker_modal(
        spec : PickerModalSpec = PickerModalSpec.new,
        icon_renderer : (String -> String)? = nil,
      ) : String
        render_icon = icon_renderer || ->(name : String) { Icons.render(name) }

        header_svg = render_icon.call(spec.header_icon)
        bracket_left_svg = render_icon.call("bracket-square.svg")
        xmark_svg = render_icon.call("xmark.svg")
        bracket_right_svg = render_icon.call("bracket-square-right.svg")
        dice_svg = render_icon.call(spec.random_icon)

        String.build do |io|
          io << %(<div id="#{HTML.escape(spec.overlay_id)}" class="#{HTML.escape(spec.overlay_class)}" role="dialog" aria-modal="true" aria-labelledby="#{HTML.escape(spec.title_id)}">\n)
          io << %(  <div class="#{HTML.escape(spec.window_class)}">\n)
          io << %(    <div class="window-header window-header-flex">\n)
          io << %(      <h1 id="#{HTML.escape(spec.title_id)}" class="window-title palette-modal-title">\n)
          io << %(        <span class="window-header-icon" title="Theme Palette Selector">#{header_svg}</span>#{HTML.escape(spec.title_text)}\n)
          io << %(      </h1>\n)
          io << %(      <div class="window-controls">\n)
          io << %(        <button type="button" id="#{HTML.escape(spec.close_btn_id)}" class="window-btn window-btn-close" title="#{HTML.escape(spec.close_btn_title)}"><span class="window-btn-bracket">#{bracket_left_svg}</span><span class="window-btn-icon-wrap">#{xmark_svg}</span><span class="window-btn-bracket">#{bracket_right_svg}</span></button>\n)
          io << %(      </div>\n)
          io << %(    </div>\n)
          io << %(    <div class="window-body palette-modal-body">\n)
          io << %(      <div class="palette-modal-top-bar">\n)
          io << %(        <p class="palette-modal-text">#{HTML.escape(spec.description_text)}</p>\n)
          io << %(        <button id="#{HTML.escape(spec.random_btn_id)}" type="button" class="export-btn export-btn-bold-sm" title="#{HTML.escape(spec.random_btn_title)}">#{dice_svg} #{HTML.escape(spec.random_btn_label)}</button>\n)
          io << %(      </div>\n)
          io << %(      <div id="#{HTML.escape(spec.grid_id)}"></div>\n)
          io << %(    </div>\n)
          io << %(  </div>\n)
          io << %(</div>)
        end
      end

      # Renders the floating HoldClick progress spinner SVG container with zero inline styles.
      def self.render_hold_spinner(spec : HoldClickSpec = HoldClickSpec.new) : String
        String.build do |io|
          io << %(<div id="#{HTML.escape(spec.spinner_id)}" class="#{HTML.escape(spec.spinner_class)}">)
          io << %(<svg width="32" height="32" viewBox="0 0 32 32">)
          io << %(<circle cx="16" cy="16" r="14" class="spinner-base" />)
          io << %(<circle cx="16" cy="16" r="#{spec.spinner_radius}" class="spinner-track" />)
          io << %(<circle cx="16" cy="16" r="#{spec.spinner_radius}" class="spinner-progress" />)
          io << %(<circle cx="16" cy="16" r="3.5" class="spinner-dot" />)
          io << %(</svg>)
          io << %(</div>)
        end
      end

      # Renders the `#duotone-svg-container` SVG filter block with zero inline styles.
      def self.render_duotone_svg(palette : PaletteDefinition? = nil) : String
        matrix_values = palette ? palette.duotone_matrix_values(0.0) : "0.2126 0.7152 0.0722 0 0  0.2126 0.7152 0.0722 0 0  0.2126 0.7152 0.0722 0 0  0 0 0 1 0"
        String.build do |io|
          io << %(<svg id="duotone-svg-container" class="solvin-palette-filters" aria-hidden="true">\n)
          io << %(  <filter id="palette-duotone-filter" color-interpolation-filters="sRGB">\n)
          io << %(    <feColorMatrix id="palette-duotone-matrix" type="matrix" values="#{matrix_values}"/>\n)
          io << %(  </filter>\n)
          io << %(</svg>)
        end
      end

      # Renders a single static catalog grid item button with semantic classes and data attributes (zero inline styles).
      def self.render_grid_item(palette : PaletteDefinition, index : Int32, is_active : Bool = false) : String
        active_cls = is_active ? " is-active" : ""
        label = palette.name.empty? ? palette.id : palette.name

        String.build do |io|
          io << %(<button type="button" class="export-btn palette-grid-item-btn#{active_cls}" data-palette="#{HTML.escape(palette.id)}" data-palette-id="#{HTML.escape(palette.id)}" data-palette-index="#{index}">)
          io << %(<span class="palette-grid-item-label">)
          io << %(<span class="palette-grid-item-dot">●</span> )
          io << %(<span>#{HTML.escape(label)}</span>)
          io << %(</span>)
          io << %(<span class="palette-grid-item-index">[ ##{index + 1} ]</span>)
          io << %(</button>)
        end
      end

      # Renders the full catalog grid container populated with all palette buttons.
      def self.render_catalog_grid(
        palettes : Array(PaletteDefinition),
        active_index : Int32 = 0,
        grid_id : String = "palette-picker-grid",
      ) : String
        String.build do |io|
          io << %(<div id="#{HTML.escape(grid_id)}">)
          palettes.each_with_index do |pal, idx|
            io << render_grid_item(pal, idx, idx == active_index)
          end
          io << %(</div>)
        end
      end

      # Returns the modular CSS stylesheet for `#palette-swap-btn`, `HoldClick` spinner, and `#palette-picker-modal-overlay`.
      def self.render_css(include_window_chrome : Bool = true) : String
        Assets::PALETTE_COMPONENT_CSS
      end

      # Returns the canonical `HoldClick` interaction controller JS source.
      def self.hold_click_js : String
        Assets::HOLD_CLICK_JS
      end

      # Returns the canonical `PaletteEngine` JS module source.
      def self.palette_engine_js : String
        Assets::PALETTE_ENGINE_JS
      end

      # Returns a zero-dependency combined JS bundle with `HoldClick`, `PaletteEngine`, and optional embedded catalog.
      def self.bundle_js(palettes_json : String? = nil, auto_init : Bool = false) : String
        String.build do |io|
          if palettes_json
            io << "window.SITE_PALETTES = " << palettes_json << ";\n"
          end
          io << hold_click_js << "\n"
          io << palette_engine_js << "\n"
          if auto_init
            io << "(function() {\n"
            io << "  if (typeof window !== 'undefined' && window.PaletteEngine) {\n"
            io << "    if (window.SITE_PALETTES) window.PaletteEngine.initHead(window.SITE_PALETTES);\n"
            io << "    if (typeof document !== 'undefined') {\n"
            io << "      if (document.readyState === 'loading') {\n"
            io << "        document.addEventListener('DOMContentLoaded', function() { window.PaletteEngine.initDom(); });\n"
            io << "      } else {\n"
            io << "        window.PaletteEngine.initDom();\n"
            io << "      }\n"
            io << "    }\n"
            io << "  }\n"
            io << "})();\n"
          end
        end
      end
    end
  end
end
