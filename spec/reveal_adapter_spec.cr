require "./spec_helper"
require "../src/sunstone/adapters/reveal_adapter"

describe Sunstone::Adapters::RevealAdapter do
  it "renders a Sunstone::Deck into Reveal.js HTML" do
    slide1 = Sunstone::Slide.from_yaml_string(<<-YAML)
      id: slide_1
      layout: intro
      title: "Sol-Vin Keynote"
      subtitle: "GDExtension Architecture"
      content: "Welcome to the next-generation game engine in Crystal."
      notes: "Pause for audience welcome."
    YAML

    slide2 = Sunstone::Slide.from_yaml_string(<<-YAML)
      id: slide_2
      layout: two-column
      title: "Two-Tier Engine"
      content: "Decoupling engine from DSL."
      code: |
        node Player < CharacterBody3D do
          prop speed : Float32 = 10.0
        end
      code_lang: crystal
    YAML

    deck = Sunstone::Deck.from_yaml_string(<<-YAML, [slide1, slide2])
      title: "Lapis Architecture Presentation"
    YAML

    html = Sunstone.to_reveal(deck, theme: "black", transition: "fade")

    html.should contain("<!doctype html>")
    html.should contain("<div class=\"reveal\">")
    html.should contain("<div class=\"slides\">")
    html.should contain("<title>Lapis Architecture Presentation</title>")
    html.should contain("<h2>Sol-Vin Keynote</h2>")
    html.should contain("Pause for audience welcome.")
    html.should contain("language-crystal")
    html.should contain("transition: 'fade'")
  end

  it "renders via Deck#to_reveal extension method" do
    deck = Sunstone::Deck.from_yaml_string(<<-YAML)
      title: "Quick Deck"
    YAML
    html = deck.to_reveal(theme: "dracula")

    html.should contain("dracula.css")
    html.should contain("<title>Quick Deck</title>")
  end
end
