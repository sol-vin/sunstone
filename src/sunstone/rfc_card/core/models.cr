require "yaml"
require "json"

module Sunstone
  module RfcCard
    # Pure, strongly-typed atomic suggestion (`[AS-X]`) specification for RFC decision matrices.
    struct SuggestionItem
      GREEK_SYMBOLS = {
        "alpha"   => "Α",
        "beta"    => "Β",
        "gamma"   => "Γ",
        "delta"   => "Δ",
        "epsilon" => "Ε",
        "zeta"    => "Ζ",
        "eta"     => "Η",
        "theta"   => "Θ",
        "iota"    => "Ι",
        "kappa"   => "Κ",
        "lambda"  => "Λ",
        "mu"      => "Μ",
        "nu"      => "Ν",
        "xi"      => "Ξ",
        "omicron" => "Ο",
        "pi"      => "Π",
        "rho"     => "Ρ",
        "sigma"   => "Σ",
        "tau"     => "Τ",
        "upsilon" => "Υ",
        "phi"     => "Φ",
        "chi"     => "Χ",
        "psi"     => "Ψ",
        "omega"   => "Ω",
      }

      getter id : String
      getter title : String
      getter body : String
      getter status : String
      getter agent : String
      getter greek_symbol : String
      getter repo : String
      getter work_order : String?
      getter issue : String?
      getter rationale : String

      def initialize(
        id : String,
        @title : String,
        @body : String = "",
        status : String = "pending",
        @agent : String = "Delta",
        greek_symbol : String? = nil,
        @repo : String = "sol-vin/solvin-ai-org",
        @work_order : String? = nil,
        issue : String | Int32 | Nil = nil,
        @rationale : String = "",
      )
        @id = SuggestionItem.normalize_id(id)
        @status = SuggestionItem.normalize_status(status)
        resolved_symbol = greek_symbol.try(&.strip)
        @greek_symbol = if resolved_symbol && !resolved_symbol.empty?
                          resolved_symbol
                        else
                          SuggestionItem.greek_for_agent(@agent)
                        end
        @issue = if iss = issue
                   s = iss.to_s.strip
                   if s.empty?
                     nil
                   elsif s.starts_with?('#') || s.starts_with?("http")
                     s
                   else
                     "##{s}"
                   end
                 else
                   nil
                 end
      end

      def self.normalize_id(raw_id : String, fallback_index : Int32 = 1) : String
        cleaned = raw_id.strip.gsub(/^\[|\]$/, "").upcase
        if cleaned.empty?
          "AS-#{fallback_index}"
        elsif cleaned.matches?(/^\d+$/)
          "AS-#{cleaned}"
        elsif cleaned.starts_with?("AS") && !cleaned.starts_with?("AS-")
          "AS-#{cleaned[2..]}"
        else
          cleaned
        end
      end

      def self.normalize_status(raw_status : String) : String
        case raw_status.strip.downcase
        when "approved", "approve", "accepted", "done", "merged", "completed"
          "approved"
        when "shelved", "shelve", "denied", "deny", "rejected", "deferred"
          "shelved"
        else
          "pending"
        end
      end

      def self.greek_for_agent(agent_name : String) : String
        key = agent_name.strip.downcase.split(/\s+|\(/).first? || ""
        GREEK_SYMBOLS[key]? || "Δ"
      end

      # Returns the canonical bracketed tag (e.g., `"[AS-1]"`).
      def tag : String
        "[#{@id}]"
      end

      def normalized_status : String
        @status
      end

      def status_label : String
        case @status
        when "approved" then "APPROVED"
        when "shelved"  then "SHELVED"
        else                 "PENDING"
        end
      end

      def status_color : String
        case @status
        when "approved" then "emerald"
        when "shelved"  then "rose"
        else                 "amber"
        end
      end

      def status_icon : String
        case @status
        when "approved" then "circle-check"
        when "shelved"  then "ban"
        else                 "clock"
        end
      end

      def self.parse_markdown_line(
        line : String,
        fallback_index : Int32 = 1,
        default_agent : String = "Delta",
        default_repo : String = "sol-vin/solvin-ai-org",
      ) : SuggestionItem?
        stripped = line.strip.sub(/^[-*+]\s+/, "")
        return nil if stripped.empty?

        # Match patterns like: **[AS-1]**: (Repo: sol-vin/sunstone, Agent: Sigma) Add declarative rfc_card...
        if m = stripped.match(/^(?:\*\*)?\[?(AS-\d+)\]?(?:\*\*)?\s*:?\s*(?:\(([^)]+)\))?\s*(.+)$/i)
          as_id = m[1].upcase
          meta_str = m[2]? || ""
          rest_title = m[3].strip
          repo = default_repo
          agent = default_agent
          status = "pending"
          wo_id : String? = nil

          if repo_m = meta_str.match(/repo\s*:\s*([^,\)]+)/i)
            repo = repo_m[1].strip.gsub("`", "")
          end
          if agent_m = meta_str.match(/agent\s*:\s*([^,\)]+)/i)
            agent = agent_m[1].strip.gsub("`", "")
          end
          if status_m = meta_str.match(/status\s*:\s*([^,\)]+)/i)
            status = status_m[1].strip.gsub("`", "")
          end
          if wo_m = meta_str.match(/(?:wo|work_order)\s*:\s*([^,\)]+)/i)
            wo_id = wo_m[1].strip.gsub("`", "")
          end

          return SuggestionItem.new(
            id: as_id,
            title: rest_title,
            status: status,
            agent: agent,
            repo: repo,
            work_order: wo_id
          )
        end

        nil
      end

      def self.parse_markdown_suggestions(
        markdown : String,
        default_agent : String = "Delta",
        default_repo : String = "sol-vin/solvin-ai-org",
      ) : Array(SuggestionItem)
        items = [] of SuggestionItem
        idx = 1
        markdown.each_line do |line|
          if item = parse_markdown_line(line, idx, default_agent, default_repo)
            items << item
            idx += 1
          end
        end
        items
      end

      def self.from_yaml(
        node : YAML::Any,
        fallback_index : Int32 = 1,
        default_agent : String = "Delta",
        default_repo : String = "sol-vin/solvin-ai-org",
      ) : SuggestionItem
        if str = node.as_s?
          if parsed = parse_markdown_line(str, fallback_index, default_agent, default_repo)
            return parsed
          end
          return SuggestionItem.new(
            id: "AS-#{fallback_index}",
            title: str.strip,
            agent: default_agent,
            repo: default_repo
          )
        end

        raw_id = node["id"]?.try(&.as_s) || node["as_id"]?.try(&.as_s) || "AS-#{fallback_index}"
        title = node["title"]?.try(&.as_s) || node["summary"]?.try(&.as_s) || node["text"]?.try(&.as_s) || "Untitled Suggestion"
        body = node["body"]?.try(&.as_s) || node["description"]?.try(&.as_s) || node["desc"]?.try(&.as_s) || ""
        status = node["status"]?.try(&.as_s) || node["decision"]?.try(&.as_s) || "pending"
        agent = node["agent"]?.try(&.as_s) || node["specialist"]?.try(&.as_s) || node["owner"]?.try(&.as_s) || default_agent
        greek = node["greek_symbol"]?.try(&.as_s) || node["greek"]?.try(&.as_s)
        repo = node["repo"]?.try(&.as_s) || node["repository"]?.try(&.as_s) || default_repo
        wo = node["work_order"]?.try(&.as_s) || node["wo"]?.try(&.as_s) || node["tracked_wo_id"]?.try(&.as_s)
        issue = node["issue"]?.try { |v| v.as_s? || v.as_i?.try(&.to_s) } || node["tracked_issue"]?.try { |v| v.as_s? || v.as_i?.try(&.to_s) }
        rationale = node["rationale"]?.try(&.as_s) || node["tradeoff"]?.try(&.as_s) || node["impact"]?.try(&.as_s) || ""

        SuggestionItem.new(
          id: raw_id,
          title: title,
          body: body,
          status: status,
          agent: agent,
          greek_symbol: greek,
          repo: repo,
          work_order: wo,
          issue: issue,
          rationale: rationale
        )
      end

      def self.from_json(
        node : JSON::Any,
        fallback_index : Int32 = 1,
        default_agent : String = "Delta",
        default_repo : String = "sol-vin/solvin-ai-org",
      ) : SuggestionItem
        if str = node.as_s?
          if parsed = parse_markdown_line(str, fallback_index, default_agent, default_repo)
            return parsed
          end
          return SuggestionItem.new(
            id: "AS-#{fallback_index}",
            title: str.strip,
            agent: default_agent,
            repo: default_repo
          )
        end

        raw_id = node["id"]?.try(&.as_s) || node["as_id"]?.try(&.as_s) || "AS-#{fallback_index}"
        title = node["title"]?.try(&.as_s) || node["summary"]?.try(&.as_s) || "Untitled Suggestion"
        body = node["body"]?.try(&.as_s) || node["description"]?.try(&.as_s) || ""
        status = node["status"]?.try(&.as_s) || node["decision"]?.try(&.as_s) || "pending"
        agent = node["agent"]?.try(&.as_s) || default_agent
        greek = node["greek_symbol"]?.try(&.as_s)
        repo = node["repo"]?.try(&.as_s) || default_repo
        wo = node["work_order"]?.try(&.as_s) || node["tracked_wo_id"]?.try(&.as_s)
        issue = node["issue"]?.try { |v| v.as_s? || v.as_i?.try(&.to_s) } || node["tracked_issue"]?.try { |v| v.as_s? || v.as_i?.try(&.to_s) }
        rationale = node["rationale"]?.try(&.as_s) || ""

        SuggestionItem.new(
          id: raw_id,
          title: title,
          body: body,
          status: status,
          agent: agent,
          greek_symbol: greek,
          repo: repo,
          work_order: wo,
          issue: issue,
          rationale: rationale
        )
      end
    end

    alias AtomicSuggestionSpec = SuggestionItem

    # Pure specification for a specialist council deliberation entry on an RFC card.
    struct CouncilCommentSpec
      getter agent : String
      getter greek_symbol : String
      getter role : String
      getter perspective : String
      getter suggestion_ids : Array(String)

      def initialize(
        @agent : String,
        greek_symbol : String? = nil,
        @role : String = "Specialist",
        @perspective : String = "",
        suggestion_ids : Array(String) = [] of String,
      )
        resolved_symbol = greek_symbol.try(&.strip)
        @greek_symbol = if resolved_symbol && !resolved_symbol.empty?
                          resolved_symbol
                        else
                          SuggestionItem.greek_for_agent(@agent)
                        end
        @suggestion_ids = suggestion_ids.map { |s| SuggestionItem.normalize_id(s) }
      end

      def self.from_yaml(node : YAML::Any) : CouncilCommentSpec
        agent = node["agent"]?.try(&.as_s) || node["agent_name"]?.try(&.as_s) || "Delta"
        greek = node["greek_symbol"]?.try(&.as_s) || node["greek"]?.try(&.as_s)
        role = node["role"]?.try(&.as_s) || "Specialist"
        perspective = node["perspective"]?.try(&.as_s) || node["comment"]?.try(&.as_s) || node["body"]?.try(&.as_s) || ""
        ids = [] of String
        if raw_ids = node["suggestion_ids"]?.try(&.as_a) || node["suggestions"]?.try(&.as_a)
          raw_ids.each do |it|
            if s = it.as_s?
              ids << s
            end
          end
        end
        CouncilCommentSpec.new(
          agent: agent,
          greek_symbol: greek,
          role: role,
          perspective: perspective,
          suggestion_ids: ids
        )
      end
    end

    # Pure, strongly-typed RFC Decision Matrix Card specification (`RfcCardSpec`).
    struct RfcCardSpec
      getter rfc_id : String
      getter discussion_number : Int32?
      getter title : String
      getter subtitle : String
      getter badge : String
      getter color : String
      getter status : String
      getter author : String
      getter target_repo : String
      getter discussion_url : String
      getter summary : String
      getter compact : Bool
      getter window_chrome : Bool
      getter show_matrix_table : Bool
      getter suggestions : Array(SuggestionItem)
      getter council_comments : Array(CouncilCommentSpec)

      def initialize(
        @rfc_id : String = "RFC-112",
        @discussion_number : Int32? = nil,
        @title : String = "Architectural Decision Matrix",
        @subtitle : String = "",
        @badge : String = "RFC DECISION MATRIX",
        @color : String = "accent",
        @status : String = "auto",
        @author : String = "Delta",
        @target_repo : String = "sol-vin/solvin-ai-org",
        @discussion_url : String = "",
        @summary : String = "",
        @compact : Bool = false,
        @window_chrome : Bool = true,
        @show_matrix_table : Bool = true,
        @suggestions : Array(SuggestionItem) = [] of SuggestionItem,
        @council_comments : Array(CouncilCommentSpec) = [] of CouncilCommentSpec,
      )
      end

      def total_count : Int32
        @suggestions.size
      end

      def approved_count : Int32
        @suggestions.count { |s| s.normalized_status == "approved" }
      end

      def pending_count : Int32
        @suggestions.count { |s| s.normalized_status == "pending" }
      end

      def shelved_count : Int32
        @suggestions.count { |s| s.normalized_status == "shelved" }
      end

      # Resolves overall RFC status from explicit `@status` or derived from `[AS-X]` items.
      def effective_status : String
        norm = @status.strip.downcase
        if norm != "auto" && !norm.empty?
          case norm
          when "approved", "approve", "accepted", "merged" then return "approved"
          when "shelved", "denied", "rejected"             then return "shelved"
          when "partial"                                   then return "partial"
          when "pending", "open", "review"                 then return "pending"
          end
        end

        return "pending" if @suggestions.empty?
        if approved_count == total_count
          "approved"
        elsif shelved_count == total_count
          "shelved"
        elsif approved_count > 0
          "partial"
        else
          "pending"
        end
      end

      def status_badge_text : String
        case effective_status
        when "approved"
          total_count > 0 ? "APPROVED (#{approved_count}/#{total_count})" : "APPROVED"
        when "partial"
          "PARTIAL (#{approved_count}/#{total_count} APPROVED)"
        when "shelved"
          "SHELVED"
        else
          total_count > 0 ? "PENDING (#{pending_count}/#{total_count})" : "PENDING APPROVAL"
        end
      end

      def resolved_discussion_label : String
        if num = @discussion_number
          "##{num}"
        elsif m = @rfc_id.match(/(\d+)/)
          "##{m[1]}"
        else
          @rfc_id
        end
      end

      def self.from_yaml(data : YAML::Any) : RfcCardSpec
        disc_num = data["discussion_number"]?.try(&.as_i?) || data["discussion"]?.try(&.as_i?)
        rfc_id = data["rfc_id"]?.try(&.as_s) || data["id"]?.try(&.as_s) || (disc_num ? "RFC-#{disc_num}" : "RFC-001")
        title = data["title"]?.try(&.as_s) || "Architectural Decision Matrix"
        subtitle = data["subtitle"]?.try(&.as_s) || ""
        badge = data["badge"]?.try(&.as_s) || "RFC DECISION MATRIX"
        color = data["color"]?.try(&.as_s) || "accent"
        status = data["status"]?.try(&.as_s) || "auto"
        author = data["author"]?.try(&.as_s) || data["agent"]?.try(&.as_s) || data["proposer"]?.try(&.as_s) || "Delta"
        target_repo = data["target_repo"]?.try(&.as_s) || data["repo"]?.try(&.as_s) || "sol-vin/solvin-ai-org"
        discussion_url = data["discussion_url"]?.try(&.as_s) || data["url"]?.try(&.as_s) || ""
        summary = data["summary"]?.try(&.as_s) || data["takeaway"]?.try(&.as_s) || ""
        window_chrome = data["window_chrome"]?.try(&.as_bool?) != false
        show_matrix_table = data["show_matrix_table"]?.try(&.as_bool?) != false

        suggestions = [] of SuggestionItem
        raw_list = data["suggestions"]?.try(&.as_a?) || data["decisions"]?.try(&.as_a?) || data["matrix"]?.try(&.as_a?) || data["items"]?.try(&.as_a?)
        if raw_list
          raw_list.each_with_index do |item_node, idx|
            suggestions << SuggestionItem.from_yaml(item_node, idx + 1, author, target_repo)
          end
        elsif md = data["markdown"]?.try(&.as_s?) || data["body"]?.try(&.as_s?)
          suggestions = SuggestionItem.parse_markdown_suggestions(md, author, target_repo)
        end

        councils = [] of CouncilCommentSpec
        if raw_councils = data["council_comments"]?.try(&.as_a?) || data["council"]?.try(&.as_a?)
          raw_councils.each do |c_node|
            councils << CouncilCommentSpec.from_yaml(c_node)
          end
        end

        compact = data["compact"]?.try(&.as_bool?) || (suggestions.size >= 4)

        RfcCardSpec.new(
          rfc_id: rfc_id,
          discussion_number: disc_num,
          title: title,
          subtitle: subtitle,
          badge: badge,
          color: color,
          status: status,
          author: author,
          target_repo: target_repo,
          discussion_url: discussion_url,
          summary: summary,
          compact: compact,
          window_chrome: window_chrome,
          show_matrix_table: show_matrix_table,
          suggestions: suggestions,
          council_comments: councils
        )
      end
    end

    alias DecisionMatrixSpec = RfcCardSpec
  end
end
