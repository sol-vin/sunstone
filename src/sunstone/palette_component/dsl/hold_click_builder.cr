require "../core/models"
require "../core/renderer"

module Sunstone
  module PaletteComponent
    module DSL
      # Declarative builder for the HoldClick interaction controller and spinner.
      class HoldClickBuilder
        @hold_duration : Int32 = 2000
        @spinner_delay : Int32 = 500
        @spinner_id : String = "palette-hold-spinner"
        @spinner_class : String = "palette-hold-spinner hold-click-spinner"
        @spinner_radius : Float64 = 11.0
        @delegate_selector : String? = nil

        def hold_duration(@hold_duration : Int32) : self
          self
        end

        def spinner_delay(@spinner_delay : Int32) : self
          self
        end

        def spinner_id(@spinner_id : String) : self
          self
        end

        def spinner_class(@spinner_class : String) : self
          self
        end

        def spinner_radius(@spinner_radius : Float64) : self
          self
        end

        def delegate_selector(@delegate_selector : String?) : self
          self
        end

        def to_spec : HoldClickSpec
          HoldClickSpec.new(
            hold_duration: @hold_duration,
            spinner_delay: @spinner_delay,
            spinner_id: @spinner_id,
            spinner_class: @spinner_class,
            spinner_radius: @spinner_radius,
            delegate_selector: @delegate_selector
          )
        end

        def render : String
          Renderer.render_hold_spinner(to_spec)
        end
      end
    end
  end
end
