require "../core/models"
require "../core/renderer"

module Sunstone
  module RfcCard
    module DSL
      # Declarative builder for an atomic suggestion (`[AS-X]`) row inside an RFC Decision Matrix card.
      class SuggestionBuilder
        @id : String
        @title : String
        @body : String = ""
        @status : String = "pending"
        @agent : String
        @greek_symbol : String? = nil
        @repo : String
        @work_order : String? = nil
        @issue : String? = nil
        @rationale : String = ""

        def initialize(
          @id : String = "AS-1",
          @title : String = "Untitled Suggestion",
          @agent : String = "Delta",
          @repo : String = "sol-vin/solvin-ai-org",
        )
        end

        def id(@id : String) : self
          self
        end

        def title(@title : String) : self
          self
        end

        def body(@body : String) : self
          self
        end

        def description(desc : String) : self
          @body = desc
          self
        end

        def status(@status : String) : self
          self
        end

        def decision(val : String) : self
          @status = val
          self
        end

        def approved! : self
          @status = "approved"
          self
        end

        def pending! : self
          @status = "pending"
          self
        end

        def shelved! : self
          @status = "shelved"
          self
        end

        def denied! : self
          @status = "shelved"
          self
        end

        def agent(@agent : String) : self
          self
        end

        def specialist(name : String) : self
          @agent = name
          self
        end

        def greek_symbol(@greek_symbol : String?) : self
          self
        end

        def repo(@repo : String) : self
          self
        end

        def repository(val : String) : self
          @repo = val
          self
        end

        def work_order(@work_order : String?) : self
          self
        end

        def wo(val : String?) : self
          @work_order = val
          self
        end

        def issue(val : String | Int32 | Nil) : self
          @issue = val.try(&.to_s)
          self
        end

        def rationale(@rationale : String) : self
          self
        end

        def tradeoff(val : String) : self
          @rationale = val
          self
        end

        def to_spec : SuggestionItem
          SuggestionItem.new(
            id: @id,
            title: @title,
            body: @body,
            status: @status,
            agent: @agent,
            greek_symbol: @greek_symbol,
            repo: @repo,
            work_order: @work_order,
            issue: @issue,
            rationale: @rationale
          )
        end

        def render : String
          Renderer.render_suggestion_row(to_spec)
        end
      end
    end
  end
end
