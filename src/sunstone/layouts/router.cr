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
require "./one_left_two_right_layout"
require "./two_left_one_right_layout"
require "./one_top_two_bottom_layout"
require "./two_top_one_bottom_layout"
require "./one_left_three_right_layout"
require "./three_left_one_right_layout"
require "./vertical_timeline_layout"
require "./roadmap_timeline_layout"
require "./calendar_month_layout"
require "./calendar_schedule_layout"
require "./radial_cycle_layout"
require "./editorial_split_layout"
require "./convergence_layout"

module Sunstone
  module LayoutRouter
    # Singleton layout renderer instances for high performance
    TWO_COLUMN           = TwoColumnLayout.new
    CODE_COMPARISON      = CodeComparisonLayout.new
    THREE_COLUMN         = ThreeColumnLayout.new
    FOUR_COLUMN          = FourColumnLayout.new
    INTRO                = IntroLayout.new
    CHAPTER              = ChapterLayout.new
    MATRIX               = MatrixLayout.new
    TIMELINE             = TimelineLayout.new
    ARCHITECTURE         = ArchitectureLayout.new
    MEDIA                = MediaLayout.new
    PROFILE              = ProfileLayout.new
    DUAL_MODE            = DualModeLayout.new
    DEMO_ROADMAP         = DemoRoadmapLayout.new
    CLOSING              = ClosingLayout.new
    QUOTE                = QuoteLayout.new
    STATS                = StatsLayout.new
    FEATURE_GRID         = FeatureGridLayout.new
    PROCESS_FLOW         = ProcessFlowLayout.new
    TABLE                = TableLayout.new
    FAQ                  = FaqLayout.new
    ONE_LEFT_TWO_RIGHT   = OneLeftTwoRightLayout.new
    TWO_LEFT_ONE_RIGHT   = TwoLeftOneRightLayout.new
    ONE_TOP_TWO_BOTTOM   = OneTopTwoBottomLayout.new
    TWO_TOP_ONE_BOTTOM   = TwoTopOneBottomLayout.new
    ONE_LEFT_THREE_RIGHT = OneLeftThreeRightLayout.new
    THREE_LEFT_ONE_RIGHT = ThreeLeftOneRightLayout.new
    VERTICAL_TIMELINE    = VerticalTimelineLayout.new
    ROADMAP_TIMELINE     = RoadmapTimelineLayout.new
    CALENDAR_MONTH       = CalendarMonthLayout.new
    CALENDAR_SCHEDULE    = CalendarScheduleLayout.new
    RADIAL_CYCLE         = RadialCycleLayout.new
    EDITORIAL_SPLIT      = EditorialSplitLayout.new
    CONVERGENCE          = ConvergenceLayout.new

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
      "one-left-two-right",
      "two-left-one-right",
      "one-top-two-bottom",
      "two-top-one-bottom",
      "one-left-three-right",
      "three-left-one-right",
      "vertical-timeline",
      "roadmap-timeline",
      "calendar-month",
      "calendar-schedule",
      "radial-cycle",
      "editorial-split",
      "convergence",
    ]

    def self.resolve(layout_name : String) : LayoutRenderer
      resolve?(layout_name) || TWO_COLUMN
    end

    def self.resolve?(layout_name : String) : LayoutRenderer?
      normalized = layout_name.strip.downcase.gsub("_", "-")
      normalized = normalized[0...-7] if normalized.ends_with?("-layout")

      case normalized
      when "two-column", "split", "code-notes", "two-col"
        TWO_COLUMN
      when "code-comparison", "comparison", "critique", "two-step", "antipattern-compare"
        CODE_COMPARISON
      when "three-column", "three-col", "columns-3", "3col"
        THREE_COLUMN
      when "four-column", "four-col", "columns-4", "4col", "grid"
        FOUR_COLUMN
      when "intro", "title", "hero", "welcome"
        INTRO
      when "chapter", "divider", "section", "transition", "title-card"
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
      when "one-left-two-right", "1l-2r", "left-stacked-right", "split-1-2", "left-stack-right"
        ONE_LEFT_TWO_RIGHT
      when "two-left-one-right", "2l-1r", "stacked-left-right", "split-2-1", "stack-left-right"
        TWO_LEFT_ONE_RIGHT
      when "one-top-two-bottom", "1t-2b", "top-split-bottom", "hero-top-two-bottom"
        ONE_TOP_TWO_BOTTOM
      when "two-top-one-bottom", "2t-1b", "split-top-bottom", "two-top-bottom-hero"
        TWO_TOP_ONE_BOTTOM
      when "one-left-three-right", "1l-3r", "left-stack-3"
        ONE_LEFT_THREE_RIGHT
      when "three-left-one-right", "3l-1r", "stack-3-left"
        THREE_LEFT_ONE_RIGHT
      when "vertical-timeline", "timeline-vertical", "milestones-vertical", "changelog"
        VERTICAL_TIMELINE
      when "roadmap-timeline", "gantt", "gantt-chart", "quarterly-roadmap", "release-schedule"
        ROADMAP_TIMELINE
      when "calendar-month", "monthly-calendar", "calendar-grid", "calendar"
        CALENDAR_MONTH
      when "calendar-schedule", "weekly-agenda", "agenda-layout", "conference-schedule", "day-schedule", "schedule"
        CALENDAR_SCHEDULE
      when "radial-cycle", "cycle", "circular-process", "flywheel", "loop", "feedback-loop"
        RADIAL_CYCLE
      when "editorial-split", "magazine", "editorial", "hero-quote-split", "artistic-editorial"
        EDITORIAL_SPLIT
      when "convergence", "tri-pillar", "intersection", "sweet-spot", "venn-layout", "venn"
        CONVERGENCE
      else
        nil
      end
    end
  end
end
