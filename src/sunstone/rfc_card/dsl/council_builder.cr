require "../core/models"
require "../core/renderer"

module Sunstone
  module RfcCard
    module DSL
      # Declarative builder for a specialist council deliberation entry inside an RFC card.
      class CouncilCommentBuilder
        @agent : String
        @greek_symbol : String? = nil
        @role : String = "Specialist"
        @perspective : String = ""
        @suggestion_ids : Array(String) = [] of String

        def initialize(@agent : String = "Delta")
        end

        def agent(@agent : String) : self
          self
        end

        def greek_symbol(@greek_symbol : String?) : self
          self
        end

        def role(@role : String) : self
          self
        end

        def perspective(@perspective : String) : self
          self
        end

        def comment(val : String) : self
          @perspective = val
          self
        end

        def suggestion_ids(@suggestion_ids : Array(String)) : self
          self
        end

        def for_suggestions(*ids : String) : self
          @suggestion_ids = ids.to_a
          self
        end

        def to_spec : CouncilCommentSpec
          CouncilCommentSpec.new(
            agent: @agent,
            greek_symbol: @greek_symbol,
            role: @role,
            perspective: @perspective,
            suggestion_ids: @suggestion_ids
          )
        end

        def render : String
          Renderer.render_council_row(to_spec)
        end
      end
    end
  end
end
