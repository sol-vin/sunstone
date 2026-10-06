require "./layout_renderer"
require "./two_column_layout"
require "./code_comparison_layout"
require "./three_column_layout"
require "./four_column_layout"
require "./intro_layout"
require "./chapter_layout"
require "./matrix_layout"
require "./timeline_layout"
require "./architecture_layout"
require "./media_layout"
require "./profile_layout"
require "./dual_mode_layout"
require "./demo_roadmap_layout"
require "./closing_layout"
require "./quote_layout"
require "./stats_layout"
require "./feature_grid_layout"
require "./process_flow_layout"
require "./table_layout"
require "./faq_layout"

module Sunstone
  module LayoutRouter
    # Singleton layout renderer instances for high performance
    TWO_COLUMN      = TwoColumnLayout.new
    CODE_COMPARISON = CodeComparisonLayout.new
    THREE_COLUMN    = ThreeColumnLayout.new
    FOUR_COLUMN     = FourColumnLayout.new
    INTRO           = IntroLayout.new
    CHAPTER         = ChapterLayout.new
    MATRIX          = MatrixLayout.new
    TIMELINE        = TimelineLayout.new
    ARCHITECTURE    = ArchitectureLayout.new
    MEDIA           = MediaLayout.new
    PROFILE         = ProfileLayout.new
    DUAL_MODE       = DualModeLayout.new
    DEMO_ROADMAP    = DemoRoadmapLayout.new
    CLOSING         = ClosingLayout.new
    QUOTE           = QuoteLayout.new
    STATS           = StatsLayout.new
    FEATURE_GRID    = FeatureGridLayout.new
    PROCESS_FLOW    = ProcessFlowLayout.new
    TABLE           = TableLayout.new
    FAQ             = FaqLayout.new

    AVAILABLE_LAYOUTS = [
      "two-column",
      "code-comparison",
      "three-column",
      "four-column",
      "intro",
      "chapter",
      "matrix",
      "timeline",
      "architecture",
      "media",
      "profile",
      "dual-mode",
      "demo-roadmap",
      "closing",
      "quote",
      "stats",
      "feature-grid",
      "process-flow",
      "table",
      "faq",
    ]

    def self.resolve(layout_name : String) : LayoutRenderer
      normalized = layout_name.strip.downcase.gsub("_", "-")

      case normalized
      when "two-column", "split", "code-notes", "two-col"
        TWO_COLUMN
      when "code-comparison", "comparison", "critique", "two-step"
        CODE_COMPARISON
      when "three-column", "three-col", "columns-3", "3col"
        THREE_COLUMN
      when "four-column", "four-col", "columns-4", "4col", "grid"
        FOUR_COLUMN
      when "intro", "title", "hero", "welcome"
        INTRO
      when "chapter", "divider", "section", "transition"
        CHAPTER
      when "matrix", "quadrant", "2x2", "grid-2x2"
        MATRIX
      when "timeline", "roadmap", "history", "phases"
        TIMELINE
      when "architecture", "stack", "layers", "tiers"
        ARCHITECTURE
      when "media", "image", "asciinema", "video", "terminal"
        MEDIA
      when "profile", "speaker", "author", "bio", "team"
        PROFILE
      when "dual-mode", "toggle", "tabs", "before-after"
        DUAL_MODE
      when "demo-roadmap", "checklist", "agenda"
        DEMO_ROADMAP
      when "closing", "thankyou", "thanks", "outro", "conclusion"
        CLOSING
      when "quote", "testimonial", "callout", "statement"
        QUOTE
      when "stats", "kpi", "numbers", "dashboard", "metrics", "key-metrics"
        STATS
      when "feature-grid", "bento", "bento-box", "showcase"
        FEATURE_GRID
      when "process-flow", "workflow", "pipeline", "steps", "funnel"
        PROCESS_FLOW
      when "table", "benchmark", "comparison-table", "spec-sheet", "data-table"
        TABLE
      when "faq", "q-and-a", "questions", "accordion"
        FAQ
      else
        # Fallback to two-column layout for unknown names
        TWO_COLUMN
      end
    end
  end
end
