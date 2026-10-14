require "html"
require "./models"
require "../../icon_registry"

module Sunstone
  module RfcCard
    # Pure, stateless HTML, Markdown, and CSS renderer for `RfcCardSpec` (`[AS-X]` Architectural Decision Matrices).
    # Adheres strictly to the Sunstone Zero-Inline-Styles standard and FontAwesome SVG Icon Registry mandate.
    module Renderer
      extend self

      def render_html(spec : RfcCardSpec) : String
        color = spec.color.strip.empty? ? "accent" : spec.color.strip
        eff_status = spec.effective_status
        is_compact = spec.compact || spec.suggestions.size >= 4
        compact_cls = is_compact ? " compact" : ""
        compact_attr = is_compact ? " data-density=\"compact\"" : ""
        chrome_cls = spec.window_chrome ? " terminal-window rfc-window" : ""

        String.build do |str|
          str << "            <div class=\"card rfc-card col " << HTML.escape(color) << compact_cls << chrome_cls
          str << "\" data-component=\"rfc-card\" data-rfc-id=\"" << HTML.escape(spec.rfc_id)
          str << "\" data-status=\"" << HTML.escape(eff_status)
          str << "\" data-color=\"" << HTML.escape(color) << "\"" << compact_attr << ">\n"

          if spec.window_chrome
            str << "              <div class=\"window-header rfc-window-header\">\n"
            str << "                <div class=\"terminal-dots\">\n"
            str << "                  <span class=\"terminal-dot dot-1 red\" title=\"Close\"></span>\n"
            str << "                  <span class=\"terminal-dot dot-2 yellow\" title=\"Minimize\"></span>\n"
            str << "                  <span class=\"terminal-dot dot-3 green\" title=\"Maximize\"></span>\n"
            str << "                </div>\n"
            str << "                <span class=\"window-title rfc-window-title\">"
            str << IconRegistry.render("scroll", "rfc-header-icon") << " "
            str << HTML.escape(spec.rfc_id) << " // " << HTML.escape(spec.badge)
            str << "</span>\n"
            str << "                <div class=\"window-controls\">\n"
            str << "                  <span class=\"lang-tag rfc-status-pill " << HTML.escape(eff_status) << "\" data-status=\"" << HTML.escape(eff_status) << "\">"
            str << HTML.escape(spec.status_badge_text) << "</span>\n"
            str << "                  <span class=\"window-btn close\" title=\"Close\">" << IconRegistry.render("xmark") << "</span>\n"
            str << "                </div>\n"
            str << "              </div>\n"
          end

          str << "              <div class=\"card-header rfc-card-header " << HTML.escape(color) << "\">\n"
          str << "                <div class=\"rfc-title-group\">\n"
          str << "                  <span class=\"badge rfc-id-badge " << HTML.escape(color) << "\" data-color=\"" << HTML.escape(color) << "\">"
          str << IconRegistry.render("scroll") << " " << HTML.escape(spec.rfc_id) << "</span>\n"
          str << "                  <span class=\"card-title rfc-card-title\">" << IconRegistry.replace_icons(HTML.escape(spec.title)) << "</span>\n"
          str << "                </div>\n"
          str << "                <span class=\"badge rfc-overall-badge " << HTML.escape(eff_status) << "\" data-status=\"" << HTML.escape(eff_status) << "\">"
          str << status_icon_svg(eff_status) << " " << HTML.escape(spec.status_badge_text) << "</span>\n"
          str << "              </div>\n"

          unless spec.subtitle.strip.empty?
            str << "              <p class=\"rfc-card-subtitle\">" << IconRegistry.replace_icons(HTML.escape(spec.subtitle)) << "</p>\n"
          end

          # Metadata strip (Proposer, Target Repo, Discussion, Tally)
          str << "              <div class=\"rfc-meta-strip\">\n"
          str << "                <span class=\"rfc-meta-pill rfc-proposer-pill\">"
          str << IconRegistry.render("user") << " Proposer: <strong>" << HTML.escape(spec.author)
          str << " (" << HTML.escape(SuggestionItem.greek_for_agent(spec.author)) << ")</strong></span>\n"
          str << "                <span class=\"rfc-meta-pill rfc-repo-pill\">"
          str << IconRegistry.render("code") << " Repo: <code>" << HTML.escape(spec.target_repo) << "</code></span>\n"
          str << "                <span class=\"rfc-meta-pill rfc-discussion-pill\">"
          str << IconRegistry.render("comment-dots") << " Discussion: <code>" << HTML.escape(spec.resolved_discussion_label) << "</code></span>\n"
          str << "                <span class=\"rfc-meta-pill rfc-tally-pill\">"
          str << IconRegistry.render("circle-check") << " Approved: <strong>" << spec.approved_count << "</strong>"
          if spec.pending_count > 0
            str << " / Pending: <strong>" << spec.pending_count << "</strong>"
          end
          if spec.shelved_count > 0
            str << " / Shelved: <strong>" << spec.shelved_count << "</strong>"
          end
          str << "</span>\n"
          str << "              </div>\n"

          # Architectural Decision Matrix ([AS-X] rows)
          if spec.show_matrix_table
            str << render_matrix_table(spec)
          else
            str << render_suggestion_list(spec)
          end

          # Optional Specialist Council Deliberations
          unless spec.council_comments.empty?
            str << "              <div class=\"rfc-council-strip\">\n"
            str << "                <div class=\"rfc-council-header\">"
            str << IconRegistry.render("comment-dots") << " SPECIALIST COUNCIL DELIBERATIONS</div>\n"
            str << "                <div class=\"rfc-council-list\">\n"
            spec.council_comments.each do |c|
              str << render_council_row(c)
            end
            str << "                </div>\n"
            str << "              </div>\n"
          end

          # Optional Executive Summary / Takeaway Footer
          unless spec.summary.strip.empty?
            str << "              <div class=\"rfc-summary-footer\">\n"
            str << "                <span class=\"badge rfc-summary-badge\">" << IconRegistry.render("shield-check") << " DECISION SUMMARY</span>\n"
            str << "                <span class=\"rfc-summary-text\">" << IconRegistry.replace_icons(HTML.escape(spec.summary)) << "</span>\n"
            str << "              </div>\n"
          end

          str << "            </div>"
        end
      end

      def render_matrix_table(spec : RfcCardSpec) : String
        String.build do |str|
          str << "              <div class=\"rfc-decision-matrix-wrap\">\n"
          str << "                <table class=\"rfc-decision-matrix\" data-count=\"" << spec.total_count << "\">\n"
          str << "                  <thead>\n"
          str << "                    <tr>\n"
          str << "                      <th class=\"rfc-col-id\">[AS-X]</th>\n"
          str << "                      <th class=\"rfc-col-suggestion\">Architectural Suggestion &amp; Scope</th>\n"
          str << "                      <th class=\"rfc-col-owner\">Specialist</th>\n"
          str << "                      <th class=\"rfc-col-repo\">Target Repo</th>\n"
          str << "                      <th class=\"rfc-col-status\">Decision</th>\n"
          str << "                    </tr>\n"
          str << "                  </thead>\n"
          str << "                  <tbody>\n"
          spec.suggestions.each do |item|
            str << render_suggestion_row(item)
          end
          str << "                  </tbody>\n"
          str << "                </table>\n"
          str << "              </div>\n"
        end
      end

      def render_suggestion_row(item : SuggestionItem) : String
        st = item.normalized_status
        st_color = item.status_color
        String.build do |str|
          str << "                    <tr class=\"rfc-suggestion-row " << st << "\" data-as-id=\"" << HTML.escape(item.id) << "\" data-status=\"" << st << "\">\n"
          str << "                      <td class=\"rfc-cell-id\">\n"
          str << "                        <span class=\"badge rfc-as-badge " << st_color << "\" data-as-id=\"" << HTML.escape(item.id) << "\">" << HTML.escape(item.tag) << "</span>\n"
          if wo = item.work_order
            unless wo.strip.empty?
              str << "                        <span class=\"rfc-wo-tag\">" << HTML.escape(wo) << "</span>\n"
            end
          end
          str << "                      </td>\n"
          str << "                      <td class=\"rfc-cell-suggestion\">\n"
          str << "                        <div class=\"rfc-as-title\">" << IconRegistry.replace_icons(HTML.escape(item.title)) << "</div>\n"
          unless item.body.strip.empty?
            str << "                        <div class=\"rfc-as-body\">" << IconRegistry.replace_icons(HTML.escape(item.body)) << "</div>\n"
          end
          unless item.rationale.strip.empty?
            str << "                        <div class=\"rfc-as-rationale\">" << IconRegistry.render("lightbulb") << " " << IconRegistry.replace_icons(HTML.escape(item.rationale)) << "</div>\n"
          end
          str << "                      </td>\n"
          str << "                      <td class=\"rfc-cell-owner\">\n"
          str << "                        <span class=\"rfc-agent-pill\" data-agent=\"" << HTML.escape(item.agent.downcase) << "\">"
          str << "<span class=\"rfc-greek-badge\">" << HTML.escape(item.greek_symbol) << "</span> "
          str << HTML.escape(item.agent) << "</span>\n"
          str << "                      </td>\n"
          str << "                      <td class=\"rfc-cell-repo\">\n"
          str << "                        <code class=\"rfc-repo-code\">" << HTML.escape(item.repo) << "</code>\n"
          if iss = item.issue
            unless iss.strip.empty?
              str << "                        <span class=\"rfc-issue-tag\">" << HTML.escape(iss) << "</span>\n"
            end
          end
          str << "                      </td>\n"
          str << "                      <td class=\"rfc-cell-status\">\n"
          str << "                        <span class=\"badge rfc-status-badge " << st << " " << st_color << "\" data-status=\"" << st << "\">"
          str << IconRegistry.render(item.status_icon) << " " << HTML.escape(item.status_label) << "</span>\n"
          str << "                      </td>\n"
          str << "                    </tr>\n"
        end
      end

      def render_suggestion_list(spec : RfcCardSpec) : String
        String.build do |str|
          str << "              <ul class=\"card-list rfc-suggestion-list\">\n"
          spec.suggestions.each do |item|
            st = item.normalized_status
            st_color = item.status_color
            str << "                <li class=\"rfc-suggestion-item " << st << "\" data-as-id=\"" << HTML.escape(item.id) << "\" data-status=\"" << st << "\">\n"
            str << "                  <div class=\"rfc-suggestion-item-header\">\n"
            str << "                    <span class=\"badge rfc-as-badge " << st_color << "\">" << HTML.escape(item.tag) << "</span>\n"
            str << "                    <span class=\"rfc-agent-pill\"><span class=\"rfc-greek-badge\">" << HTML.escape(item.greek_symbol) << "</span> " << HTML.escape(item.agent) << "</span>\n"
            str << "                    <code class=\"rfc-repo-code\">" << HTML.escape(item.repo) << "</code>\n"
            if wo = item.work_order
              unless wo.strip.empty?
                str << "                    <span class=\"rfc-wo-tag\">" << HTML.escape(wo) << "</span>\n"
              end
            end
            str << "                    <span class=\"badge rfc-status-badge " << st << " " << st_color << "\">"
            str << IconRegistry.render(item.status_icon) << " " << HTML.escape(item.status_label) << "</span>\n"
            str << "                  </div>\n"
            str << "                  <div class=\"rfc-as-title\">" << IconRegistry.replace_icons(HTML.escape(item.title)) << "</div>\n"
            unless item.rationale.strip.empty?
              str << "                  <div class=\"rfc-as-rationale\">" << IconRegistry.render("lightbulb") << " " << IconRegistry.replace_icons(HTML.escape(item.rationale)) << "</div>\n"
            end
            str << "                </li>\n"
          end
          str << "              </ul>\n"
        end
      end

      def render_council_row(comment : CouncilCommentSpec) : String
        String.build do |str|
          str << "                  <div class=\"rfc-council-item\" data-agent=\"" << HTML.escape(comment.agent.downcase) << "\">\n"
          str << "                    <span class=\"rfc-council-agent\"><span class=\"rfc-greek-badge\">" << HTML.escape(comment.greek_symbol) << "</span> "
          str << "<strong>" << HTML.escape(comment.agent) << "</strong> (" << HTML.escape(comment.role) << ")</span>\n"
          unless comment.suggestion_ids.empty?
            str << "                    <span class=\"rfc-council-tags\">"
            comment.suggestion_ids.each do |sid|
              str << "<span class=\"badge rfc-as-badge\">[" << HTML.escape(sid) << "]</span>"
            end
            str << "</span>\n"
          end
          str << "                    <span class=\"rfc-council-perspective\">" << IconRegistry.replace_icons(HTML.escape(comment.perspective)) << "</span>\n"
          str << "                  </div>\n"
        end
      end

      def render_markdown(spec : RfcCardSpec) : String
        String.build do |str|
          str << "- **RFC Decision Matrix (`" << spec.rfc_id << "` — " << spec.title << ")**:\n"
          str << "  - **Status**: `" << spec.status_badge_text << "` | **Proposer**: " << spec.author << " (" << SuggestionItem.greek_for_agent(spec.author) << ") | **Target Repo**: `" << spec.target_repo << "`\n"
          unless spec.suggestions.empty?
            str << "  - **Atomic Suggestions (`[AS-X]`)**:\n"
            spec.suggestions.each do |item|
              wo_suffix = item.work_order ? " -> `#{item.work_order}`" : ""
              str << "    - `[" << item.id << "]` (**" << item.status_label << "** | " << item.agent << " `" << item.greek_symbol << "` | `" << item.repo << "`" << wo_suffix << "): " << item.title << "\n"
              unless item.rationale.strip.empty?
                str << "      - *Rationale*: " << item.rationale << "\n"
              end
            end
          end
          unless spec.council_comments.empty?
            str << "  - **Specialist Council Deliberations**:\n"
            spec.council_comments.each do |c|
              str << "    - **" << c.agent << " (" << c.greek_symbol << ")**: " << c.perspective << "\n"
            end
          end
          unless spec.summary.strip.empty?
            str << "  - **Decision Summary**: " << spec.summary << "\n"
          end
        end
      end

      def render_css : String
        <<-CSS
        /* ==============================================================================
           RFC Card & [AS-X] Architectural Decision Matrix Component
           Zero Inline Styles • Semantic Classes & Theme Variable Encapsulation
           ============================================================================== */
        .rfc-card {
          display: flex;
          flex-direction: column;
          gap: 0.65rem;
          padding: 0;
          overflow: hidden;
          border-radius: var(--sunstone-radius-md, 8px);
          background: var(--sunstone-surface, var(--bg-window, rgba(30, 41, 59, 0.85)));
          border: 1px solid var(--sunstone-border, var(--border-color, rgba(148, 163, 184, 0.25)));
        }

        .rfc-card:not(.rfc-window) {
          padding: 0.9rem 1.15rem;
        }

        .rfc-card.rfc-window > :not(.window-header) {
          padding-left: 1.05rem;
          padding-right: 1.05rem;
        }

        .rfc-card.rfc-window > :last-child {
          padding-bottom: 0.9rem;
        }

        .rfc-card-header {
          display: flex;
          align-items: center;
          justify-content: space-between;
          gap: 0.75rem;
          padding-top: 0.45rem;
          flex-wrap: wrap;
        }

        .rfc-title-group {
          display: flex;
          align-items: center;
          gap: 0.55rem;
          flex-wrap: wrap;
        }

        .rfc-card-title {
          font-size: 1.02rem;
          font-weight: 700;
          color: var(--sunstone-text-primary, var(--text-color, #f8fafc));
        }

        .rfc-card-subtitle {
          margin: -0.25rem 0 0 0;
          font-size: 0.82rem;
          opacity: 0.85;
          color: var(--sunstone-text-secondary, var(--text-dim, #cbd5e1));
        }

        .rfc-meta-strip {
          display: flex;
          flex-wrap: wrap;
          align-items: center;
          gap: 0.5rem;
          font-size: 0.74rem;
        }

        .rfc-meta-pill {
          display: inline-flex;
          align-items: center;
          gap: 0.32rem;
          padding: 0.18rem 0.55rem;
          border-radius: 6px;
          background: var(--sunstone-surface-hover, rgba(148, 163, 184, 0.12));
          border: 1px solid var(--sunstone-border, var(--border-color, rgba(148, 163, 184, 0.2)));
          color: var(--sunstone-text-secondary, var(--text-color, #cbd5e1));
        }

        .rfc-decision-matrix-wrap {
          width: 100%;
          overflow-x: auto;
        }

        .rfc-decision-matrix {
          width: 100%;
          border-collapse: collapse;
          font-size: 0.78rem;
          text-align: left;
        }

        .rfc-decision-matrix th {
          padding: 0.42rem 0.6rem;
          font-size: 0.68rem;
          font-weight: 700;
          text-transform: uppercase;
          letter-spacing: 0.05em;
          border-bottom: 2px solid var(--sunstone-border, var(--border-color, rgba(148, 163, 184, 0.3)));
          color: var(--sunstone-text-secondary, var(--text-dim, #94a3b8));
        }

        .rfc-decision-matrix td {
          padding: 0.48rem 0.6rem;
          vertical-align: middle;
          border-bottom: 1px solid var(--sunstone-border, var(--border-color, rgba(148, 163, 184, 0.16)));
        }

        .rfc-card.compact .rfc-decision-matrix td {
          padding: 0.34rem 0.5rem;
        }

        .rfc-as-badge {
          font-family: var(--sunstone-font-mono, 'JetBrains Mono', 'Fira Code', monospace);
          font-weight: 800;
          font-size: 0.7rem;
          padding: 0.15rem 0.5rem;
          border-radius: 4px;
        }

        .rfc-wo-tag,
        .rfc-issue-tag {
          display: inline-block;
          font-family: var(--sunstone-font-mono, 'JetBrains Mono', monospace);
          font-size: 0.66rem;
          font-weight: 600;
          opacity: 0.85;
          margin-left: 0.25rem;
        }

        .rfc-as-title {
          font-weight: 600;
          line-height: 1.3;
          color: var(--sunstone-text-primary, var(--text-color, #f8fafc));
        }

        .rfc-as-body,
        .rfc-as-rationale {
          font-size: 0.72rem;
          opacity: 0.85;
          margin-top: 0.15rem;
          line-height: 1.3;
        }

        .rfc-agent-pill {
          display: inline-flex;
          align-items: center;
          gap: 0.3rem;
          font-weight: 600;
          font-size: 0.74rem;
          white-space: nowrap;
        }

        .rfc-greek-badge {
          display: inline-flex;
          align-items: center;
          justify-content: center;
          width: 1.25rem;
          height: 1.25rem;
          border-radius: 4px;
          font-weight: 800;
          font-size: 0.72rem;
          background: var(--sunstone-surface-hover, rgba(56, 189, 248, 0.15));
          color: var(--sunstone-accent, var(--accent-color, #38bdf8));
        }

        .rfc-repo-code {
          font-size: 0.7rem;
          padding: 0.12rem 0.4rem;
          border-radius: 4px;
          white-space: nowrap;
        }

        .rfc-status-badge {
          display: inline-flex;
          align-items: center;
          gap: 0.3rem;
          font-size: 0.68rem;
          font-weight: 700;
          white-space: nowrap;
        }

        .rfc-council-strip {
          display: flex;
          flex-direction: column;
          gap: 0.35rem;
          padding-top: 0.35rem;
          border-top: 1px dashed var(--sunstone-border, var(--border-color, rgba(148, 163, 184, 0.25)));
          font-size: 0.74rem;
        }

        .rfc-council-header {
          font-size: 0.68rem;
          font-weight: 800;
          letter-spacing: 0.05em;
          text-transform: uppercase;
          opacity: 0.85;
        }

        .rfc-council-list {
          display: flex;
          flex-direction: column;
          gap: 0.28rem;
        }

        .rfc-council-item {
          display: flex;
          align-items: center;
          gap: 0.45rem;
          flex-wrap: wrap;
        }

        .rfc-summary-footer {
          display: flex;
          align-items: center;
          gap: 0.55rem;
          padding-top: 0.4rem;
          border-top: 1px solid var(--sunstone-border, var(--border-color, rgba(148, 163, 184, 0.22)));
          font-size: 0.76rem;
        }

        .rfc-summary-text {
          font-weight: 500;
          color: var(--sunstone-text-primary, var(--text-color, #f8fafc));
        }
        CSS
      end

      private def status_icon_svg(status : String) : String
        case status
        when "approved" then IconRegistry.render("circle-check")
        when "shelved"  then IconRegistry.render("ban")
        else                 IconRegistry.render("clock")
        end
      end
    end
  end
end
