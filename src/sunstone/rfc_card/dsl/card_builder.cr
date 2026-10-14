require "../core/models"
require "../core/renderer"
require "./suggestion_builder"
require "./council_builder"

module Sunstone
  module RfcCard
    module DSL
      # Top-level Two-Tier Declarative Builder for the `rfc_card` slide component (`RfcCardSpec`).
      class CardBuilder
        @rfc_id : String = "RFC-112"
        @discussion_number : Int32? = nil
        @title : String = "Architectural Decision Matrix"
        @subtitle : String = ""
        @badge : String = "RFC DECISION MATRIX"
        @color : String = "accent"
        @status : String = "auto"
        @author : String = "Delta"
        @target_repo : String = "sol-vin/solvin-ai-org"
        @discussion_url : String = ""
        @summary : String = ""
        @compact : Bool? = nil
        @window_chrome : Bool = true
        @show_matrix_table : Bool = true
        @suggestions : Array(SuggestionItem) = [] of SuggestionItem
        @council_comments : Array(CouncilCommentSpec) = [] of CouncilCommentSpec

        def rfc_id(@rfc_id : String) : self
          self
        end

        def id(val : String) : self
          @rfc_id = val
          self
        end

        def discussion_number(num : Int32?) : self
          @discussion_number = num
          if num && @rfc_id == "RFC-112"
            @rfc_id = "RFC-#{num}"
          end
          self
        end

        def discussion(num : Int32) : self
          discussion_number(num)
        end

        def title(@title : String) : self
          self
        end

        def subtitle(@subtitle : String) : self
          self
        end

        def badge(@badge : String) : self
          self
        end

        def color(@color : String) : self
          self
        end

        def status(@status : String) : self
          self
        end

        def author(@author : String) : self
          self
        end

        def proposer(val : String) : self
          @author = val
          self
        end

        def target_repo(@target_repo : String) : self
          self
        end

        def repo(val : String) : self
          @target_repo = val
          self
        end

        def discussion_url(@discussion_url : String) : self
          self
        end

        def summary(@summary : String) : self
          self
        end

        def takeaway(val : String) : self
          @summary = val
          self
        end

        def compact(@compact : Bool) : self
          self
        end

        def window_chrome(@window_chrome : Bool) : self
          self
        end

        def show_matrix_table(@show_matrix_table : Bool) : self
          self
        end

        # Adds an `[AS-X]` atomic suggestion via a block receiver (`yield SuggestionBuilder`).
        def suggestion(id : String? = nil, &block : SuggestionBuilder -> Nil) : self
          next_id = id || "AS-#{@suggestions.size + 1}"
          builder = SuggestionBuilder.new(
            id: next_id,
            agent: @author,
            repo: @target_repo
          )
          yield builder
          @suggestions << builder.to_spec
          self
        end

        # Adds an `[AS-X]` atomic suggestion directly with keyword arguments.
        def suggestion(
          id : String,
          title : String,
          body : String = "",
          status : String = "pending",
          agent : String? = nil,
          greek_symbol : String? = nil,
          repo : String? = nil,
          work_order : String? = nil,
          issue : String | Int32 | Nil = nil,
          rationale : String = "",
        ) : self
          @suggestions << SuggestionItem.new(
            id: id,
            title: title,
            body: body,
            status: status,
            agent: agent || @author,
            greek_symbol: greek_symbol,
            repo: repo || @target_repo,
            work_order: work_order,
            issue: issue,
            rationale: rationale
          )
          self
        end

        # Alias for `suggestion` supporting `card.as_item("AS-1") { |s| ... }`.
        def as_item(id : String? = nil, &block : SuggestionBuilder -> Nil) : self
          suggestion(id, &block)
        end

        # Alias for `suggestion` supporting `card.as_item("AS-1", "Title", ...)`.
        def as_item(
          id : String,
          title : String,
          body : String = "",
          status : String = "pending",
          agent : String? = nil,
          greek_symbol : String? = nil,
          repo : String? = nil,
          work_order : String? = nil,
          issue : String | Int32 | Nil = nil,
          rationale : String = "",
        ) : self
          suggestion(
            id: id,
            title: title,
            body: body,
            status: status,
            agent: agent,
            greek_symbol: greek_symbol,
            repo: repo,
            work_order: work_order,
            issue: issue,
            rationale: rationale
          )
        end

        # Parses `[AS-X]` bullet lines from an RFC markdown text block and appends them to the decision matrix.
        def from_markdown(markdown : String) : self
          parsed = SuggestionItem.parse_markdown_suggestions(markdown, @author, @target_repo)
          @suggestions.concat(parsed)
          self
        end

        # Adds a specialist council deliberation entry via a block receiver (`yield CouncilCommentBuilder`).
        def council(agent : String = "Delta", &block : CouncilCommentBuilder -> Nil) : self
          builder = CouncilCommentBuilder.new(agent)
          yield builder
          @council_comments << builder.to_spec
          self
        end

        # Adds a specialist council deliberation entry directly with keyword arguments.
        def council(
          agent : String,
          perspective : String,
          role : String = "Specialist",
          greek_symbol : String? = nil,
          suggestion_ids : Array(String) = [] of String,
        ) : self
          @council_comments << CouncilCommentSpec.new(
            agent: agent,
            greek_symbol: greek_symbol,
            role: role,
            perspective: perspective,
            suggestion_ids: suggestion_ids
          )
          self
        end

        def to_spec : RfcCardSpec
          is_compact = @compact.nil? ? (@suggestions.size >= 4) : @compact.not_nil!
          RfcCardSpec.new(
            rfc_id: @rfc_id,
            discussion_number: @discussion_number,
            title: @title,
            subtitle: @subtitle,
            badge: @badge,
            color: @color,
            status: @status,
            author: @author,
            target_repo: @target_repo,
            discussion_url: @discussion_url,
            summary: @summary,
            compact: is_compact,
            window_chrome: @window_chrome,
            show_matrix_table: @show_matrix_table,
            suggestions: @suggestions.dup,
            council_comments: @council_comments.dup
          )
        end

        def render : String
          Renderer.render_html(to_spec)
        end

        def render_markdown : String
          Renderer.render_markdown(to_spec)
        end
      end

      alias RfcCardBuilder = CardBuilder
    end
  end
end
