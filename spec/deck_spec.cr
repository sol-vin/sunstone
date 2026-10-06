require "./spec_helper"

describe Sunstone::Deck do
  it "loads deck from YAML and resolves slide paths" do
    deck = Sunstone::Deck.load("examples/showcase/deck.yml")
    deck.title.should eq("Sunstone Showcase")
    deck.theme.should eq("generic")
    deck.width.should eq(1280)
    deck.height.should eq(720)
    deck.slides.size.should eq(16)

    intro = deck.slides.first
    intro.id.should eq("intro")
    intro.layout.should eq("intro")
    intro.badge.should eq("SHOWCASE DECK")
  end

  it "formats footer strings with template variables" do
    deck = Sunstone::Deck.load("examples/showcase/deck.yml")
    slide = deck.slides.first
    palettes = Sunstone::Palette.load_for_theme(deck.theme)
    palette = palettes[slide.palette]? || palettes.values.first

    renderer = Sunstone::LayoutRouter.resolve(slide.layout)
    footer = renderer.format_footer_template(deck.footer_right, slide, deck, palette, 1, 17)
    footer.should eq("Slide 1 / 17")
  end
end
