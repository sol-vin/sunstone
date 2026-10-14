require "./spec_helper"
require "file_utils"

describe Sunstone::RfcCard do
  describe "Tier 1: Core Engine (SuggestionItem, CouncilCommentSpec, RfcCardSpec, Renderer)" do
    it "normalizes [AS-X] IDs, statuses, and Greek specialist symbols" do
      s1 = Sunstone::RfcCard::SuggestionItem.new(
        id: "1",
        title: "Implement RFCInspector engine",
        status: "approve",
        agent: "Delta",
        repo: "sol-vin/solvin-ai-org",
        work_order: "WO-067",
        issue: 141
      )
      s1.id.should eq("AS-1")
      s1.tag.should eq("[AS-1]")
      s1.normalized_status.should eq("approved")
      s1.status_label.should eq("APPROVED")
      s1.status_color.should eq("emerald")
      s1.status_icon.should eq("circle-check")
      s1.greek_symbol.should eq("Δ")
      s1.issue.should eq("#141")

      s2 = Sunstone::RfcCard::SuggestionItem.new(
        id: "[as-3]",
        title: "Add declarative rfc_card slide component builder",
        status: "pending",
        agent: "Sigma",
        repo: "sol-vin/sunstone"
      )
      s2.id.should eq("AS-3")
      s2.tag.should eq("[AS-3]")
      s2.greek_symbol.should eq("Σ")
      s2.status_label.should eq("PENDING")
      s2.status_color.should eq("amber")
      s2.status_icon.should eq("clock")

      s3 = Sunstone::RfcCard::SuggestionItem.new(
        id: "AS2",
        title: "Experimental deferred item",
        status: "shelve",
        agent: "Beta",
        repo: "sol-vin/sol.vin"
      )
      s3.id.should eq("AS-2")
      s3.greek_symbol.should eq("Β")
      s3.normalized_status.should eq("shelved")
      s3.status_label.should eq("SHELVED")
      s3.status_color.should eq("rose")
      s3.status_icon.should eq("ban")
    end

    it "parses [AS-X] lines directly from RFC markdown proposal text" do
      markdown = <<-MD
      - **[AS-1]**: (Repo: sol-vin/solvin-ai-org, Agent: Delta, Status: approved, WO: WO-067) Implement Two-Tier `RFCInspector` engine & endpoints.
      - **[AS-2]**: (Repo: sol-vin/solvin-ai-org, Agent: Beta, Status: approved, WO: WO-068) Build the retro OS User Ticket `[AS-X]` Inspector & Approval Modal.
      - **[AS-3]**: (Repo: sol-vin/sunstone, Agent: Sigma, Status: approved, WO: WO-069) Add a declarative `rfc_card` slide component builder in `sol-vin/sunstone`.
      MD

      items = Sunstone::RfcCard::SuggestionItem.parse_markdown_suggestions(markdown)
      items.size.should eq(3)
      items[0].id.should eq("AS-1")
      items[0].agent.should eq("Delta")
      items[0].repo.should eq("sol-vin/solvin-ai-org")
      items[0].work_order.should eq("WO-067")
      items[0].normalized_status.should eq("approved")

      items[2].id.should eq("AS-3")
      items[2].agent.should eq("Sigma")
      items[2].greek_symbol.should eq("Σ")
      items[2].repo.should eq("sol-vin/sunstone")
      items[2].work_order.should eq("WO-069")
    end

    it "computes overall RFC status and tallies from SuggestionItem list" do
      spec = Sunstone::RfcCard::RfcCardSpec.new(
        rfc_id: "RFC-112",
        discussion_number: 112,
        title: "Interactive User Ticket Approval & [AS-X] Drawer",
        author: "Beta",
        target_repo: "sol-vin/sunstone",
        suggestions: [
          Sunstone::RfcCard::SuggestionItem.new(id: "AS-1", title: "Inspector Engine", status: "approved", agent: "Delta"),
          Sunstone::RfcCard::SuggestionItem.new(id: "AS-2", title: "Retro OS Modal", status: "approved", agent: "Beta"),
          Sunstone::RfcCard::SuggestionItem.new(id: "AS-3", title: "Sunstone rfc_card", status: "approved", agent: "Sigma"),
        ]
      )
      spec.total_count.should eq(3)
      spec.approved_count.should eq(3)
      spec.pending_count.should eq(0)
      spec.shelved_count.should eq(0)
      spec.effective_status.should eq("approved")
      spec.status_badge_text.should eq("APPROVED (3/3)")
    end

    it "renders strictly zero-inline-style semantic HTML with FontAwesome SVG icons and zero Unicode emojis" do
      spec = Sunstone::RfcCard::RfcCardSpec.new(
        rfc_id: "RFC-112",
        discussion_number: 112,
        title: "Interactive User Ticket Approval & [AS-X] Drawer",
        subtitle: "Cross-Repo Governance & Presentation Matrix",
        badge: "RFC #112",
        color: "emerald",
        author: "Beta",
        target_repo: "sol-vin/sunstone",
        summary: "All 3 atomic suggestions approved by @sol-vin and promoted to tracked work orders.",
        suggestions: [
          Sunstone::RfcCard::SuggestionItem.new(
            id: "AS-1",
            title: "Implement Two-Tier RFCInspector engine & endpoints",
            status: "approved",
            agent: "Delta",
            repo: "sol-vin/solvin-ai-org",
            work_order: "WO-067",
            issue: 141,
            rationale: "Decouples GraphQL discussion inspection from UI presentation."
          ),
          Sunstone::RfcCard::SuggestionItem.new(
            id: "AS-2",
            title: "Build retro OS User Ticket [AS-X] Inspector & Approval Modal",
            status: "approved",
            agent: "Beta",
            repo: "sol-vin/solvin-ai-org",
            work_order: "WO-068",
            issue: 142
          ),
          Sunstone::RfcCard::SuggestionItem.new(
            id: "AS-3",
            title: "Add declarative rfc_card slide component builder in sol-vin/sunstone",
            status: "approved",
            agent: "Sigma",
            repo: "sol-vin/sunstone",
            work_order: "WO-069",
            issue: 143
          ),
        ],
        council_comments: [
          Sunstone::RfcCard::CouncilCommentSpec.new(
            agent: "Sigma",
            role: "Slideshow & Presentation Engineer",
            perspective: "Enables zero-inline-style [AS-X] decision matrices across all 6 Sunstone themes.",
            suggestion_ids: ["AS-3"]
          ),
        ]
      )

      html = Sunstone::RfcCard::Renderer.render_html(spec)

      html.should contain("data-component=\"rfc-card\"")
      html.should contain("data-rfc-id=\"RFC-112\"")
      html.should contain("data-status=\"approved\"")
      html.should contain("[AS-1]")
      html.should contain("[AS-2]")
      html.should contain("[AS-3]")
      html.should contain("WO-067")
      html.should contain("WO-068")
      html.should contain("WO-069")
      html.should contain("#141")
      html.should contain("#143")
      html.should contain("sol-vin/sunstone")
      html.should contain("fa-icon fa-scroll")
      html.should contain("fa-icon fa-circle-check")
      html.should contain("SPECIALIST COUNCIL DELIBERATIONS")
      html.should contain("DECISION SUMMARY")
      html.should_not contain(" style=")
      html.should_not contain(" style =")
    end
  end

  describe "Tier 2: Declarative DSL (Sunstone.rfc_card, Sunstone::RfcCard.build, CardBuilder)" do
    it "builds and renders an [AS-X] architectural decision matrix via declarative block DSL" do
      Sunstone::RFCCard.should eq(Sunstone::RfcCard)

      html = Sunstone.rfc_card do |card|
        card.rfc_id "RFC-112"
        card.discussion 112
        card.title "Interactive User Ticket Approval & [AS-X] Drawer"
        card.subtitle "Mission Control Web UI & Sunstone Integration"
        card.badge "ARCHITECTURE RFC"
        card.color "emerald"
        card.proposer "Beta"
        card.target_repo "sol-vin/sunstone"
        card.takeaway "Approved by @sol-vin across all 3 atomic suggestions."

        card.suggestion "AS-1" do |s|
          s.title "Implement Two-Tier RFCInspector engine & endpoints"
          s.specialist "Delta"
          s.repository "sol-vin/solvin-ai-org"
          s.wo "WO-067"
          s.issue 141
          s.approved!
          s.rationale "Provides live [AS-X] inspection and granular /approve dispatch."
        end

        card.as_item "AS-2" do |s|
          s.title "Build retro OS User Ticket [AS-X] Inspector & Approval Modal"
          s.agent "Beta"
          s.repo "sol-vin/solvin-ai-org"
          s.work_order "WO-068"
          s.issue "#142"
          s.approved!
        end

        card.suggestion "AS-3" do |s|
          s.title "Add declarative rfc_card slide component builder in sol-vin/sunstone"
          s.agent "Sigma"
          s.repo "sol-vin/sunstone"
          s.work_order "WO-069"
          s.issue 143
          s.approved!
        end

        card.council "Sigma" do |c|
          c.role "Slide Engine Lead"
          c.for_suggestions "AS-3"
          c.comment "Integrates seamlessly with TwoColumnLayout, RfcCardLayout, and RevealAdapter."
        end
      end

      html.should contain("data-component=\"rfc-card\"")
      html.should contain("RFC-112")
      html.should contain("APPROVED (3/3)")
      html.should contain("data-as-id=\"AS-1\"")
      html.should contain("data-as-id=\"AS-2\"")
      html.should contain("data-as-id=\"AS-3\"")
      html.should contain("WO-069")
      html.should contain("Slide Engine Lead")
      html.should_not contain(" style=")

      md = Sunstone::RfcCard.render_markdown do |card|
        card.rfc_id "RFC-112"
        card.title "Interactive User Ticket Approval"
        card.author "Beta"
        card.target_repo "sol-vin/sunstone"
        card.suggestion("AS-3", "Add rfc_card slide component builder", status: "approved", agent: "Sigma", repo: "sol-vin/sunstone", work_order: "WO-069")
      end

      md.should contain("RFC Decision Matrix (`RFC-112`")
      md.should contain("`[AS-3]` (**APPROVED** | Sigma `Σ` | `sol-vin/sunstone` -> `WO-069`)")
    end

    it "renders rfc_card slots inside TwoColumnLayout, RfcCardLayout, and RevealAdapter" do
      two_col_slide = Sunstone::Slide.from_yaml_string(<<-YAML)
        id: rfc_two_col
        layout: two-column
        title: "RFC #112 Architectural Review"
        ratio: "1:1"
        left:
          type: code
          title: "rfc_deck.cr"
          lang: crystal
          code: |
            Sunstone.rfc_card do |card|
              card.rfc_id "RFC-112"
            end
        right:
          type: rfc_card
          rfc_id: "RFC-112"
          discussion_number: 112
          title: "Atomic Suggestion Decision Matrix"
          author: "Beta"
          target_repo: "sol-vin/sunstone"
          suggestions:
            - id: "AS-1"
              title: "RFCInspector Engine"
              agent: "Delta"
              repo: "sol-vin/solvin-ai-org"
              status: "approved"
              work_order: "WO-067"
            - id: "AS-3"
              title: "Declarative rfc_card Builder"
              agent: "Sigma"
              repo: "sol-vin/sunstone"
              status: "approved"
              work_order: "WO-069"
      YAML

      dedicated_slide = Sunstone::Slide.from_yaml_string(<<-YAML)
        id: rfc_dedicated
        layout: rfc-card
        badge: "RFC #112"
        title: "Sol-Vin RFC #112 Decision Matrix"
        rfc_id: "RFC-112"
        author: "Beta"
        target_repo: "sol-vin/sunstone"
        summary: "All suggestions approved."
        suggestions:
          - "[AS-1]: (Repo: sol-vin/solvin-ai-org, Agent: Delta, Status: approved, WO: WO-067) Implement RFCInspector engine"
          - "[AS-2]: (Repo: sol-vin/solvin-ai-org, Agent: Beta, Status: approved, WO: WO-068) Build User Ticket Modal"
          - "[AS-3]: (Repo: sol-vin/sunstone, Agent: Sigma, Status: approved, WO: WO-069) Add declarative rfc_card builder"
      YAML

      deck = Sunstone::Deck.from_yaml_string(<<-YAML, [two_col_slide, dedicated_slide])
        title: "RFC Architecture Deck"
        theme: "sol.vin"
      YAML

      palettes = Sunstone::Palette.load_for_theme(deck.theme)
      palette = palettes.values.first

      two_col_renderer = Sunstone::LayoutRouter.resolve(two_col_slide.layout)
      two_col_html = two_col_renderer.render_html(two_col_slide, deck, palette, 1, 2)
      two_col_html.should contain("data-component=\"rfc-card\"")
      two_col_html.should contain("[AS-1]")
      two_col_html.should contain("[AS-3]")
      two_col_html.gsub(/<code[^>]*>.*?<\/code>/m, "").should_not contain(" style=")

      rfc_layout_renderer = Sunstone::LayoutRouter.resolve("rfc_card")
      rfc_layout_renderer.should be_a(Sunstone::RfcCardLayout)
      dedicated_html = rfc_layout_renderer.render_html(dedicated_slide, deck, palette, 2, 2)
      dedicated_html.should contain("data-layout=\"rfc-card\"")
      dedicated_html.should contain("data-component=\"rfc-card\"")
      dedicated_html.should contain("APPROVED (3/3)")
      dedicated_html.should contain("WO-069")
      dedicated_html.gsub(/<code[^>]*>.*?<\/code>/m, "").should_not contain(" style=")

      reveal_html = deck.to_reveal
      reveal_html.should contain("Sol-Vin RFC #112 Decision Matrix")
    end
  end
end
