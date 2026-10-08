require "./spec_helper"

describe "Sunstone Layouts (Strict Zero-Inline-Styles)" do
  deck = Sunstone::Deck.load("examples/showcase/deck.yml")
  palettes = Sunstone::Palette.load_for_theme(deck.theme)

  Sunstone::LayoutRouter::AVAILABLE_LAYOUTS.each do |layout_name|
    it "renders '#{layout_name}' layout with zero inline style attributes on HTML tags" do
      slide = deck.slides.find { |s| s.layout == layout_name } || deck.slides.first
      renderer = Sunstone::LayoutRouter.resolve(layout_name)
      palette = palettes[slide.palette]? || palettes.values.first

      html = renderer.render_html(slide, deck, palette, 1, 10)

      # Check for semantic data attributes
      html.should contain("data-layout=")
      html.should contain("data-palette=")

      # Verify that no presentation HTML tag has an inline style attribute
      # (Ignore any raw code snippets that might be printed inside <code>)
      clean_html = html.gsub(/<code[^>]*>.*?<\/code>/m, "")
      clean_html.should_not contain(" style=")
      clean_html.should_not contain(" style =")
    end
  end

  it "resolves aliases correctly in LayoutRouter" do
    Sunstone::LayoutRouter.resolve("split").should be_a(Sunstone::TwoColumnLayout)
    Sunstone::LayoutRouter.resolve("critique").should be_a(Sunstone::CodeComparisonLayout)
    Sunstone::LayoutRouter.resolve("hero").should be_a(Sunstone::IntroLayout)
    Sunstone::LayoutRouter.resolve("divider").should be_a(Sunstone::ChapterLayout)
    Sunstone::LayoutRouter.resolve("quadrant").should be_a(Sunstone::MatrixLayout)
    Sunstone::LayoutRouter.resolve("roadmap").should be_a(Sunstone::TimelineLayout)
    Sunstone::LayoutRouter.resolve("stack").should be_a(Sunstone::ArchitectureLayout)
    Sunstone::LayoutRouter.resolve("kpi").should be_a(Sunstone::StatsLayout)
    Sunstone::LayoutRouter.resolve("bento").should be_a(Sunstone::FeatureGridLayout)
    Sunstone::LayoutRouter.resolve("pipeline").should be_a(Sunstone::ProcessFlowLayout)
    Sunstone::LayoutRouter.resolve("benchmark").should be_a(Sunstone::TableLayout)
    Sunstone::LayoutRouter.resolve("q-and-a").should be_a(Sunstone::FaqLayout)
    Sunstone::LayoutRouter.resolve("1l-2r").should be_a(Sunstone::OneLeftTwoRightLayout)
    Sunstone::LayoutRouter.resolve("2l-1r").should be_a(Sunstone::TwoLeftOneRightLayout)
    Sunstone::LayoutRouter.resolve("1t-2b").should be_a(Sunstone::OneTopTwoBottomLayout)
    Sunstone::LayoutRouter.resolve("2t-1b").should be_a(Sunstone::TwoTopOneBottomLayout)
    Sunstone::LayoutRouter.resolve("1l-3r").should be_a(Sunstone::OneLeftThreeRightLayout)
    Sunstone::LayoutRouter.resolve("3l-1r").should be_a(Sunstone::ThreeLeftOneRightLayout)
    Sunstone::LayoutRouter.resolve("timeline-vertical").should be_a(Sunstone::VerticalTimelineLayout)
    Sunstone::LayoutRouter.resolve("gantt").should be_a(Sunstone::RoadmapTimelineLayout)
    Sunstone::LayoutRouter.resolve("calendar").should be_a(Sunstone::CalendarMonthLayout)
    Sunstone::LayoutRouter.resolve("schedule").should be_a(Sunstone::CalendarScheduleLayout)
    Sunstone::LayoutRouter.resolve("flywheel").should be_a(Sunstone::RadialCycleLayout)
    Sunstone::LayoutRouter.resolve("magazine").should be_a(Sunstone::EditorialSplitLayout)
    Sunstone::LayoutRouter.resolve("venn").should be_a(Sunstone::ConvergenceLayout)
  end

  it "renders window headers with exactly one set of terminal dots and suppresses pseudo-element duplicate dots" do
    slide = deck.slides.find { |s| s.layout == "two-column" } || deck.slides.first
    renderer = Sunstone::LayoutRouter.resolve("two-column")
    palette = palettes[slide.palette]? || palettes.values.first
    html = renderer.render_html(slide, deck, palette, 1, 10)

    # Must contain semantic terminal-dots
    html.should contain("terminal-dots")
    html.should contain("terminal-dot dot-1 red")
    html.should contain("terminal-dot dot-2 yellow")
    html.should contain("terminal-dot dot-3 green")

    # Base CSS must suppress .window-header::before so no pseudo-element duplicate dots exist
    Sunstone::Assets::BASE_CSS.should contain(".window-header::before")
    Sunstone::Assets::BASE_CSS.should contain("content: none !important;")
  end
end
